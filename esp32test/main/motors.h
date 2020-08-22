#include <stdint.h>

void motors_init();

// Motor is either 0 or 1
// Speed is in range -1000..1000 
// This function sends the command immediately then returns.
void motor_set_speed_signed(uint8_t motor, int speed_signed); 

void motor_send_dshot_command(uint8_t motor, int cmd); 
