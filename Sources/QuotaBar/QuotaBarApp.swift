import SwiftUI

@main
struct QuotaBarApp: App {
    @StateObject private var store = QuotaStore()

    var body: some Scene {
        MenuBarExtra {
            QuotaView(store: store)
        } label: {
            Image(nsImage: MenuBarLabel.image(usage: store.usage, now: store.now))
        }
        .menuBarExtraStyle(.window)
    }
}
