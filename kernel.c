// kernel.c - minimal 32-bit kernel, VGA hello
#include <stdint.h>

static void vga_puts(const char* s) {
    volatile uint16_t* vga = (uint16_t*)0xB8000;
    uint16_t color = 0x0F00; // white on black
    int i = 0;

    while (s[i]) {
        vga[i] = (uint16_t)s[i] | color;
        i++;
    }
}

void kernel_main(void) {
    vga_puts("dmsOS\n");
    for (;;) {
        __asm__ volatile ("hlt");
    }
}
