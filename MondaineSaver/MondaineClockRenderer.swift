import AppKit

struct MondaineClockStyle {
    var background = NSColor(calibratedWhite: 0.08, alpha: 1.0)
    var dial = NSColor(calibratedWhite: 0.97, alpha: 1.0)
    var marker = NSColor(calibratedWhite: 0.12, alpha: 1.0)
    var bezel = NSColor(calibratedWhite: 0.76, alpha: 1.0)
    var bezelEdge = NSColor(calibratedWhite: 0.42, alpha: 1.0)
    var bezelHighlight = NSColor(calibratedWhite: 0.95, alpha: 0.55)
    var rim = NSColor(calibratedWhite: 0.60, alpha: 1.0)
    var seconds = NSColor(calibratedRed: 0.89, green: 0.19, blue: 0.11, alpha: 1.0)
    var secondsInnerHub = NSColor(calibratedRed: 0.80, green: 0.16, blue: 0.10, alpha: 1.0)
}


struct MondaineClockRenderer {
    var style = MondaineClockStyle()
    var showsDebugOverlay = false

    mutating func draw(in bounds: CGRect, snapshot: ClockSnapshot, context: CGContext, isPreview: Bool, isDarkMode: Bool = false) {
        if isDarkMode {
            style.background = NSColor(calibratedWhite: 0.03, alpha: 1.0)
            style.dial = NSColor(calibratedWhite: 0.08, alpha: 1.0)
            style.marker = NSColor(calibratedWhite: 0.65, alpha: 1.0)
            style.rim = NSColor(calibratedWhite: 0.2, alpha: 1.0)
            style.bezel = NSColor(calibratedWhite: 0.18, alpha: 1.0)
            style.bezelEdge = NSColor(calibratedWhite: 0.05, alpha: 1.0)
            style.bezelHighlight = NSColor(calibratedWhite: 0.6, alpha: 0.3)
            style.seconds = NSColor(calibratedRed: 0.7, green: 0.1, blue: 0.05, alpha: 1.0)
            style.secondsInnerHub = NSColor(calibratedRed: 0.5, green: 0.05, blue: 0.02, alpha: 1.0)
        }

        style.background.setFill()
        bounds.fill()

        context.saveGState()
        context.setAllowsAntialiasing(true)
        context.setShouldAntialias(true)

        let side = min(bounds.width, bounds.height) * (isPreview ? 0.82 : 0.9)
        let clockRect = CGRect(
            x: bounds.midX - side / 2.0,
            y: bounds.midY - side / 2.0,
            width: side,
            height: side
        )

        drawClock(in: clockRect, snapshot: snapshot, context: context, isDarkMode: isDarkMode)
        if showsDebugOverlay {
            drawDebugOverlay(in: bounds, snapshot: snapshot)
        }
        context.restoreGState()
    }

    private func drawClock(in rect: CGRect, snapshot: ClockSnapshot, context: CGContext, isDarkMode: Bool) {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = rect.width / 2.0

        drawOuterRim(center: center, radius: radius, context: context)
        drawDial(center: center, radius: radius * 0.93, context: context)
        drawMarkers(center: center, radius: radius * 0.86, context: context)
        drawHands(center: center, radius: radius * 0.8, snapshot: snapshot, context: context, isDarkMode: isDarkMode)
        drawGlassReflection(center: center, radius: radius, context: context)
    }

    private func drawGlassReflection(center: CGPoint, radius: CGFloat, context: CGContext) {
        context.saveGState()
        let rect = CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2.0, height: radius * 2.0)
        context.addPath(CGPath(ellipseIn: rect, transform: nil))
        context.clip()

        let colors = [
            NSColor(calibratedWhite: 1.0, alpha: 0.18).cgColor,
            NSColor(calibratedWhite: 1.0, alpha: 0.02).cgColor,
            NSColor(calibratedWhite: 1.0, alpha: 0.0).cgColor
        ] as CFArray
        
