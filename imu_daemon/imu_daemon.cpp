#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdint.h>
#include <stddef.h>
#include <string.h>
#include <math.h>
#include <fcntl.h>
#include <poll.h>
#include <assert.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <sys/un.h>
#include <time.h>
#include "I2Cdev.h"
#include "MPU6050_6Axis_MotionApps20.h"

// class default I2C address is 0x68
// specific I2C addresses may be passed as a parameter here
// AD0 low = 0x68 (default for SparkFun breakout and InvenSense evaluation board)
// AD0 high = 0x69
MPU6050 mpu;

// uncomment "OUTPUT_READABLE_QUATERNION" if you want to see the actual
// quaternion components in a [w, x, y, z] format (not best for parsing
// on a remote host such as Processing or something though)
// #define OUTPUT_READABLE_QUATERNION

// uncomment "OUTPUT_READABLE_EULER" if you want to see Euler angles
// (in degrees) calculated from the quaternions coming from the FIFO.
// Note that Euler angles suffer from gimbal lock (for more info, see
// http://en.wikipedia.org/wiki/Gimbal_lock)
//#define OUTPUT_READABLE_EULER

// uncomment "OUTPUT_READABLE_YAWPITCHROLL" if you want to see the yaw/
// pitch/roll angles (in degrees) calculated from the quaternions coming
// from the FIFO. Note this also requires gravity vector calculations.
// Also note that yaw/pitch/roll angles suffer from gimbal lock (for
// more info, see: http://en.wikipedia.org/wiki/Gimbal_lock)
#define OUTPUT_READABLE_YAWPITCHROLL

// uncomment "OUTPUT_READABLE_REALACCEL" if you want to see acceleration
// components with gravity removed. This acceleration reference frame is
// not compensated for orientation, so +X is always +X according to the
// sensor, just without the effects of gravity. If you want acceleration
// compensated for orientation, us OUTPUT_READABLE_WORLDACCEL instead.
#define OUTPUT_READABLE_REALACCEL

// uncomment "OUTPUT_READABLE_WORLDACCEL" if you want to see acceleration
// components with gravity removed and adjusted for the world frame of
// reference (yaw is relative to initial orientation, since no magnetometer
// is present in this case). Could be quite handy in some cases.
// #define OUTPUT_READABLE_WORLDACCEL

// MPU control/status vars
bool dmpReady = false;  // set true if DMP init was successful
uint8_t mpuIntStatus;   // holds actual interrupt status byte from MPU
uint8_t devStatus;      // return status after each device operation (0 = success, !0 = error)
uint16_t packetSize;    // expected DMP packet size (default is 42 bytes)
uint16_t fifoCount;     // count of all bytes currently in FIFO
uint8_t fifoBuffer[64]; // FIFO storage buffer

// orientation/motion vars
Quaternion q;           // [w, x, y, z]         quaternion container
VectorInt16 aa;         // [x, y, z]            accel sensor measurements
VectorInt16 aaReal;     // [x, y, z]            gravity-free accel sensor measurements
VectorInt16 aaLast;     // [x, y, z]        last tick's aaReal
VectorInt16 aaWorld;    // [x, y, z]            world-frame accel sensor measurements
VectorFloat gravity;    // [x, y, z]            gravity vector
float euler[3];         // [psi, theta, phi]    Euler angle container
float ypr[3];           // [yaw, pitch, roll]   yaw/pitch/roll container and gravity vector

int gpio_fd = -1;
int loopcount = 0; // Counts since last data
static bool need_init = true;
int ipc_socket = -1;
int sensor_values_count = 0; // Number of sensor readings since startup
int time_last = 0; // ms last reading
int motion_last_time = 0; // time of last motion
int motion_time_last = 0;
int high_jerk_count = 0; // number of ticks jerk is too high

const float JERK_THRESHOLD = 1.5;
const int MOTION_TIME_THRESHOLD = 200; // millisecs

const int HIGH_JERK_THRESHOLD = 500;
// ================================================================
// ===                      INITIAL SETUP                       ===
// ================================================================

// Give the time in milliseconds
static int get_time_ms()
{
    struct timespec ts;
    int res = clock_gettime(CLOCK_MONOTONIC, &ts);
    assert(res == 0);
    return (ts.tv_sec * 1000) + (ts.tv_nsec / 1000000);
}

void check_fd(int fd, const char *reason)
{
    if (fd == -1) {
        perror(reason);
        abort();
    }
}

static int init_socket() 
{
    int s = socket(AF_UNIX, SOCK_DGRAM,0);
    check_fd(s, "socket");
    return s;
}

static void write_json_field(char * buf, const char * fname, float val)
{
    char fbuf[1024];
    if (strlen(buf) > 5) {
        strcat(buf, ", ");
    }
    sprintf(fbuf, "\"%s\": %.2f", fname, val);
    strcat(buf, fbuf);
}

