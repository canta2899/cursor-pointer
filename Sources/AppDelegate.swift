import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var listenerEnabled = true
    private var laserActive = false
    private var overlayWindow: OverlayWindow?
    
    private var lastControlRelease: Date?
    private var globalMonitor: Any?

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupTray()
        setupGlobalListener()
        
        // Hide dock icon explicitly just in case LSUIElement isn't picked up during dev
        NSApp.setActivationPolicy(.accessory)
    }

    func applicationWillTerminate(_ notification: Notification) {
        // Ensure cursor is restored on exit
        CursorManager.shared.showCursor()
    }

    private func setupTray() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            // Using a system symbol since I accidentally deleted the custom icon
            button.image = NSImage(systemSymbolName: "cursorarrow.rays", accessibilityDescription: "Cursor Pointer")
        }
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Disable Listener", action: #selector(toggleListener), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem.menu = menu
    }

    private func setupGlobalListener() {
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
            guard let self = self, self.listenerEnabled else { return }
            
            // 0x3C is the mask for Control key on macOS
            // We check if the control flag is being released
            if event.modifierFlags.intersection(.deviceIndependentFlagsMask) == [] && event.keyCode == 59 { // 59 is Control
                let now = Date()
                if let lastRelease = self.lastControlRelease {
                    let diff = now.timeIntervalSince(lastRelease)
                    if diff < 0.4 {
                        self.toggleLaser()
                        self.lastControlRelease = nil
                        return
                    }
                }
                self.lastControlRelease = now
            }
        }
    }

    @objc private func toggleListener() {
        listenerEnabled.toggle()
        if let item = statusItem.menu?.item(at: 0) {
            item.title = listenerEnabled ? "Disable Listener" : "Enable Listener"
        }
        
        if !listenerEnabled && laserActive {
            toggleLaser()
        }
    }

    private func toggleLaser() {
        laserActive.toggle()
        
        if laserActive {
            if overlayWindow == nil {
                overlayWindow = OverlayWindow()
            }
            overlayWindow?.show()
            CursorManager.shared.hideCursor()
        } else {
            overlayWindow?.hide()
            CursorManager.shared.showCursor()
        }
    }
}
