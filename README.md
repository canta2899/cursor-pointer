# Cursor Pointer (Native macOS)

A lightweight macOS tray application that provides a laser pointer effect for your cursor. It runs in the menu bar with no dock icon and, when triggered by double-clicking the Ctrl key, it replaces the cursor with a smooth, fading red trail that follows your cursor like a laser pointer.

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

