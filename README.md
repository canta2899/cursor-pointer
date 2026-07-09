# Cursor Pointer

This is a _mostly_ vibecoded MacOS application that runs in the tray bar (no dock icon) and, when active, allows to turn the mouse cursor into a smooth, fading red trail that follows your mouse movements like a laser pointer. Works also when sharing a full screen window.

I made this because sometimes, while screen sharing during talks or presentations, I just want to be able to point at things clearly without bloating my mac with random paid software that does everything but what I need.

<div align="center">
<img src="./demo.gif" alt="demo" width="400"/>
</div>

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

