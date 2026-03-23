import SwiftUI

// MARK: - Log List View
// Per DESIGN.md Section 5: "Log Lists"
// No dividers. Alternate rows using surface and surface-container-low.
// Space Grotesk for timestamps to maintain the "instrument" feel.

struct LogListView: View {
    let entries: [LogEntry]
    var maxEntries: Int = 50

    var body: some View {
        LazyVStack(spacing: 0) {
            ForEach(Array(entries.prefix(maxEntries).enumerated()), id: \.element.id) { index, entry in
                LogRow(entry: entry, isAlternate: index.isMultiple(of: 2))
            }
        }
    }
}

// MARK: - Log Row

struct LogRow: View {
    let entry: LogEntry
    var isAlternate: Bool = false

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.md) {
            // Timestamp (monospaced — "instrument" feel)
            Text(entry.formattedTimestamp)
                .font(NeuralFont.monoSmall())
                .foregroundColor(.onSurfaceVariant)
                .frame(width: 80, alignment: .leading)

            // Log level badge
            Text(entry.level.rawValue)
                .font(NeuralFont.monoSmall())
                .foregroundColor(entry.level.color)
                .frame(width: 36, alignment: .leading)

            // Module
            Text(entry.module)
                .font(NeuralFont.monoSmall())
                .foregroundColor(.neuralPrimary)
                .frame(width: 56, alignment: .leading)

            // Message
            Text(entry.message)
                .font(NeuralFont.monoSmall())
                .foregroundColor(.onSurface)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.sm)
        .background(
            isAlternate ? Color.surface : Color.surfaceContainerLow
        )
    }
}

#Preview {
    ScrollView {
        LogListView(entries: LogEntry.sampleLogs)
    }
    .background(Color.surface)
}
