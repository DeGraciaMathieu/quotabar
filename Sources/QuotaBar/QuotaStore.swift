import Foundation

@MainActor
final class QuotaStore: ObservableObject {
    @Published private(set) var usage: PlanUsage?
    /// When the status line relay last saved the limits.
    @Published private(set) var updatedAt: Date?
    @Published private(set) var now = Date()

    /// Written by `scripts/statusline-relay.sh`.
    private let fileURL = FileManager.default
        .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        .appending(path: "quotabar/statusline.json")

    private let refreshInterval: TimeInterval = 5
    private var timer: Timer?

    private struct StatusLineInput: Decodable {
        let rateLimits: PlanUsage?

        private enum CodingKeys: String, CodingKey {
            case rateLimits = "rate_limits"
        }
    }

    init() {
        refresh()
        // Also moves `now` forward, so countdowns and passed resets stay right between two saves.
        timer = Timer.scheduledTimer(withTimeInterval: refreshInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.refresh() }
        }
    }

    private func refresh() {
        now = Date()

        guard let data = try? Data(contentsOf: fileURL),
              let input = try? JSONDecoder().decode(StatusLineInput.self, from: data) else { return }

        usage = input.rateLimits
        updatedAt = (try? FileManager.default.attributesOfItem(atPath: fileURL.path))?[.modificationDate] as? Date
    }
}
