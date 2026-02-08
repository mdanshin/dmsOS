# dmsOS: построчная аннотация

Этот файл объясняет каждую строку исходников и конфигов проекта. Код остается минимальным, а подробные пояснения лежат рядом.

Формат:

- `имя_файла:номер_строки` `исходная_строка` — что делает строка и почему она нужна.

Примечание про Makefile: строки команд в правилах должны начинаться с символа TAB; в цитатах ниже я показываю TAB как `\t`.

---

## `boot.asm`

- `boot.asm:1` `/* boot.asm - Multiboot v1 header + точка входа (GNU as) */` — комментарий: файл содержит Multiboot v1 заголовок и входную точку; синтаксис GNU `as` (GAS).
- `boot.asm:2` *(пустая строка)* — визуальный разделитель.
- `boot.asm:3` `/* Multiboot v1 header (must be within first 8 KiB) */` — комментарий: заголовок v1 должен лежать в первых 8 KiB образа.
- `boot.asm:4` `.section .multiboot` — секция с заголовком Multiboot v1.
- `boot.asm:5` `.align 4` — выравнивание на 4 байта (требование заголовка v1).
- `boot.asm:6` `.long 0x1BADB002` — magic Multiboot v1.
- `boot.asm:7` `.long 0` — flags: минимальный вариант без дополнительных требований.
- `boot.asm:8` `.long -(0x1BADB002 + 0)` — checksum: magic + flags + checksum = 0.
- `boot.asm:9` *(пустая строка)* — разделитель.
- `boot.asm:10` `.section .text` — секция исполняемого кода.
- `boot.asm:11` `.code32` — 32-битные инструкции.
- `boot.asm:12` `.globl start` — экспортируем символ `start` (entrypoint в ELF).
- `boot.asm:13` `.extern kernel_main` — объявляем внешний символ (функция в `kernel.c`).
- `boot.asm:14` *(пустая строка)* — разделитель.
- `boot.asm:15` `start:` — точка входа ядра.
- `boot.asm:16` `cli` — выключаем маскируемые прерывания.
- `boot.asm:17` `movl $stack_top, %esp` — ставим стек.
- `boot.asm:18` `call kernel_main` — переходим в C-код.
- `boot.asm:19` *(пустая строка)* — разделитель.
- `boot.asm:20` `.hang:` — бесконечный цикл.
- `boot.asm:21` `hlt` — останавливаем CPU.
- `boot.asm:22` `jmp .hang` — зацикливаемся.
- `boot.asm:23` *(пустая строка)* — разделитель.
- `boot.asm:24` `.section .bss` — секция неинициализированных данных.
- `boot.asm:25` `.align 16` — выравнивание стека.
- `boot.asm:26` `stack_bottom:` — нижняя граница стека.
- `boot.asm:27` `.skip 16384` — резервируем 16 KiB под стек.
- `boot.asm:28` `stack_top:` — верхняя граница стека.
- `boot.asm:29` *(пустая строка)* — финальная пустая строка.

---

## `kernel.c`

