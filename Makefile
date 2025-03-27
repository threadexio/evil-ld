CFLAGS ?= -DDEBUG
LFLAGS ?=
ASMFLAGS ?= 

evil-ld: entry.o main.o
	ld $^ -o $@ -static -m elf_i386 -z noexecstack $(LFLAGS)

entry.o: entry.s
	nasm $< -o $@ -f elf32 $(ASMFLAGS)

main.o: main.c
	cc -c $< -o $@ -m32 -Wall -Wextra $(CFLAGS)

clean:
	rm -f evil-ld entry.o main.o
