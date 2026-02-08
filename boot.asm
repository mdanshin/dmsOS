/* boot.asm - Multiboot v1 header + точка входа (GNU as) */

    /* Multiboot v1 header (must be within first 8 KiB) */
    .section .multiboot
    .align 4
    .long 0x1BADB002
    .long 0
    .long -(0x1BADB002 + 0)

    .section .text
    .code32
    .globl start
    .extern kernel_main

start:
    cli
    movl $stack_top, %esp
    call kernel_main

.hang:
    hlt
    jmp .hang

    .section .bss
    .align 16
stack_bottom:
    .skip 16384
stack_top:
