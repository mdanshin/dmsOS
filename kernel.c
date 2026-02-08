// kernel.c - самый простой "kernel": печатает строку в VGA
#include <stdint.h>

static volatile uint16_t* const VGA = (uint16_t*)0xB8000;
static uint8_t row = 0, col = 0;
static uint8_t color = 0x0F; // white on black

static void putc(char c) {
    if (c == '\n') {
        col = 0;
        row++;
        return;
    }
    VGA[row * 80 + col] = (uint16_t)c | ((uint16_t)color << 8);
    col++;
    if (col >= 80) { col = 0; row++; }
}

static void puts(const char* s) {
    while (*s) putc(*s++);
}

void kernel_main(void) {
    // очистка экрана
    for (int r = 0; r < 25; r++) {
        for (int c = 0; c < 80; c++) {
            VGA[r * 80 + c] = (uint16_t)' ' | ((uint16_t)color << 8);
        }
    }
    row = 0; col = 0;

    puts("dmsOS kernel\n");
    puts("Hello from MY kernel!\n");

    for (;;) {
        __asm__ volatile ("hlt");
    }
}
