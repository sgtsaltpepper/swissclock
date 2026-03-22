import AppKit

final class PreviewAppDelegate: NSObject, NSApplicationDelegate {
    private var window: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        let contentRect = NSRect(x: 0, y: 0, width: 1100, height: 900)
        let styleMask: NSWindow.StyleMask = [.titled, .closable, .miniaturizable, .resizable]
        let window = NSWindow(contentRect: contentRect, styleMask: styleMask, backing: .buffered, defer: false)
        window.center()
        window.title = "Mondaine Preview"

        let clockView = MondaineClockView(frame: contentRect)
        clockView.autoresizingMask = [.width, .height]
        clockView.showsDebugOverlay = false
        clockView.startAnimating()

        window.contentView = clockView
        window.makeKeyAndOrderFront(nil)

        self.window = window
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}

let app = NSApplication.shared
let delegate = PreviewAppDelegate()
app.delegate = delegate
app.setActivationPolicy(.regular)
app.run()
