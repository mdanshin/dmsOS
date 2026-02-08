/* boot_cd.asm - El Torito no-emulation boot image
 * Loads kernel from the boot image itself (no filesystem parsing).
 * BIOS loads this image to 0x7C00 and jumps there.
 */

    .section .text
    .code16
    .globl start

start:
    cli
    xorw %ax, %ax
    movw %ax, %ds
    movw %ax, %es
    movw %ax, %ss
    movw $0x7C00, %sp

    /* Enable A20 (fast A20 via port 0x92) */
    inb $0x92, %al
    orb $0x02, %al
    outb %al, $0x92

    lgdt gdt_desc

    movl %cr0, %eax
    orl $0x1, %eax
    movl %eax, %cr0

    ljmp $0x08, $pm_start

    .code32
pm_start:
    movw $0x10, %ax
    movw %ax, %ds
    movw %ax, %es
    movw %ax, %ss
    movw %ax, %fs
    movw %ax, %gs

    movl $0x90000, %esp

    cld
    movl $kernel_payload, %esi
    movl $0x100000, %edi
    movl $(kernel_payload_end - kernel_payload), %ecx
    rep movsb

    jmp 0x100000

    .align 8
gdt:
    .quad 0x0000000000000000
    .quad 0x00CF9A000000FFFF
    .quad 0x00CF92000000FFFF

gdt_desc:
    .word (gdt_end - gdt) - 1
    .long gdt
gdt_end:

    .align 16
kernel_payload:
    .incbin "kernel.bin"
kernel_payload_end:

    /* Pad boot image to 16 KiB (32 * 512). If kernel grows, increase. */
    .align 1
pad_start:
    .fill (16384 - (pad_start - start)), 1, 0
