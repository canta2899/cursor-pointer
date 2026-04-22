import XCTest
@testable import CursorPointer

final class CursorPointerTests: XCTestCase {
    
    var calculator: TrailCalculator!
    
    override func setUp() {
        super.setUp()
        calculator = TrailCalculator(duration: 0.3)
    }
    
    func testFilterPoints() {
        let now = Date()
        let points = [
            TrailPoint(location: .zero, timestamp: now.addingTimeInterval(-0.1)),
            TrailPoint(location: .zero, timestamp: now.addingTimeInterval(-0.2)),
            TrailPoint(location: .zero, timestamp: now.addingTimeInterval(-0.4)) // Should be filtered
        ]
        
        let filtered = calculator.filterPoints(points, relativeTo: now)
        
        XCTAssertEqual(filtered.count, 2)
        XCTAssertEqual(filtered[0].timestamp, points[0].timestamp)
        XCTAssertEqual(filtered[1].timestamp, points[1].timestamp)
    }
    
    func testCalculateAlpha() {
        let now = Date()
        
        // Brand new point
        let p1 = TrailPoint(location: .zero, timestamp: now)
        XCTAssertEqual(calculator.calculateAlpha(for: p1, relativeTo: now), 1.0)
        
        // Halfway point
        let p2 = TrailPoint(location: .zero, timestamp: now.addingTimeInterval(-0.15))
        XCTAssertEqual(calculator.calculateAlpha(for: p2, relativeTo: now), 0.5, accuracy: 0.01)
        
        // Expired point
        let p3 = TrailPoint(location: .zero, timestamp: now.addingTimeInterval(-0.4))
        XCTAssertEqual(calculator.calculateAlpha(for: p3, relativeTo: now), 0.0)
    }
    
    func testCalculateRadius() {
        XCTAssertEqual(calculator.calculateRadius(for: 1.0, baseRadius: 10.0), 10.0)
        XCTAssertEqual(calculator.calculateRadius(for: 0.5, baseRadius: 10.0), 5.0)
        XCTAssertEqual(calculator.calculateRadius(for: 0.0, baseRadius: 10.0), 0.0)
    }
    
    func testDoubleTapDetector() {
        let detector = DoubleTapDetector(threshold: 0.4)
        let now = Date()
        
        // First tap
        XCTAssertFalse(detector.processTap(at: now))
        
        // Second tap within threshold
        XCTAssertTrue(detector.processTap(at: now.addingTimeInterval(0.2)))
        
        // Third tap (new sequence)
        XCTAssertFalse(detector.processTap(at: now.addingTimeInterval(0.3)))
        
        // Fourth tap outside threshold
        XCTAssertFalse(detector.processTap(at: now.addingTimeInterval(0.8)))
        
        // Fifth tap (new sequence)
        XCTAssertFalse(detector.processTap(at: now.addingTimeInterval(0.9)))
    }
}
