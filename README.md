# dmsOS

Минимальный учебный "скелет ОС" для x86 (32-bit): загрузка через BIOS с CD-ROM ISO (El Torito) и вывод текста в VGA text mode (`0xB8000`). Без GRUB.

Построчная аннотация исходников: `ANNOTATED.md`.

## Как загружается

BIOS -> `boot_cd.asm` (16-bit) -> protected mode -> копирование `kernel.bin` на 1 MiB -> `_start` (kernel_entry.asm) -> `kernel_main` (kernel.c).

## Что в репозитории

- `boot_cd.asm` — микрозагрузчик (El Torito): включает A20, включает protected mode, копирует `kernel.bin` в `0x100000` и прыгает туда.
- `kernel_entry.asm` — вход ядра в 32-bit: ставит стек и вызывает `kernel_main`.
- `kernel.c` — минимальное ядро: пишет строку в VGA и делает `hlt`.
- `kernel.ld` — линкер-скрипт ядра (адрес 1 MiB).
- `Makefile` — сборка `dmsOS.iso` (через `xorriso -as mkisofs`).

Примечание: `boot.asm` написан под GNU `as` (GAS), несмотря на расширение `.asm`.

## Зависимости

Нужно установить:

- `make`
- `gcc`/`clang` + `as` + `ld` с поддержкой 32-bit (`-m32`, `elf_i386`)
- `xorriso`

Примеры пакетов:

- CentOS Stream 8 / RHEL 8: `sudo dnf install make gcc binutils xorriso`
- Fedora: `sudo dnf install make gcc binutils xorriso`
- Debian/Ubuntu: `sudo apt-get install make gcc binutils xorriso`

Если у вас нет кросс-компилятора `i686-elf-*`, можно собрать системным тулчейном (при условии, что `-m32` работает):

- `make CC=gcc LD=ld`

## Сборка

- Собрать ISO: `make` (результат: `dmsOS.iso`)
- Очистить артефакты: `make clean`

## Что должно получиться

При загрузке ISO появится текст:

- `dmsOS`