// For boolean
static void write_json_bool(char * buf, const char * fname, bool val)
{
    char fbuf[1024];
    if (strlen(buf) > 5) {
        strcat(buf, ", ");
    }
    sprintf(fbuf, "\"%s\": %s", fname, val ? "true" : "false");
    strcat(buf, fbuf);
}


static void send_json_packet(
    float yaw, float pitch, float roll, 
    float ax, float ay, float az, 
    float jerk, bool motion_flag,
    int time_now)
{
    // build json packet, send via unix datagram
    char buf[2048];
    const char * prefix = "{ ";
    const char * suffix = " }";
    strncpy(buf, prefix, sizeof(buf));
    // Write fields
    write_json_field(buf, "yaw", yaw);
    write_json_field(buf, "pitch", pitch);
    write_json_field(buf, "roll", roll);
    write_json_field(buf, "ax", ax);
    write_json_field(buf, "ay", ay);
    write_json_field(buf, "az", az);
    write_json_field(buf, "jerk", jerk);
    write_json_bool(buf, "motion", motion_flag);
    write_json_field(buf, "time", time_now);
    // Write suffix
    strncat(buf, suffix, sizeof(buf));
    size_t packet_len = strlen(buf);
    assert(packet_len > 0);
    // Send the packet to some endpoints
    int successes = 0;
    for (int i=0; i<5; i++) {
        struct sockaddr_un dest;
        memset(&dest, 0, sizeof(dest));
        dest.sun_family = AF_UNIX;
        // Write string to 2nd byte position of sun_path,
        // so we have a zero in the 1st byte.
        int pathlen = sprintf(dest.sun_path + 1, "robot.IMU%d", i);
        // The remaining part of the path should be all zeros
        // Calculate the exact length of the sun_addr which we want.
        size_t addrlen = offsetof(struct sockaddr_un, sun_path) + pathlen + 1;
        // Send it
        int res = sendto(ipc_socket, buf, packet_len, 
            0, // flags
            (struct sockaddr *) &dest, addrlen);
        // Do we care about res? only slightly.
        if (res == 0) successes += 1;
    }
    // Additionally write to stdout, only if there is motion.
    if (motion_flag) puts(buf);
}

static void init_mpu() {
    // initialize device
    printf("Resetting MPU\n");
    mpu.reset();
    printf("Initializing I2C devices...\n");
    mpu.initialize();

    // verify connection
    printf("Testing device connections...\n");
    bool ok = mpu.testConnection();
    printf(ok ? "MPU6050 connection successful\n" : "MPU6050 connection failed\n");
    if (! ok) {
        abort();
    }

    // load and configure the DMP
    printf("Initializing DMP...\n");
    devStatus = mpu.dmpInitialize();
    
    // make sure it worked (returns 0 if so)
    if (devStatus == 0) {

        // enable interrupt detection
        printf("Interrupt mode=%d\n", mpu.getInterruptMode());
        printf("Interrupt drive=%d\n", mpu.getInterruptDrive());
        printf("getFSyncInterruptEnabled=%d\n", mpu.getFSyncInterruptEnabled());
        printf("getClockOutputEnabled=%d\n", mpu.getClockOutputEnabled());
        mpu.setIntEnabled(0); // clear all int enabled flags
        // mpu.setInterruptLatch(1);
        // mpu.setIntEnabled(1);
        // mpu.setIntDataReadyEnabled(1);
        mpu.setIntDMPEnabled(1);
        // mpu.setIntPLLReadyEnabled(1); // Some interrupt from the dmp?
        mpuIntStatus = mpu.getIntStatus(); // Clear existing status.
        // turn on the DMP, now that it's ready
        printf("Enabling DMP...\n");
        mpu.setDMPEnabled(true);
        printf("Setting the motion detected thresh, i dont know why\n");
        mpu.setMotionDetectionThreshold(64);

        // set our DMP Ready flag so the main loop() function knows it's okay to use it
        printf("DMP ready!\n");
        dmpReady = true;

        // get expected DMP packet size for later comparison
        packetSize = mpu.dmpGetFIFOPacketSize();
    } else {
        // ERROR!
        // 1 = initial memory load failed
        // 2 = DMP configuration updates failed
        // (if it's going to break, usually the code will be 1)
        printf("DMP Initialization failed (code %d)\n", devStatus);
        abort();
    }
    if (ipc_socket == -1) {
        ipc_socket = init_socket();
    }
    need_init = false;
    usleep(100000);
}


// ================================================================
// ===                    MAIN PROGRAM LOOP                     ===
// ================================================================

