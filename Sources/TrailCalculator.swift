import Foundation

public struct TrailPoint: Equatable {
    public let location: CGPoint
    public let timestamp: Date
    
    public init(location: CGPoint, timestamp: Date) {
        self.location = location
        self.timestamp = timestamp
    }
}

public class TrailCalculator {
    public let duration: TimeInterval
    
    public init(duration: TimeInterval = 0.3) {
        self.duration = duration
    }
    
    public func filterPoints(_ points: [TrailPoint], relativeTo now: Date) -> [TrailPoint] {
        return points.filter { now.timeIntervalSince($0.timestamp) < duration }
    }
    
    public func calculateAlpha(for point: TrailPoint, relativeTo now: Date) -> Double {
        let age = now.timeIntervalSince(point.timestamp)
        return max(0, 1.0 - (age / duration))
    }
    
    public func calculateRadius(for alpha: Double, baseRadius: Double = 6.0) -> Double {
        return baseRadius * alpha
    }
}
