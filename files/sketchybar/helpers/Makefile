all: bin/menus bin/clock bin/wait_click bin/calendar bin/focus bin/wifibluetooth bin/weather.app

bin/menus: menus.c | bin
	clang -std=c99 -O3 -F/System/Library/PrivateFrameworks/ -framework Carbon -framework SkyLight $< -o $@

bin/wait_click: wait_click.c | bin
	clang -std=c99 -O3 -framework ApplicationServices $< -o $@

# The Info.plist is embedded so macOS can ask for calendar access
bin/calendar: calendar.swift calendar-Info.plist sketchybar.h | bin
	swiftc -O -swift-version 5 -import-objc-header sketchybar.h \
		-Xlinker -sectcreate -Xlinker __TEXT -Xlinker __info_plist -Xlinker calendar-Info.plist \
		calendar.swift -o $@

bin/focus: focus.swift sketchybar.h | bin
	swiftc -O -swift-version 5 -import-objc-header sketchybar.h focus.swift -o $@

# The Info.plist is embedded so macOS can ask for Bluetooth access
bin/wifibluetooth: wifibluetooth.swift wifibluetooth-Info.plist sketchybar.h | bin
	swiftc -O -swift-version 5 -import-objc-header sketchybar.h \
		-Xlinker -sectcreate -Xlinker __TEXT -Xlinker __info_plist -Xlinker wifibluetooth-Info.plist \
		wifibluetooth.swift -o $@

# An app bundle, see weather-Info.plist
bin/weather.app: weather.swift weather-Info.plist sketchybar.h | bin
	mkdir -p $@/Contents/MacOS
	cp weather-Info.plist $@/Contents/Info.plist
	swiftc -O -swift-version 5 -import-objc-header sketchybar.h weather.swift -o $@/Contents/MacOS/weather
	codesign --force --sign - $@

bin/clock: clock.c | bin
	clang -std=c99 clock.c -framework CoreFoundation -o bin/clock

bin:
	mkdir bin
