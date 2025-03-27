INTERPRETER ?= $(shell realpath $$PWD/../evil-ld)

all: example_real example_patched

example_real: example.c
	cc $^ -o $@ -m32

example_patched: example_real
	cp $< $@
	patchelf --set-interpreter "$(INTERPRETER)" $@
