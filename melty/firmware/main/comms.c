#include "comms.h"
#include "wifi_password.h"

#include <stdio.h>
#include <string.h>
#include "esp_system.h"
#include "esp_event.h"
#include "esp_log.h"
#include "esp_wifi.h"

#include "lwip/err.h"
#include "lwip/sockets.h"
#include "lwip/sys.h"
#include <lwip/netdb.h>

#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "freertos/event_groups.h"

static const char * TAG = "wifi";

static int s_retry_num = 0;

/* FreeRTOS event group to signal when we are connected*/
static EventGroupHandle_t s_wifi_event_group;

/* The event group allows multiple bits for each event, but we only care about two events:
 * - we are connected to the AP with an IP
 * - we failed to connect after the maximum amount of retries */
#define WIFI_CONNECTED_BIT BIT0
#define WIFI_FAIL_BIT      BIT1

#define EXAMPLE_ESP_MAXIMUM_RETRY  100

comms_state_t comms_state; 

static void wifi_event_handler(void* arg, esp_event_base_t event_base,
                                    int32_t event_id, void* event_data)
{
    // AP events
    if (event_id == WIFI_EVENT_AP_STACONNECTED) {
        wifi_event_ap_staconnected_t* event = (wifi_event_ap_staconnected_t*) event_data;
        ESP_LOGI(TAG, "station "MACSTR" join, AID=%d",
                 MAC2STR(event->mac), event->aid);
    } else if (event_id == WIFI_EVENT_AP_STADISCONNECTED) {
        wifi_event_ap_stadisconnected_t* event = (wifi_event_ap_stadisconnected_t*) event_data;
        ESP_LOGI(TAG, "station "MACSTR" leave, AID=%d",
                 MAC2STR(event->mac), event->aid);
    }
    // Station events:
    if (event_base == WIFI_EVENT && event_id == WIFI_EVENT_STA_START) {
        esp_wifi_connect();
    } else if (event_base == WIFI_EVENT && event_id == WIFI_EVENT_STA_DISCONNECTED) {
        if (s_retry_num < EXAMPLE_ESP_MAXIMUM_RETRY) {
            esp_wifi_connect();
            s_retry_num++;
            ESP_LOGI(TAG, "retry to connect to the AP");
        } else {
            xEventGroupSetBits(s_wifi_event_group, WIFI_FAIL_BIT);
        }
        ESP_LOGI(TAG,"connect to the AP fail");
        comms_state.got_signal = 0;
    } else if (event_base == IP_EVENT && event_id == IP_EVENT_STA_GOT_IP) {
        ip_event_got_ip_t* event = (ip_event_got_ip_t*) event_data;
        ESP_LOGI(TAG, "got ip:%s",
                 ip4addr_ntoa(&event->ip_info.ip));
        s_retry_num = 0;
        xEventGroupSetBits(s_wifi_event_group, WIFI_CONNECTED_BIT);
        comms_state.got_signal = 1;
    }

}

static void wifi_init_common()
{
    tcpip_adapter_init();
    ESP_ERROR_CHECK(esp_event_loop_create_default());

    wifi_init_config_t cfg = WIFI_INIT_CONFIG_DEFAULT();
    ESP_ERROR_CHECK(esp_wifi_init(&cfg));

    ESP_ERROR_CHECK(esp_event_handler_register(WIFI_EVENT, ESP_EVENT_ANY_ID, &wifi_event_handler, NULL));
    ESP_ERROR_CHECK(esp_event_handler_register(IP_EVENT, IP_EVENT_STA_GOT_IP, &wifi_event_handler, NULL));

}

static void wifi_init_sta()
{
    static const char * ssid = WIFI_STA_SSID;
    static const char * password = WIFI_STA_PASS;
    
    wifi_init_common();
    s_wifi_event_group = xEventGroupCreate();
    wifi_config_t wifi_config;
    memset(&wifi_config, 0, sizeof(wifi_config));
    strcpy((char *) wifi_config.sta.ssid, ssid);
    strcpy((char *) wifi_config.sta.password, password);
    
    ESP_ERROR_CHECK(esp_wifi_set_mode(WIFI_MODE_STA));
    ESP_ERROR_CHECK(esp_wifi_set_config(ESP_IF_WIFI_STA, &wifi_config));
    ESP_ERROR_CHECK(esp_wifi_start() );
    printf("wifi_init_sta finished\n");
}

#define SERVER_TAG "udp_server_task"
#define PORT 4200


static void maybe_send_telemetry(int sock, struct sockaddr_in *telem_receiver_addr)
{
    
}

static void udp_server_task(void *pvParameters)
{
    ESP_LOGI(SERVER_TAG, "Begin udp_server_task");
    int sock = socket(AF_INET, SOCK_DGRAM, 0);
    struct sockaddr_in bind_addr;
    bind_addr.sin_family = AF_INET;
    bind_addr.sin_addr.s_addr = htonl(INADDR_ANY);
    bind_addr.sin_port = htons(PORT);
    if (bind(sock, (struct sockaddr *) & bind_addr, sizeof(bind_addr)) != 0) {
        ESP_LOGE(SERVER_TAG, "Socket unable to bind: errno %d", errno);
    }
    
    struct timeval timeout_option = { tv_sec:0, tv_usec: 50000 };
    
    int res = setsockopt(sock, SOL_SOCKET, SO_RCVTIMEO, 
        &timeout_option, sizeof(timeout_option));
    
    if (res != 0) {
        ESP_LOGE(SERVER_TAG, "Failed setsockopt SO_RCVTIMEO %d", errno);
    }
    /*
     * Get packets, with regular timeouts. On timeout, send telemetry
     * packets.
     */
   
   
    struct sockaddr_in telem_receiver_addr;
    memset(&telem_receiver_addr, 0, sizeof(telem_receiver_addr));
    
    while (1) {
        uint8_t packet[200];
        ssize_t packetlen;
        struct sockaddr_in source_addr;
        source_addr.sin_family = AF_INET;
        socklen_t addrlen = sizeof(source_addr);
        int flags = 0;
        packetlen = recvfrom(sock, packet, sizeof(packet), flags,
            (struct sockaddr *) &source_addr, &addrlen);
        if (packetlen == -1) {
            // Is it a read timeout?
            if (errno == EWOULDBLOCK) {
                maybe_send_telemetry(sock, &telem_receiver_addr);
            }
        } else {
            // Ok
            // ESP_LOGI(SERVER_TAG, "Got packet length %d", packetlen);
            // ESP_LOGI(SERVER_TAG, "Got packet from %s", inet_ntoa(source_addr.sin_addr));
            if ((packetlen > 0) && (packetlen < sizeof(packet)) && (packet[0] != '#')) {
                if (packet[0] == '9') {
                    // Use this address for telemetry.
                    memcpy(&telem_receiver_addr, &source_addr, addrlen);
                }
            }
        }
    }
    vTaskDelete(NULL);
}   

void comms_init()
{
    comms_state.got_signal = 0;
//    wifi_init_softap();
    wifi_init_sta();
    xTaskCreate(udp_server_task, "udp_server", 4096, NULL, 5, NULL);
}
