import Cocoa

NSWindow.allowsAutomaticWindowTabbing = false

class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!
    var label: NSTextField!
    var timer: Timer?

    // 状态
    var secondsRemaining = 15 * 60
    var isBreakTime = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        createOverlay()
        startTimer()
    }

    func createOverlay() {
        guard let screen = NSScreen.main else { return }
        let frame = screen.frame

        window = NSWindow(
            contentRect: NSRect(
                x: frame.width - 220,
                y: frame.height - 220,
                width: 200,
                height: 200
            ),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        window.isOpaque = false
        window.backgroundColor = .clear
        window.level = .screenSaver
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.ignoresMouseEvents = true

        label = NSTextField(labelWithString: "")
        label.font = NSFont.systemFont(ofSize: 64, weight: .bold)
        label.textColor = .systemRed
        label.alignment = .center
        label.frame = window.contentView!.bounds
        label.autoresizingMask = [.width, .height]

        window.contentView?.addSubview(label)
        window.makeKeyAndOrderFront(nil)

        updateDisplay()
    }

    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.tick()
        }
    }

    func tick() {
        secondsRemaining -= 1

        if secondsRemaining <= 0 {
            if isBreakTime {
                // 休息结束 → 重新进入工作阶段
                isBreakTime = false
                secondsRemaining = 15 * 60
                window.alphaValue = 0.3   // 倒计时淡一点
            } else {
                // 工作结束 → 进入休息阶段
                isBreakTime = true
                secondsRemaining = 3 * 60
                window.alphaValue = 1.0   // 提示明显一点
            }
        }

        updateDisplay()
    }

    func updateDisplay() {
        if isBreakTime {
            label.stringValue = "起来走走"
        } else {
            let minutes = secondsRemaining / 60
            let seconds = secondsRemaining % 60
            label.stringValue = String(format: "%02d:%02d", minutes, seconds)
        }
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
