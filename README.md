# dmsOS

Минимальный учебный "скелет ОС" для x86 (32-bit): загрузка через BIOS + GRUB (Multiboot v1) и вывод текста в VGA text mode (`0xB8000`).

Построчная аннотация исходников: `ANNOTATED.md`.

## Как загружается

BIOS -> GRUB -> Multiboot -> `start` (boot.asm) -> `kernel_main` (kernel.c).

## Что в репозитории

- `boot.asm` — заголовок Multiboot v1 + точка входа `start`: ставит стек и вызывает `kernel_main`.
- `kernel.c` — минимальное ядро: чистит экран и печатает несколько строк.
- `linker.ld` — линкер-скрипт: кладет заголовок Multiboot v1 в начало и линкует образ на 1 MiB.
- `grub.cfg` — конфиг GRUB для загрузки `kernel.elf`.
- `Makefile` — сборка `kernel.elf` и упаковка в `dmsOS.iso`.

Примечание: `boot.asm` написан под GNU `as` (GAS), несмотря на расширение `.asm`.

## Зависимости

Нужно установить:

- `make`
- `gcc`/`clang` + `as` + `ld` с поддержкой 32-bit (`-m32`, `elf_i386`)
- `grub-mkrescue` или `grub2-mkrescue`
- `xorriso` (нужен `grub-mkrescue`)

Примеры пакетов:

- CentOS Stream 8 / RHEL 8: `sudo dnf install make gcc binutils grub2-tools xorriso`
- Fedora: `sudo dnf install make gcc binutils grub2-tools xorriso`
- Debian/Ubuntu: `sudo apt-get install make gcc binutils grub-pc-bin xorriso`

Если у вас нет кросс-компилятора `i686-elf-*`, можно собрать системным тулчейном (при условии, что `-m32` работает):

- `make CC=gcc LD=ld`

## Сборка

- Собрать ISO: `make` (результат: `dmsOS.iso`)
- Очистить артефакты: `make clean`

## Что должно получиться

При загрузке ISO появится текст вроде:

- `dmsOS kernel`
- `Hello from MY kernel!`
