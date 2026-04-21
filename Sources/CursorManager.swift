import AppKit

// Private CGS headers
@_silgen_name("CGSMainConnectionID")
func CGSMainConnectionID() -> Int32

@_silgen_name("CGSSetConnectionProperty")
func CGSSetConnectionProperty(_ cid: Int32, _ targetCid: Int32, _ key: CFString, _ value: CFTypeRef) -> Int32

class CursorManager {
    static let shared = CursorManager()
    private var isHidden = false
    
    private init() {}
    
    func hideCursor() {
        guard !isHidden else { return }
        isHidden = true
        
        // 1. Enable background cursor control
        let cid = CGSMainConnectionID()
        let key = "SetsCursorInBackground" as CFString
        CGSSetConnectionProperty(cid, cid, key, kCFBooleanTrue)
        
        // 2. Hide on all displays
        var displayCount: UInt32 = 0
        CGGetActiveDisplayList(0, nil, &displayCount)
        
        let displays = UnsafeMutablePointer<CGDirectDisplayID>.allocate(capacity: Int(displayCount))
        CGGetActiveDisplayList(displayCount, displays, &displayCount)
        
        for i in 0..<Int(displayCount) {
            CGDisplayHideCursor(displays[i])
        }
        displays.deallocate()
    }
    
    func showCursor() {
        guard isHidden else { return }
        isHidden = false
        
        var displayCount: UInt32 = 0
        CGGetActiveDisplayList(0, nil, &displayCount)
        
        let displays = UnsafeMutablePointer<CGDirectDisplayID>.allocate(capacity: Int(displayCount))
        CGGetActiveDisplayList(displayCount, displays, &displayCount)
        
        for i in 0..<Int(displayCount) {
            CGDisplayShowCursor(displays[i])
        }
        displays.deallocate()
    }
}
