all: bin/menus | bin/clock

bin/menus: menus.c | bin
	clang -std=c99 -O3 -F/System/Library/PrivateFrameworks/ -framework Carbon -framework SkyLight $< -o $@

bin/clock: clock.c | bin
	clang -std=c99 clock.c -framework CoreFoundation -o bin/clock

bin:
	mkdir bin