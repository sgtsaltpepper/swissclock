import AppKit

final class MondaineClockView: NSView {
    var snapshotProvider: () -> ClockSnapshot = { MondaineClockModel.snapshot(at: Date()) }
    var rendersAsPreview = false {
        didSet {
            needsDisplay = true
        }
    }
    var showsDebugOverlay = false {
        didSet {
            needsDisplay = true
        }
    }

    private var displayTimer: Timer?

    override var isOpaque: Bool {
        true
    }

    private var isDarkMode: Bool {
        if #available(macOS 10.14, *) {
            return effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        }
        return false
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        guard let context = NSGraphicsContext.current?.cgContext else { return }
        var renderer = MondaineClockRenderer(showsDebugOverlay: showsDebugOverlay)
        renderer.draw(in: bounds, snapshot: snapshotProvider(), context: context, isPreview: rendersAsPreview, isDarkMode: isDarkMode)
    }

    func startAnimating() {
        stopAnimating()

        displayTimer = Timer.scheduledTimer(withTimeInterval: MondaineClockModel.frameInterval, repeats: true) { [weak self] _ in
            self?.needsDisplay = true
        }
    }

    func stopAnimating() {
        displayTimer?.invalidate()
        displayTimer = nil
    }

    deinit {
        stopAnimating()
    }
}
