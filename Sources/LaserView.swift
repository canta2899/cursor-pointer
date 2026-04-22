import AppKit
import QuartzCore

class LaserView: NSView {
    private var trail: [TrailPoint] = []
    private var displayLink: CVDisplayLink?
    private let calculator = TrailCalculator(duration: 0.3)
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupDisplayLink()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupDisplayLink()
    }
    
    private func setupDisplayLink() {
        var link: CVDisplayLink?
        CVDisplayLinkCreateWithActiveCGDisplays(&link)
        displayLink = link
        
        if let link = displayLink {
            CVDisplayLinkSetOutputCallback(link, { (displayLink, inNow, inOutputTime, flagsIn, flagsOut, displayLinkContext) -> CVReturn in
                let view = Unmanaged<LaserView>.fromOpaque(displayLinkContext!).takeUnretainedValue()
                DispatchQueue.main.async {
                    view.updateTrail()
                }
                return kCVReturnSuccess
            }, Unmanaged.passUnretained(self).toOpaque())
        }
    }
    
    func start() {
        if let link = displayLink {
            CVDisplayLinkStart(link)
        }
    }
    
    func stop() {
        if let link = displayLink {
            CVDisplayLinkStop(link)
        }
        trail.removeAll()
        setNeedsDisplay(self.bounds)
    }
    
    private func updateTrail() {
        let mouseLocation = NSEvent.mouseLocation
        // Convert screen coordinates to window/view coordinates
        if let window = self.window {
            let pointInWindow = window.convertPoint(fromScreen: mouseLocation)
            trail.append(TrailPoint(location: pointInWindow, timestamp: Date()))
        }
        
        trail = calculator.filterPoints(trail, relativeTo: Date())
        
        setNeedsDisplay(self.bounds)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        guard let context = NSGraphicsContext.current?.cgContext else { return }
        
        let now = Date()
        
        // Draw trail
        for point in trail {
            let alpha = calculator.calculateAlpha(for: point, relativeTo: now)
            let radius = calculator.calculateRadius(for: alpha)
            
            if alpha > 0 && radius > 0 {
                context.setFillColor(NSColor.red.withAlphaComponent(alpha * 0.6).cgColor)
                context.fillEllipse(in: CGRect(x: point.location.x - radius, y: point.location.y - radius, width: radius * 2, height: radius * 2))
            }
        }
        
        // Draw main dot
        if let current = trail.last {
            let dotRadius: CGFloat = 8.0
            
            // Outer glow
            context.setFillColor(NSColor.red.withAlphaComponent(0.15).cgColor)
            context.fillEllipse(in: CGRect(x: current.location.x - dotRadius * 2, y: current.location.y - dotRadius * 2, width: dotRadius * 4, height: dotRadius * 4))
            
            // Core
            context.setFillColor(NSColor.red.withAlphaComponent(0.9).cgColor)
            context.fillEllipse(in: CGRect(x: current.location.x - dotRadius, y: current.location.y - dotRadius, width: dotRadius * 2, height: dotRadius * 2))
            
            // Highlight
            let highlightRadius = dotRadius * 0.4
            context.setFillColor(NSColor(red: 1.0, green: 0.6, blue: 0.6, alpha: 0.9).cgColor)
            context.fillEllipse(in: CGRect(x: current.location.x - highlightRadius, y: current.location.y - highlightRadius, width: highlightRadius * 2, height: highlightRadius * 2))
        }
    }
}
