CFLAGS ?=
LFLAGS ?=
ASMFLAGS ?=

DEBUG ?= 1
ifeq ($(DEBUG),1)
CFLAGS += -DDEBUG
endif

REAL_LD ?=
ifneq ($(REAL_LD),)
CFLAGS += -DREAL_LD=\"$(REAL_LD)\"
endif

DISABLE_ASLR ?= 1
ifeq ($(DISABLE_ASLR),1)
CFLAGS += -DDISABLE_ASLR
endif

evil-ld: entry.o main.o
	ld $^ -o $@ -static -m elf_i386 -z noexecstack $(LFLAGS)

entry.o: entry.s
	nasm $< -o $@ -f elf32 $(ASMFLAGS)

main.o: main.c
	cc -c $< -o $@ -m32 -Wall -Wextra $(CFLAGS)

clean:
	rm -f evil-ld entry.o main.o