        let locations: [CGFloat] = [0.0, 0.45, 1.0]
        if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: locations) {
            let start = CGPoint(x: center.x - radius * 0.3, y: center.y + radius * 0.8)
            let end = CGPoint(x: center.x + radius * 0.5, y: center.y - radius * 0.5)
            context.drawLinearGradient(gradient, start: start, end: end, options: [])
        }
        context.restoreGState()
    }

    private func drawOuterRim(center: CGPoint, radius: CGFloat, context: CGContext) {
        let rimRect = CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2.0, height: radius * 2.0)

        // Dark outer edge (shadow/depth)
        context.addPath(CGPath(ellipseIn: rimRect, transform: nil))
        context.setFillColor(style.bezelEdge.cgColor)
        context.fillPath()

        // Silver metallic bezel
        let bezelRect = rimRect.insetBy(dx: radius * 0.02, dy: radius * 0.02)
        context.addPath(CGPath(ellipseIn: bezelRect, transform: nil))
        context.setFillColor(style.bezel.cgColor)
        context.fillPath()

        // Subtle highlight ring
        context.addPath(CGPath(ellipseIn: bezelRect.insetBy(dx: radius * 0.01, dy: radius * 0.01), transform: nil))
        context.setStrokeColor(style.bezelHighlight.cgColor)
        context.setLineWidth(radius * 0.012)
        context.strokePath()
    }

    private func drawDial(center: CGPoint, radius: CGFloat, context: CGContext) {
        let dialRect = CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2.0, height: radius * 2.0)
        context.addPath(CGPath(ellipseIn: dialRect, transform: nil))
        context.setFillColor(style.dial.cgColor)
        context.fillPath()

        context.addPath(CGPath(ellipseIn: dialRect.insetBy(dx: radius * 0.01, dy: radius * 0.01), transform: nil))
        context.setStrokeColor(style.rim.cgColor)
        context.setLineWidth(radius * 0.02)
        context.strokePath()
    }

    private func drawMarkers(center: CGPoint, radius: CGFloat, context: CGContext) {
        context.saveGState()
        context.setStrokeColor(style.marker.cgColor)
        context.setLineCap(.butt)

        for index in 0..<60 {
            let progress = Double(index) / 60.0
            let isHourMark = index.isMultiple(of: 5)
            let tickLength = radius * (isHourMark ? 0.18 : 0.07)
            let tickWidth = radius * (isHourMark ? 0.055 : 0.022)

            let outerPoint = point(center: center, radius: radius, progress: progress)
            let innerPoint = point(center: center, radius: radius - tickLength, progress: progress)

            context.setLineWidth(tickWidth)
            context.move(to: innerPoint)
            context.addLine(to: outerPoint)
            context.strokePath()
        }
        context.restoreGState()
    }

    private func drawHands(center: CGPoint, radius: CGFloat, snapshot: ClockSnapshot, context: CGContext, isDarkMode: Bool) {
        context.saveGState()
        if isDarkMode {
            let lumeColor = NSColor(calibratedRed: 0.2, green: 0.95, blue: 0.4, alpha: 0.9)
            context.setShadow(offset: .zero, blur: radius * 0.05, color: lumeColor.cgColor)
        } else {
            context.setShadow(offset: CGSize(width: radius * 0.018, height: -radius * 0.024), blur: radius * 0.025, color: NSColor(calibratedWhite: 0.0, alpha: 0.4).cgColor)
        }

        drawRectangularHand(
            center: center,
            progress: snapshot.hourProgress,
            frontLength: radius * 0.50,
            backLength: radius * 0.16,
            width: radius * 0.10,
            color: style.marker,
            context: context
        )

        drawRectangularHand(
            center: center,
            progress: snapshot.minuteProgress,
            frontLength: radius * 0.76,
            backLength: radius * 0.13,
            width: radius * 0.08,
            color: style.marker,
            context: context
        )
        context.restoreGState()

        context.saveGState()
        if !isDarkMode {
            context.setShadow(offset: CGSize(width: radius * 0.025, height: -radius * 0.03), blur: radius * 0.03, color: NSColor(calibratedWhite: 0.0, alpha: 0.45).cgColor)
        }
        drawSecondHand(center: center, radius: radius, snapshot: snapshot, context: context)

        let outerHubRadius = radius * 0.052
        let innerHubRadius = radius * 0.026
        context.addPath(CGPath(ellipseIn: CGRect(x: center.x - outerHubRadius, y: center.y - outerHubRadius, width: outerHubRadius * 2.0, height: outerHubRadius * 2.0), transform: nil))
        context.setFillColor(style.seconds.cgColor)
        context.fillPath()

        context.addPath(CGPath(ellipseIn: CGRect(x: center.x - innerHubRadius, y: center.y - innerHubRadius, width: innerHubRadius * 2.0, height: innerHubRadius * 2.0), transform: nil))
        context.setFillColor(style.secondsInnerHub.cgColor)
        context.fillPath()
        
        context.restoreGState()
    }

    private func drawRectangularHand(center: CGPoint, progress: Double, frontLength: CGFloat, backLength: CGFloat, width: CGFloat, color: NSColor, context: CGContext) {
        let direction = unitVector(progress: progress)
        let back = center.translated(by: direction.scaled(by: -backLength))
        let front = center.translated(by: direction.scaled(by: frontLength))

        context.saveGState()
        context.setStrokeColor(color.cgColor)
        context.setLineWidth(width)
        context.setLineCap(.round)
        context.move(to: back)
        context.addLine(to: front)
        context.strokePath()
        context.restoreGState()
    }

    private func drawSecondHand(center: CGPoint, radius: CGFloat, snapshot: ClockSnapshot, context: CGContext) {
        let direction = unitVector(progress: snapshot.secondProgress)
        let frontTip = center.translated(by: direction.scaled(by: radius * 0.72))
        let lollipopCenter = center.translated(by: direction.scaled(by: -(radius * 0.53)))
        let lollipopRadius = radius * 0.082

        context.setStrokeColor(style.seconds.cgColor)
        context.setLineCap(.round)

        context.setLineWidth(radius * 0.018)
        context.move(to: frontTip)
        context.addLine(to: lollipopCenter)
        context.strokePath()

        context.setLineWidth(radius * 0.038)
        context.move(to: center)
        context.addLine(to: center.translated(by: direction.scaled(by: radius * 0.23)))
        context.strokePath()

        context.addPath(CGPath(ellipseIn: CGRect(x: lollipopCenter.x - lollipopRadius, y: lollipopCenter.y - lollipopRadius, width: lollipopRadius * 2.0, height: lollipopRadius * 2.0), transform: nil))
        context.setFillColor(style.seconds.cgColor)
        context.fillPath()

        if snapshot.secondHandPhase == .pause {
            context.setStrokeColor(style.seconds.cgColor)
            context.setLineWidth(radius * 0.04)
            context.setLineCap(.round)
            context.move(to: frontTip.translated(by: direction.scaled(by: -(radius * 0.035))))
            context.addLine(to: frontTip.translated(by: direction.scaled(by: radius * 0.035)))
            context.strokePath()
        }
    }

    private func drawDebugOverlay(in bounds: CGRect, snapshot: ClockSnapshot) {
        let timezone = TimeZone.autoupdatingCurrent.identifier
        let lines = [
            String(format: "DEBUG %02d:%02d:%02d", snapshot.displayedHour, snapshot.displayedMinute, snapshot.displayedSecond),
            "TZ \(timezone)",
            String(format: "P H %.3f  M %.3f  S %.3f", snapshot.hourProgress, snapshot.minuteProgress, snapshot.secondProgress)
        ]

        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .left

        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.monospacedSystemFont(ofSize: 18, weight: .medium),
            .foregroundColor: NSColor.systemGreen,
            .paragraphStyle: paragraph
        ]

        let overlay = NSAttributedString(string: lines.joined(separator: "\n"), attributes: attributes)
        let size = overlay.size()
        let rect = CGRect(x: 20, y: 20, width: size.width + 16, height: size.height + 12)

        NSColor(calibratedWhite: 0.0, alpha: 0.55).setFill()
        NSBezierPath(roundedRect: rect, xRadius: 8, yRadius: 8).fill()
        overlay.draw(in: rect.insetBy(dx: 8, dy: 6))
    }

    private func point(center: CGPoint, radius: CGFloat, progress: Double) -> CGPoint {
        center.translated(by: unitVector(progress: progress).scaled(by: radius))
    }

    private func unitVector(progress: Double) -> CGVector {
        let angle = progress * Double.pi * 2.0
        return CGVector(dx: CGFloat(sin(angle)), dy: CGFloat(cos(angle)))
    }

}

private extension CGPoint {
    func translated(by vector: CGVector) -> CGPoint {
        CGPoint(x: x + vector.dx, y: y + vector.dy)
    }
}

private extension CGVector {
    func scaled(by amount: CGFloat) -> CGVector {
        CGVector(dx: dx * amount, dy: dy * amount)
    }
}
