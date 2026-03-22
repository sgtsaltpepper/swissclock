import ScreenSaver

@objc(SwissClockSaverView)
final class MondaineSaverView: ScreenSaverView {

    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        animationTimeInterval = MondaineClockModel.frameInterval
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        animationTimeInterval = MondaineClockModel.frameInterval
    }

    override var isOpaque: Bool {
        true
    }

    override var hasConfigureSheet: Bool {
        false
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
        var renderer = MondaineClockRenderer(showsDebugOverlay: false)
        renderer.draw(in: bounds, snapshot: MondaineClockModel.snapshot(at: Date()), context: context, isPreview: isPreview, isDarkMode: isDarkMode)
    }

    override func animateOneFrame() {
        self.needsDisplay = true
    }

    override func startAnimation() {
        super.startAnimation()
        self.needsDisplay = true
    }
}
