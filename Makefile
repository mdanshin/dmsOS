# Makefile
# Micro bootloader -> kernel (no GRUB). Goal: minimal ISO size.

CC ?= cc
LD ?= ld
AS ?= as
OBJCOPY ?= objcopy
XORRISO ?= xorriso

CFLAGS := -ffreestanding -m32
LDFLAGS := -nostdlib -m elf_i386

ISO_ROOT := iso_root
ISO := dmsOS.iso

all: $(ISO)

kernel_entry.o: kernel_entry.asm
	$(AS) --32 kernel_entry.asm -o kernel_entry.o

kernel.o: kernel.c
	$(CC) $(CFLAGS) -c kernel.c -o kernel.o

kernel.elf: kernel_entry.o kernel.o kernel.ld
	$(LD) $(LDFLAGS) -T kernel.ld -o kernel.elf kernel_entry.o kernel.o

kernel.bin: kernel.elf
	$(OBJCOPY) -O binary kernel.elf kernel.bin

boot.img: boot_cd.asm kernel.bin
	$(AS) --32 boot_cd.asm -o boot_cd.o
	$(LD) -m elf_i386 -Ttext 0x7C00 -e start --oformat binary -o boot.img boot_cd.o

$(ISO): boot.img
	rm -rf $(ISO_ROOT)
	mkdir -p $(ISO_ROOT)
	cp boot.img $(ISO_ROOT)/boot.img
	$(XORRISO) -as mkisofs -o $(ISO) -b boot.img -no-emul-boot -boot-load-size 32 -c boot.cat $(ISO_ROOT) >/dev/null

clean:
	rm -rf *.o *.elf *.bin boot.img $(ISO_ROOT) $(ISO)

.PHONY: all clean
