import AppKit

class OverlayWindow: NSPanel {
    private var laserView: LaserView!

    init() {
        let screenRect = NSScreen.main?.frame ?? .zero
        super.init(
            contentRect: screenRect,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        
        self.isOpaque = false
        self.backgroundColor = .clear
        self.level = .init(Int(CGShieldingWindowLevel()))
        self.ignoresMouseEvents = true
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]
        self.hidesOnDeactivate = false
        
        laserView = LaserView(frame: screenRect)
        self.contentView = laserView
    }
    
    func show() {
        // Ensure it covers the current screen or all screens
        if let screen = NSScreen.main {
            self.setFrame(screen.frame, display: true)
        }
        self.makeKeyAndOrderFront(nil)
        laserView.start()
    }
    
    func hide() {
        self.orderOut(nil)
        laserView.stop()
    }
}