- `kernel.c:1` `// kernel.c - самый простой "kernel": печатает строку в VGA` — комментарий: минимальное ядро, вывод напрямую в VGA text buffer.
- `kernel.c:2` `#include <stdint.h>` — фиксированные целочисленные типы.
- `kernel.c:3` *(пустая строка)* — разделитель.
- `kernel.c:4` `static volatile uint16_t* const VGA = (uint16_t*)0xB8000;` — указатель на VGA-память; `volatile` не дает оптимизатору выкидывать записи.
- `kernel.c:5` `static uint8_t row = 0, col = 0;` — позиция "курсора" (80x25).
- `kernel.c:6` `static uint8_t color = 0x0F; // white on black` — атрибут VGA: белый текст на черном фоне.
- `kernel.c:7` *(пустая строка)* — разделитель.
- `kernel.c:8` `static void putc(char c) {` — печать одного символа.
- `kernel.c:9` `    if (c == '\n') {` — специальная обработка перевода строки.
- `kernel.c:10` `        col = 0;` — новая строка начинается с колонки 0.
- `kernel.c:11` `        row++;` — переходим на следующую строку.
- `kernel.c:12` `        return;` — не пишем `\n` в видеопамять.
- `kernel.c:13` `    }` — конец ветки `if`.
- `kernel.c:14` `    VGA[row * 80 + col] = (uint16_t)c | ((uint16_t)color << 8);` — запись символа + атрибут (цвет в старшем байте).
- `kernel.c:15` `    col++;` — сдвиг курсора.
- `kernel.c:16` `    if (col >= 80) { col = 0; row++; }` — перенос строки при достижении края.
- `kernel.c:17` `}` — конец `putc`.
- `kernel.c:18` *(пустая строка)* — разделитель.
- `kernel.c:19` `static void puts(const char* s) {` — печать C-строки.
- `kernel.c:20` `    while (*s) putc(*s++);` — печатаем символы до `\0`.
- `kernel.c:21` `}` — конец `puts`.
- `kernel.c:22` *(пустая строка)* — разделитель.
- `kernel.c:23` `void kernel_main(void) {` — вход в ядро; вызывается из `boot.asm`.
- `kernel.c:24` `    // очистка экрана` — комментарий: дальше заполняем экран пробелами.
- `kernel.c:25` `    for (int r = 0; r < 25; r++) {` — цикл по строкам.
- `kernel.c:26` `        for (int c = 0; c < 80; c++) {` — цикл по колонкам.
- `kernel.c:27` `            VGA[r * 80 + c] = (uint16_t)' ' | ((uint16_t)color << 8);` — очищаем ячейку: пробел + текущий цвет.
- `kernel.c:28` `        }` — конец внутреннего цикла.
- `kernel.c:29` `    }` — конец внешнего цикла.
- `kernel.c:30` `    row = 0; col = 0;` — сбрасываем позицию курсора.
- `kernel.c:31` *(пустая строка)* — разделитель.
- `kernel.c:32` `    puts("dmsOS kernel\n");` — тестовый вывод: подтверждает, что ядро запущено.
- `kernel.c:33` `    puts("Hello from MY kernel!\n");` — вторая строка вывода.
- `kernel.c:34` *(пустая строка)* — разделитель.
- `kernel.c:35` `    for (;;) {` — ядро не возвращается; бесконечный цикл.
- `kernel.c:36` `        __asm__ volatile ("hlt");` — `hlt` останавливает CPU (в этом минимальном ядре просто "спим").
- `kernel.c:37` `    }` — конец цикла.
- `kernel.c:38` `}` — конец `kernel_main`.
- `kernel.c:39` *(пустая строка)* — финальная пустая строка.

---

## `linker.ld`

- `linker.ld:1` `/* linker.ld */` — комментарий: скрипт GNU `ld`.
- `linker.ld:2` `ENTRY(start)` — entrypoint ELF: символ `start`.
- `linker.ld:3` *(пустая строка)* — разделитель.
- `linker.ld:4` `SECTIONS` — блок раскладки секций.
- `linker.ld:5` `{` — начало блока.
- `linker.ld:6` `. = 1M;` — базовый адрес размещения образа: 1 MiB.
- `linker.ld:7` *(пустая строка)* — разделитель.
- `linker.ld:8` `.text : ALIGN(4K) {` — секция кода, выравнивание по странице.
- `linker.ld:9` `*(.multiboot)` — кладем заголовок Multiboot v1 в начало образа.
- `linker.ld:10` `*(.text*)` — весь код из входных `.text*` секций.
- `linker.ld:11` `}` — конец `.text`.
- `linker.ld:12` *(пустая строка)* — разделитель.
- `linker.ld:13` `.rodata : ALIGN(4K) { *(.rodata*) }` — константные данные.
- `linker.ld:14` `.data   : ALIGN(4K) { *(.data*) }` — инициализированные данные.
- `linker.ld:15` `.bss    : ALIGN(4K) { *(COMMON) *(.bss*) }` — неинициализированные данные.
- `linker.ld:16` `}` — конец `SECTIONS`.
- `linker.ld:17` *(пустая строка)* — финальная пустая строка.

---

## `grub.cfg`

- `grub.cfg:1` `set timeout=0` — автозагрузка без ожидания меню.
- `grub.cfg:2` `set default=0` — пункт меню по умолчанию.
- `grub.cfg:3` *(пустая строка)* — разделитель.
- `grub.cfg:4` `menuentry "dmsOS" {` — один пункт меню.
- `grub.cfg:5` `multiboot /boot/kernel.elf` — загружаем ядро по протоколу Multiboot v1.
- `grub.cfg:6` `boot` — старт загрузки.
- `grub.cfg:7` `}` — конец `menuentry`.
- `grub.cfg:8` *(пустая строка)* — финальная пустая строка.

---

## `Makefile`

