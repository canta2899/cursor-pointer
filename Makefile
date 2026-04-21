APP_NAME = CursorPointer
BIN_NAME = CursorPointer
BUNDLE_ID = com.canta2899.cursor-pointer
APP_BUNDLE = out/$(APP_NAME).app
CONTENTS = $(APP_BUNDLE)/Contents
MACOS = $(CONTENTS)/MacOS
TARGET = arm64-apple-macosx12.0
RESOURCES = $(CONTENTS)/Resources

SWIFT_FILES = Sources/main.swift \
              Sources/AppDelegate.swift \
              Sources/OverlayWindow.swift \
              Sources/LaserView.swift \
              Sources/CursorManager.swift

all: build

build:
	@mkdir -p "$(MACOS)"
	@mkdir -p "$(RESOURCES)"
	swiftc $(SWIFT_FILES) -o "$(MACOS)/$(BIN_NAME)" -O -target "$(TARGET)"
	cp Resources/Info.plist "$(CONTENTS)/Info.plist"

clean:
	rm -rf "$(APP_BUNDLE)"

run: build
	open "$(APP_BUNDLE)"

.PHONY: all build clean run
