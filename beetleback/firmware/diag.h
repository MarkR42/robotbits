#include <stdint.h>

void diag_putc(unsigned char c);
void diag_puts(const char *s);
void diag_puts_progmem(const char *s);
void diag_printhex_8(uint8_t n);
void diag_printhex_16(uint16_t n);
void diag_newline();

void diag_init();
