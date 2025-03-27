NASM ?= nasm
CC ?= cc
LD ?= ld

CFLAGS ?=
LFLAGS ?=
ASMFLAGS ?=

NAME ?= evil-ld
ifneq ($(NAME),)
CFLAGS += -DNAME=\"$(NAME)\"
endif

DEBUG ?= 1
ifeq ($(DEBUG),1)
CFLAGS += -DDEBUG
endif

REAL_LD ?=
ifneq ($(REAL_LD),)
CFLAGS += -DREAL_LD=\"$(REAL_LD)\"
endif

KEEP_SUID ?= 1
ifeq ($(KEEP_SUID),1)
CFLAGS += -DKEEP_SUID
endif

DISABLE_ASLR ?= 1
ifeq ($(DISABLE_ASLR),1)
CFLAGS += -DDISABLE_ASLR
endif

OBJS := src/entry.s.o src/main.c.o

$(NAME): $(OBJS)
	$(LD) $^ -o $@ -static -m elf_i386 -z noexecstack $(LFLAGS)

.PHONY:
clean:
	rm -f $(OBJS) $(NAME)

%.s.o: %.s
	$(NASM) $< -o $@ -f elf32 $(ASMFLAGS)

%.c.o: %.c
	$(CC) -c $< -o $@ -m32 -Wall -Wextra $(CFLAGS)


