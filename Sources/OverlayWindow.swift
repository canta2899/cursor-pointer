import AppKit

class OverlayWindow: NSPanel {
    private var laserView: LaserView!
    private let targetScreen: NSScreen

    init(screen: NSScreen) {
        self.targetScreen = screen
        let screenRect = screen.frame
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

        // View frame is window-local (origin at zero), not in global screen coords
        laserView = LaserView(frame: CGRect(origin: .zero, size: screenRect.size))
        self.contentView = laserView
    }

    func show() {
        // Refresh frame in case resolution changed since init
        self.setFrame(targetScreen.frame, display: true)
        self.makeKeyAndOrderFront(nil)
        laserView.start()
    }

    func hide() {
        self.orderOut(nil)
        laserView.stop()
    }
}
