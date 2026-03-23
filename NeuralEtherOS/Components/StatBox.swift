import SwiftUI

// MARK: - Stat Box
// Compact metric display with label + value.
// Uses tonal surface elevation (no borders per DESIGN.md "No-Line" rule).

struct StatBox: View {
    let label: String
    let value: String
    var accentColor: Color = .neuralPrimary
    var showGlow: Bool = false

    var body: some View {
        VStack(spacing: Spacing.sm) {
            // Value
            Text(value)
                .font(NeuralFont.headlineLarge())
                .foregroundColor(.onSurface)
                .minimumScaleFactor(0.7)
                .lineLimit(1)

            // Label
            Text(label)
                .font(NeuralFont.monoSmall())
                .tracking(2)
                .foregroundColor(accentColor)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.lg)
        .padding(.horizontal, Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.lg)
                .fill(Color.surfaceContainerLow)
        )
        .overlay(
            showGlow
                ? RoundedRectangle(cornerRadius: CornerRadius.lg)
                    .stroke(accentColor.opacity(0.3), lineWidth: 1)
                    .blur(radius: 4)
                : nil
        )
    }
}

// MARK: - Stat Row (Horizontal group of stat boxes)

struct StatRow: View {
    let stats: [(label: String, value: String)]

    var body: some View {
        HStack(spacing: Spacing.md) {
            ForEach(Array(stats.enumerated()), id: \.offset) { _, stat in
                StatBox(label: stat.label, value: stat.value)
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        StatRow(stats: [
            ("COUNTRIES", "175"),
            ("VELOCITY", "10kX"),
            ("LATENCY", "0.02ms")
        ])
        StatBox(label: "SYNC_RATE", value: "92.4%", showGlow: true)
    }
    .padding()
    .background(Color.surface)
}
