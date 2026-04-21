# Cursor Pointer (Native macOS)

A lightweight macOS tray application that provides a laser pointer effect for your cursor.

## Features
- **Ultra-lightweight**: Rewritten in pure Swift/AppKit, removing the heavy WebView overhead.
- **Tray-only**: Runs in the menu bar with no dock icon.
- **Laser Trail**: A smooth, fading red trail that follows your cursor.
- **Global Toggle**: Double-tap the `Control` key to toggle the laser.
- **Cursor Hiding**: Automatically hides the system cursor when the laser is active (even in the background).

## Building & Running

### Requirements
- macOS 12.0 or later
- Xcode Command Line Tools (`swiftc`, `make`)

### Build
To build the application bundle:
```bash
make build
```

### Run
To build and launch the application:
```bash
make run
```

### Controls
- **Toggle Laser**: Double-tap the `Control` key.
- **Tray Menu**: Click the cursor icon in the menu bar to enable/disable the listener or quit.

## Architecture
The app uses:
- `NSStatusItem` for the tray menu.
- `NSEvent` global monitors for input detection.
- A transparent `NSPanel` at the `cgShieldingWindowLevel` for the overlay.
- `CVDisplayLink` + `CoreGraphics` for 60fps+ rendering of the laser trail.
- Private CoreGraphics Services (CGS) APIs to handle cursor visibility globally.
