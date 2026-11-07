import SwiftUI

@main
struct QuotaBarApp: App {
    @StateObject private var store = QuotaStore()

    var body: some Scene {
        MenuBarExtra {
            QuotaView(store: store)
        } label: {
            Text(menuBarTitle)
        }
        .menuBarExtraStyle(.window)
    }

    /// e.g. "5h 42% (1 h 05) · 7j 68%"
    private var menuBarTitle: String {
        guard let usage = store.usage else { return "Quota –" }

        let fiveHour = usage.fiveHour.map { window in
            let percentage = "5h \(Int(window.usedPercentage(at: store.now).rounded()))%"
            guard let timeLeft = window.timeUntilReset(at: store.now) else { return percentage }

            return "\(percentage) (\(timeLeft))"
        }
        let sevenDay = usage.sevenDay.map { "7j \(Int($0.usedPercentage(at: store.now).rounded()))%" }

        return [fiveHour, sevenDay].compactMap { $0 }.joined(separator: " · ")
    }
}
