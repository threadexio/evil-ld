INTERPRETER ?= $(shell realpath -s $$PWD/loader)

all: example_real example_patched

example_real: example.c
	cc $^ -o $@ -m32 -ggdb3

example_patched: example_real
	cp $< $@
	patchelf --set-interpreter "$(INTERPRETER)" $@
	chmod +s $@
