import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var listenerEnabled = true
    private var laserActive = false
    private var overlayWindows: [OverlayWindow] = []
    
    private let doubleTapDetector = DoubleTapDetector()
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
            if let icon = NSImage(named: "MenuBarIconTemplate") {
                icon.isTemplate = true
                button.image = icon
            }
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
            
            // 59 = left Control, 62 = right Control
            let isControlRelease = event.modifierFlags.intersection(.deviceIndependentFlagsMask) == [] &&
                (event.keyCode == 59 || event.keyCode == 62)
            if isControlRelease && self.doubleTapDetector.processTap() {
                self.toggleLaser()
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
            overlayWindows = NSScreen.screens.map { OverlayWindow(screen: $0) }
            overlayWindows.forEach { $0.show() }
            CursorManager.shared.hideCursor()
        } else {
            overlayWindows.forEach { $0.hide() }
            overlayWindows.removeAll()
            CursorManager.shared.showCursor()
        }
    }
}
