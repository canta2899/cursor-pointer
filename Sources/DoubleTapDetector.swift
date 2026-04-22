import Foundation

public class DoubleTapDetector {
    private let threshold: TimeInterval
    private var lastTapDate: Date?
    
    public init(threshold: TimeInterval = 0.4) {
        self.threshold = threshold
    }
    
    /// Processes a tap and returns true if it's a double tap
    public func processTap(at now: Date = Date()) -> Bool {
        if let lastTap = lastTapDate {
            let diff = now.timeIntervalSince(lastTap)
            if diff < threshold {
                lastTapDate = nil // Reset after successful detection
                return true
            }
        }
        lastTapDate = now
        return false
    }
}
