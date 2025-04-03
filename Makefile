.PHONY: build clean

CFLAGS := -Werror

default: build

clean:
	rm bin/main || true
	rm -r build || true

init: clean
	mkdir -p build

build/javascript.yy.c: src/javascript.lex
	flex -o $@ $^

build/javascript.yy.o: build/javascript.yy.c
	gcc $(CFLAGS) -o $@ -c $^

bin/main: build/javascript.yy.o
	gcc $(CFLAGS) -o $@ $^ -lfl

build: init bin/main