void loop() {
    if (need_init) {
        init_mpu();
    }
    
    loopcount += 1;
    // if programming failed, don't try to do anything
    if (!dmpReady) return;
    // get current FIFO count
    fifoCount = mpu.getFIFOCount();

    // printf("fifoCount=%d\n", fifoCount);
    if (fifoCount == 1024) {
        // reset so we can continue cleanly
        mpu.resetFIFO();
        printf("FIFO overflow!\n");

    // otherwise, check for DMP data ready interrupt (this should happen frequently)
    } else if (fifoCount >= 42) {
        // read a packet from FIFO
        mpu.getFIFOBytes(fifoBuffer, packetSize);
        int time_now = get_time_ms();
        int time_since_last = time_now - time_last;
        float jerk = 0;
        
        #ifdef OUTPUT_READABLE_QUATERNION
            // display quaternion values in easy matrix form: w x y z
            mpu.dmpGetQuaternion(&q, fifoBuffer);
            printf("quat %7.2f %7.2f %7.2f %7.2f    ", q.w,q.x,q.y,q.z);
        #endif

        #ifdef OUTPUT_READABLE_EULER
            // display Euler angles in degrees
            mpu.dmpGetQuaternion(&q, fifoBuffer);
            mpu.dmpGetEuler(euler, &q);
            printf("euler %7.2f %7.2f %7.2f    ", euler[0] * 180/M_PI, euler[1] * 180/M_PI, euler[2] * 180/M_PI);
        #endif

        #ifdef OUTPUT_READABLE_YAWPITCHROLL
            // display Euler angles in degrees
            mpu.dmpGetQuaternion(&q, fifoBuffer);
            mpu.dmpGetGravity(&gravity, &q);
            mpu.dmpGetYawPitchRoll(ypr, &q, &gravity);
            // printf("ypr  %7.2f %7.2f %7.2f    ", ypr[0] * 180/M_PI, ypr[1] * 180/M_PI, ypr[2] * 180/M_PI);
        #endif

        #ifdef OUTPUT_READABLE_REALACCEL
            // display real acceleration, adjusted to remove gravity
            mpu.dmpGetQuaternion(&q, fifoBuffer);
            mpu.dmpGetAccel(&aa, fifoBuffer);
            mpu.dmpGetGravity(&gravity, &q);
            mpu.dmpGetLinearAccel(&aaReal, &aa, &gravity);
            // printf("areal %6d %6d %6d    ", aaReal.x, aaReal.y, aaReal.z);
        // calculate jerk
        {
            VectorInt16 diff;
            diff.x = aaReal.x - aaLast.x;
            diff.y = aaReal.y - aaLast.y;
            diff.z = aaReal.z - aaLast.z;
            jerk = diff.getMagnitude() / (time_since_last);
            // Jerk should be in accelerator per millisecond.
            // printf("jerk %.1f ", jerk);
            aaLast = aaReal;
            // Calculate if there is motion;
            // If jerk is low enough, no motion
            bool motion_now = (jerk > JERK_THRESHOLD);
            if (motion_now) {   
                motion_last_time = time_now;
            }
            if (jerk > HIGH_JERK_THRESHOLD) {
                // Very jerky, this is unusual, or the MPU may be giving 
                // crazy bad data.
                high_jerk_count += 1;
                if (high_jerk_count > 3) {
                    printf("MPU GONE CRAZY\n");
                    need_init = true;
                    high_jerk_count = 0;
                }
            } else {
                high_jerk_count = 0;
            }
        }
        #endif

        #ifdef OUTPUT_READABLE_WORLDACCEL
            // display initial world-frame acceleration, adjusted to remove gravity
            // and rotated based on known orientation from quaternion
            mpu.dmpGetQuaternion(&q, fifoBuffer);
            mpu.dmpGetAccel(&aa, fifoBuffer);
            mpu.dmpGetGravity(&gravity, &q);
            mpu.dmpGetLinearAccelInWorld(&aaWorld, &aaReal, &q);
            // printf("aworld %6d %6d %6d    ", aaWorld.x, aaWorld.y, aaWorld.z);
        #endif
   
        bool motion_flag  = (motion_last_time >= (time_now - MOTION_TIME_THRESHOLD));
        // printf("t=%d\n", time_now);
        // Here call the function to write to the socket.
        float effective_yaw = ypr[0] * 180 / M_PI;
        if (aaReal.z < 0) {
            // If the IMU is installed upside down, invert yaw
            effective_yaw = - effective_yaw;
        }
        send_json_packet(
            // Yaw, Pitch, Roll
            effective_yaw, ypr[1] * 180/M_PI, ypr[2] * 180/M_PI,
            // Acceleration
            aaReal.x, aaReal.y, aaReal.z,
            // Jerk
            jerk, motion_flag,
            time_now);
        
        loopcount = 0;
        sensor_values_count += 1;
        time_last = time_now;
        // Got it , sleep for about 1/40 second
        usleep(25 * 1000);
    } else {
        // FIFO not ready.
        mpuIntStatus = mpu.getIntStatus(); // Clear interrupt status.
    }
}

int main() {
    for (;;)
        loop();

    return 0;
}

