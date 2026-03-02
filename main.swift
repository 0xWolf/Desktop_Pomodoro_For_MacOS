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

        // 初始位置先右上角
        let windowWidth: CGFloat = 200
        let windowHeight: CGFloat = 100
        let x = frame.width - windowWidth - 20
        let y = frame.height - windowHeight - 40

        window = NSWindow(
            contentRect: NSRect(x: x, y: y, width: windowWidth, height: windowHeight),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        window.isOpaque = false
        window.backgroundColor = .clear
        window.level = .screenSaver
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.ignoresMouseEvents = true
        window.alphaValue = 0.3

        label = NSTextField(labelWithString: "")
        label.font = NSFont.systemFont(ofSize: 48, weight: .bold)
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

        guard let screen = NSScreen.main else { return }

        if secondsRemaining <= 0 {
            if isBreakTime {
                // 休息结束 → 重新进入工作阶段
                isBreakTime = false
                secondsRemaining = 15 * 60
                // 移回右上角
                moveWindow(to: .topRight, screen: screen)
                window.alphaValue = 0.3
            } else {
                // 工作结束 → 进入休息阶段
                isBreakTime = true
                secondsRemaining = 3 * 60
                // 居中
                moveWindow(to: .center, screen: screen)
                window.alphaValue = 1.0
            }
        }

        updateDisplay()
    }

    enum WindowPosition {
        case topRight
        case center
    }

    func moveWindow(to position: WindowPosition, screen: NSScreen) {
        let windowSize = window.frame.size
        var newOrigin = CGPoint.zero

        switch position {
        case .topRight:
            newOrigin = CGPoint(
                x: screen.frame.width - windowSize.width - 20,
                y: screen.frame.height - windowSize.height - 40
            )
        case .center:
            newOrigin = CGPoint(
                x: (screen.frame.width - windowSize.width) / 2,
                y: (screen.frame.height - windowSize.height) / 2
            )
        }

        window.setFrameOrigin(newOrigin)
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

// ===== 启动 App =====
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
