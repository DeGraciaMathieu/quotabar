import SwiftUI

/// The menu bar shows a single item badly when it mixes several symbols and texts,
/// so the label is drawn as one template image instead.
@MainActor
enum MenuBarLabel {
    static func image(usage: PlanUsage?, now: Date) -> NSImage {
        let renderer = ImageRenderer(content: MenuBarLabelContent(usage: usage, now: now))
        renderer.scale = NSScreen.main?.backingScaleFactor ?? 2

        let image = renderer.nsImage ?? NSImage()
        // Template: macOS tints it to match a light or dark menu bar.
        image.isTemplate = true
        return image
    }
}

/// e.g. "🕒 81% 1 h 20 · 📅 17%"
private struct MenuBarLabelContent: View {
    let usage: PlanUsage?
    let now: Date

    var body: some View {
        HStack(spacing: 4) {
            if let fiveHour = usage?.fiveHour {
                Image(systemName: "clock")
                Text(sessionText(for: fiveHour))
            }

            if usage?.fiveHour != nil && usage?.sevenDay != nil {
                Text("·")
            }

            if let sevenDay = usage?.sevenDay {
                Image(systemName: "calendar")
                Text(percentageText(for: sevenDay))
            }

            if usage?.fiveHour == nil && usage?.sevenDay == nil {
                Image(systemName: "clock")
                Text("–")
            }
        }
        .font(.system(size: NSFont.menuBarFont(ofSize: 0).pointSize))
    }

    private func sessionText(for window: QuotaWindow) -> String {
        let percentage = percentageText(for: window)
        guard let timeLeft = window.timeUntilReset(at: now) else { return percentage }

        return "\(percentage) \(timeLeft)"
    }

    private func percentageText(for window: QuotaWindow) -> String {
        "\(Int(window.usedPercentage(at: now).rounded()))%"
    }
}
