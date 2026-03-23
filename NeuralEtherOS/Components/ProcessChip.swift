import SwiftUI

// MARK: - Process Chip
// Per DESIGN.md Section 5: "Process Chips"
// secondary-container (#3A485B) with label-md text.
// Pill shape (radius: full) to contrast against architectural squareness.

struct ProcessChip: View {
    let label: String
    var icon: String?
    var accentColor: Color?
    var isActive: Bool = false

    var body: some View {
        HStack(spacing: Spacing.sm) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 11))
                    .foregroundColor(chipTextColor)
            }

            Text(label)
                .font(NeuralFont.labelMedium())
                .foregroundColor(chipTextColor)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background(
            Capsule()
                .fill(chipBackgroundColor)
        )
        .overlay(
            isActive
                ? Capsule()
                    .stroke(Color.neuralPrimary.opacity(0.3), lineWidth: 1)
                    .blur(radius: 2)
                : nil
        )
    }

    private var chipBackgroundColor: Color {
        if isActive {
            return Color.neuralPrimary.opacity(0.15)
        }
        return Color.secondaryContainer
    }

    private var chipTextColor: Color {
        if let accentColor {
            return accentColor
        }
        if isActive {
            return .neuralPrimary
        }
        return .onSurface
    }
}

// MARK: - Chip Row

struct ChipRow: View {
    let chips: [(label: String, icon: String?)]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.sm) {
                ForEach(Array(chips.enumerated()), id: \.offset) { _, chip in
                    ProcessChip(label: chip.label, icon: chip.icon)
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        HStack {
            ProcessChip(label: "ONLINE", icon: "circle.fill", accentColor: .neuralSuccess, isActive: true)
            ProcessChip(label: "v2.4.1", icon: "tag")
            ProcessChip(label: "175 NODES", icon: "globe")
        }

        ChipRow(chips: [
            ("LEARNING", "brain"),
            ("SYNCING", "arrow.triangle.2.circlepath"),
            ("OPTIMIZING", "gauge.high"),
            ("ENCRYPTING", "lock.fill"),
        ])
    }
    .padding()
    .background(Color.surface)
}
