all: bin/menus bin/clock bin/wait_click bin/calendar

bin/menus: menus.c | bin
	clang -std=c99 -O3 -F/System/Library/PrivateFrameworks/ -framework Carbon -framework SkyLight $< -o $@

bin/wait_click: wait_click.c | bin
	clang -std=c99 -O3 -framework ApplicationServices $< -o $@

# The Info.plist is embedded so macOS can ask for calendar access
bin/calendar: calendar.swift calendar-Info.plist sketchybar.h | bin
	swiftc -O -swift-version 5 -import-objc-header sketchybar.h \
		-Xlinker -sectcreate -Xlinker __TEXT -Xlinker __info_plist -Xlinker calendar-Info.plist \
		calendar.swift -o $@

bin/clock: clock.c | bin
	clang -std=c99 clock.c -framework CoreFoundation -o bin/clock

bin:
	mkdir bin
