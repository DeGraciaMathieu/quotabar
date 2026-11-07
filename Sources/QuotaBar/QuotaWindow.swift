import Foundation

/// One plan usage limit as Claude Code reports it: the 5-hour session window or the 7-day window.
struct QuotaWindow: Decodable {
    let usedPercentage: Double
    let resetsAt: Date

    private enum CodingKeys: String, CodingKey {
        case usedPercentage = "used_percentage"
        case resetsAt = "resets_at"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        usedPercentage = try container.decode(Double.self, forKey: .usedPercentage)
        // Unix epoch in seconds.
        resetsAt = Date(timeIntervalSince1970: try container.decode(Double.self, forKey: .resetsAt))
    }

    /// The saved value is only refreshed when Claude Code gets a response: once the reset time
    /// is past, the window is known to be empty again.
    func usedPercentage(at now: Date) -> Double {
        now >= resetsAt ? 0 : usedPercentage
    }

    /// Time left before the reset, e.g. "42 min", "1 h 05" or "2 j 3 h"; nil once the reset is past.
    func timeUntilReset(at now: Date) -> String? {
        guard now < resetsAt else { return nil }

        let minutes = Int((resetsAt.timeIntervalSince(now) / 60).rounded(.up))
        guard minutes >= 60 else { return "\(minutes) min" }

        let hours = minutes / 60
        guard hours >= 24 else { return "\(hours) h \(String(format: "%02d", minutes % 60))" }

        return "\(hours / 24) j \(hours % 24) h"
    }
}

/// The `rate_limits` part of the JSON Claude Code sends to the status line command.
struct PlanUsage: Decodable {
    let fiveHour: QuotaWindow?
    let sevenDay: QuotaWindow?

    private enum CodingKeys: String, CodingKey {
        case fiveHour = "five_hour"
        case sevenDay = "seven_day"
    }
}
