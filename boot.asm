/* boot.asm - Multiboot2 header + точка входа (GNU as) */

    .section .multiboot_header
    .align 8
mb2_header_start:
    .long 0xE85250D6
    .long 0
    .long mb2_header_end - mb2_header_start
    .long -(0xE85250D6 + 0 + (mb2_header_end - mb2_header_start))

    /* End tag */
    .word 0
    .word 0
    .long 8
mb2_header_end:

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
