/* kernel_entry.asm - 32-bit kernel entry */

    .section .text
    .code32
    .globl _start
    .extern kernel_main

_start:
    cli
    movl $0x200000, %esp
    call kernel_main

.hang:
    hlt
    jmp .hang
