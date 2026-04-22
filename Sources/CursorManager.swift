import AppKit

// Private undocumented CGS API that allows cursor hiding while the app runs in the background
// Will probably break at some point
@_silgen_name("CGSMainConnectionID")
func CGSMainConnectionID() -> Int32

@_silgen_name("CGSSetConnectionProperty")
func CGSSetConnectionProperty(_ cid: Int32, _ targetCid: Int32, _ key: CFString, _ value: CFTypeRef) -> Int32

class CursorManager {
    static let shared = CursorManager()
    private var isHidden = false
    private var usingNSCursorFallback = false

    private init() {}

    func hideCursor() {
        guard !isHidden else { return }
        isHidden = true
        usingNSCursorFallback = false

        let cid = CGSMainConnectionID()
        let result = CGSSetConnectionProperty(cid, cid, "SetsCursorInBackground" as CFString, kCFBooleanTrue)

        if result != 0 {
            // if private api is unavailable fall back to NSCursor
            NSCursor.hide()
            usingNSCursorFallback = true
            return
        }

        forEachDisplay { CGDisplayHideCursor($0) }
    }

    func showCursor() {
        guard isHidden else { return }
        isHidden = false

        if usingNSCursorFallback {
            NSCursor.unhide()
            usingNSCursorFallback = false
            return
        }

        let cid = CGSMainConnectionID()
        // Show cursor first while background mode is still active, then revoke it
        forEachDisplay { CGDisplayShowCursor($0) }
        _ = CGSSetConnectionProperty(cid, cid, "SetsCursorInBackground" as CFString, kCFBooleanFalse)
    }

    private func forEachDisplay(_ action: (CGDirectDisplayID) -> Void) {
        var displayCount: UInt32 = 0
        CGGetActiveDisplayList(0, nil, &displayCount)
        guard displayCount > 0 else { return }

        let displays = UnsafeMutablePointer<CGDirectDisplayID>.allocate(capacity: Int(displayCount))
        defer { displays.deallocate() }
        CGGetActiveDisplayList(displayCount, displays, &displayCount)

        for i in 0..<Int(displayCount) {
            action(displays[i])
        }
    }
}
