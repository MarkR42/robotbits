#include "timer.h"

#include "diag.h"

#include <avr/pgmspace.h>

static uint32_t timer_overflow_count;
static uint8_t timer_last_value;

void timer_init()
{
    diag_puts_progmem(PSTR("timer_init"));
    diag_newline();
    
    // The timer has no specific enable flag and it just runs all
    // the time. There are a few settings:
    // Set prescaler = 64
    // Prescaler = 9.6 / 64 = 6.66 microseconds period per clock

    // TCCR0B bottom 3 bits = Clock select. Value 011 = divide 64
    TCCR0B = 0x03;
    // Reset the prescaler:
    GTCCR = 0x1; // This bit auto-clears.
    // Reset the timer tick
    GTCCR = 0x80; // Enable TSM: Timer/counter sync - halt timer.
    TCNT0 = 0;
    GTCCR = 0; // Disable TSM: Start timer.
}

/*
 * Returns the number of ticks since start.
 * Needs to be called at least once per timer overflow otherwise we
 * will miss overflows.
 */
uint32_t timer_read()
{
    // Check for overflow?
    uint8_t timer_current = TCNT0;
    if (timer_current < timer_last_value) {
        // Overflow.
        timer_overflow_count += 1;
    }
    timer_last_value = timer_current;
    return (timer_overflow_count * 256) + timer_current;
}

void timer_wait(uint32_t ticks)
{
    uint32_t start = timer_read();
    uint32_t end = start + ticks;
    while (timer_read() < end) {
        
    }
}