- `Makefile:1` `# Makefile` — комментарий: файл правил сборки.
- `Makefile:2` `# Минимальная сборка BIOS/GRUB (Multiboot v1).` — комментарий: схема загрузки и протокол.
- `Makefile:3` `# Рекомендуется кросс-компилятор i686-elf-*` — комментарий: для freestanding ядра лучше кросс-toolchain.
- `Makefile:4` *(пустая строка)* — разделитель.
- `Makefile:5` `CC ?= i686-elf-gcc` — компилятор C (можно переопределить: `make CC=gcc`).
- `Makefile:6` `LD ?= i686-elf-ld` — линкер.
- `Makefile:7` `AS ?= as` — ассемблер.
- `Makefile:8` `GRUB_MKRESCUE ?= grub2-mkrescue` — утилита создания ISO (на некоторых системах может называться `grub-mkrescue`).
- `Makefile:9` *(пустая строка)* — разделитель.
- `Makefile:10` `CFLAGS := -ffreestanding -m32` — минимальные флаги компиляции: freestanding (без зависимости от glibc) и 32-bit код.
- `Makefile:11` `LDFLAGS := -T linker.ld -nostdlib -m elf_i386` — флаги линковки: свой скрипт + без libc + 32-bit ELF.
- `Makefile:12` *(пустая строка)* — разделитель.
- `Makefile:13` `ISO_DIR := iso` — staging-директория, из которой собирается ISO.
- `Makefile:14` `ISO := dmsOS.iso` — имя выходного ISO.
- `Makefile:15` *(пустая строка)* — разделитель.
- `Makefile:16` `all: $(ISO)` — цель по умолчанию.
- `Makefile:17` *(пустая строка)* — разделитель.
- `Makefile:18` `boot.o: boot.asm` — сборка объектника стартового кода.
- `Makefile:19` `\t$(AS) --32 boot.asm -o boot.o` — команда (TAB): собрать `boot.o` из `boot.asm`.
- `Makefile:20` *(пустая строка)* — разделитель.
- `Makefile:21` `kernel.o: kernel.c` — сборка объектника C-кода.
- `Makefile:22` `\t$(CC) $(CFLAGS) -c kernel.c -o kernel.o` — команда (TAB): компилируем `kernel.c`.
- `Makefile:23` *(пустая строка)* — разделитель.
- `Makefile:24` `kernel.elf: boot.o kernel.o linker.ld` — линковка ELF-ядра.
- `Makefile:25` `\t$(LD) $(LDFLAGS) -o kernel.elf boot.o kernel.o` — команда (TAB): получаем `kernel.elf`.
- `Makefile:26` *(пустая строка)* — разделитель.
- `Makefile:27` `$(ISO): kernel.elf grub.cfg` — ISO зависит от ядра и конфигурации GRUB.
- `Makefile:28` `\trm -rf $(ISO_DIR)` — команда (TAB): пересоздаем staging-директорию.
- `Makefile:29` `\tmkdir -p $(ISO_DIR)/boot/grub` — команда (TAB): создаем структуру каталогов GRUB.
- `Makefile:30` `\tcp kernel.elf $(ISO_DIR)/boot/kernel.elf` — команда (TAB): кладем ядро в ISO.
- `Makefile:31` `\tcp grub.cfg $(ISO_DIR)/boot/grub/grub.cfg` — команда (TAB): кладем `grub.cfg`.
- `Makefile:32` `\t$(GRUB_MKRESCUE) -o $(ISO) $(ISO_DIR) >/dev/null` — команда (TAB): собираем ISO.
- `Makefile:33` *(пустая строка)* — разделитель.
- `Makefile:34` `clean:` — цель очистки.
- `Makefile:35` `\trm -rf *.o *.elf $(ISO_DIR) $(ISO)` — команда (TAB): удаляем артефакты.
- `Makefile:36` *(пустая строка)* — разделитель.
- `Makefile:37` `.PHONY: all clean` — помечаем цели как "не файлы".
- `Makefile:38` *(пустая строка)* — финальная пустая строка.

---

## `.gitignore`

- `.gitignore:1` `# Build artifacts` — комментарий: артефакты сборки.
- `.gitignore:2` `*.o` — объектные файлы.
- `.gitignore:3` `*.elf` — ELF-образы.
- `.gitignore:4` `*.bin` — бинарные файлы.
- `.gitignore:5` `*.img` — образы дисков.
- `.gitignore:6` `*.iso` — ISO-образы.
- `.gitignore:7` *(пустая строка)* — разделитель.
- `.gitignore:8` `# Build directories` — комментарий: директории сборки.
- `.gitignore:9` `iso/` — staging-директория ISO.
- `.gitignore:10` `build/` — вспомогательные/временные файлы (если появляются).
- `.gitignore:11` *(пустая строка)* — разделитель.
- `.gitignore:12` `# Editor/OS noise` — комментарий: мусор от редакторов/ОС.
- `.gitignore:13` `*~` — резервные файлы.
- `.gitignore:14` `*.swp` — swap vim.
- `.gitignore:15` `*.swo` — swap vim.
- `.gitignore:16` `.DS_Store` — файл macOS.
- `.gitignore:17` *(пустая строка)* — финальная пустая строка.
