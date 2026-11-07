import SwiftUI

struct QuotaView: View {
    @ObservedObject var store: QuotaStore

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            if let usage = store.usage {
                QuotaGauge(title: "Session (5 h)", window: usage.fiveHour, now: store.now)
                QuotaGauge(title: "Semaine (7 j)", window: usage.sevenDay, now: store.now)
            } else {
                Text("Aucune donnée pour l'instant : elles arrivent à la prochaine réponse de Claude Code.")
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Divider()

            HStack {
                if let updatedAt = store.updatedAt {
                    Text("Mis à jour \(updatedAt.formatted(.relative(presentation: .named)))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button("Quitter QuotaBar") {
                    NSApplication.shared.terminate(nil)
                }
            }
        }
        .padding(14)
        .frame(width: 320)
    }
}

private struct QuotaGauge: View {
    let title: String
    let window: QuotaWindow?
    let now: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .fontWeight(.medium)

                Spacer()

                if let window {
                    Text("\(Int(window.usedPercentage(at: now).rounded())) %")
                        .monospacedDigit()
                        .foregroundStyle(QuotaLevel.color(for: window.usedPercentage(at: now)))
                }
            }

            if let window {
                ProgressView(value: window.usedPercentage(at: now), total: 100)
                    .tint(QuotaLevel.color(for: window.usedPercentage(at: now)))

                Text(resetText(for: window))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text("Non communiqué par Claude Code")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func resetText(for window: QuotaWindow) -> String {
        guard let timeLeft = window.timeUntilReset(at: now) else { return "Remis à zéro" }

        let time = window.resetsAt.formatted(date: .abbreviated, time: .shortened)
        return "Remise à zéro dans \(timeLeft) (\(time))"
    }
}

enum QuotaLevel {
    static func color(for percentage: Double) -> Color {
        if percentage >= 90 { return .red }
        if percentage >= 70 { return .orange }
        return .primary
    }
}
