# Makefile
# Минимальная сборка BIOS/GRUB (Multiboot2).
# Рекомендуется кросс-компилятор i686-elf-*

CC ?= i686-elf-gcc
LD ?= i686-elf-ld
AS ?= as
GRUB_MKRESCUE ?= grub2-mkrescue

CFLAGS := -ffreestanding -m32
LDFLAGS := -T linker.ld -nostdlib -m elf_i386

ISO_DIR := iso
ISO := dmsOS.iso

all: $(ISO)

boot.o: boot.asm
	$(AS) --32 boot.asm -o boot.o

kernel.o: kernel.c
	$(CC) $(CFLAGS) -c kernel.c -o kernel.o

kernel.elf: boot.o kernel.o linker.ld
	$(LD) $(LDFLAGS) -o kernel.elf boot.o kernel.o

$(ISO): kernel.elf grub.cfg
	rm -rf $(ISO_DIR)
	mkdir -p $(ISO_DIR)/boot/grub
	cp kernel.elf $(ISO_DIR)/boot/kernel.elf
	cp grub.cfg $(ISO_DIR)/boot/grub/grub.cfg
	$(GRUB_MKRESCUE) -o $(ISO) $(ISO_DIR) >/dev/null

clean:
	rm -rf *.o *.elf $(ISO_DIR) $(ISO)

.PHONY: all clean
