import SwiftUI

// MARK: - Insight Card
// Per DESIGN.md Section 5: "The Insight Card"
// No divider lines. Uses spacing-8 (2rem) vertical whitespace to separate sections.
// surface-container-low with glassmorphism blur.

struct InsightCard<Content: View>: View {
    var title: String?
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xxxl) {
            if let title {
                Text(title)
                    .font(NeuralFont.headlineMedium())
                    .foregroundColor(.onSurface)
            }

            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.xxl)
        .glassmorphism(cornerRadius: CornerRadius.lg)
    }
}

// MARK: - Metric Insight Card (with key-value pairs)

struct MetricInsightCard: View {
    var title: String
    var metrics: [(key: String, value: String)]
    var accentColor: Color = .neuralPrimary

    var body: some View {
        InsightCard(title: title) {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                ForEach(Array(metrics.enumerated()), id: \.offset) { _, metric in
                    HStack {
                        Text(metric.key)
                            .font(NeuralFont.monoMedium())
                            .foregroundColor(.onSurfaceVariant)

                        Spacer()

                        Text(metric.value)
                            .font(NeuralFont.monoMedium())
                            .foregroundColor(accentColor)
                    }
                }
            }
        }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 20) {
            InsightCard(title: "BRAIN_METRICS") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Neural pathways: 1,247,892")
                        .font(NeuralFont.monoMedium())
                        .foregroundColor(.onSurfaceVariant)
                    Text("Active threads: 42")
                        .font(NeuralFont.monoMedium())
                        .foregroundColor(.onSurfaceVariant)
                }
            }

            MetricInsightCard(
                title: "SYSTEM_STATUS",
                metrics: [
                    ("CPU_LOAD", "23%"),
                    ("MEMORY", "4.2GB"),
                    ("THREADS", "42"),
                    ("UPTIME", "72h 14m")
                ]
            )
        }
        .padding()
    }
    .background(Color.surface)
}
