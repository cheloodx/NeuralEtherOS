import SwiftUI

// MARK: - Neural Trace
// Per DESIGN.md Section 5: "Special App Component"
// A thin 2px line with gradient from primary to tertiary.
// Glows brighter as "confidence" scores increase.

struct NeuralTraceView: View {
    /// Confidence level from 0.0 to 1.0
    var confidence: Double
    /// Whether to animate
    var isAnimating: Bool = true

    @State private var shimmerOffset: CGFloat = -1.0

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                Capsule()
                    .fill(Color.surfaceContainerHighest)
                    .frame(height: 2)

                // Filled trace with gradient
                Capsule()
                    .fill(LinearGradient.neuralTraceGradient)
                    .frame(width: geometry.size.width * CGFloat(confidence), height: 2)
                    .overlay(
                        // Glow effect — brighter at higher confidence
                        Capsule()
                            .fill(Color.neuralPrimary)
                            .blur(radius: 4 + CGFloat(confidence) * 4)
                            .opacity(0.3 + confidence * 0.4)
                            .frame(height: 2)
                    )
                    // Shimmer overlay
                    .overlay(
                        shimmerOverlay(width: geometry.size.width * CGFloat(confidence))
                    )
            }
        }
        .frame(height: 10) // includes glow
        .onAppear {
            guard isAnimating else { return }
            withAnimation(
                .linear(duration: 2.0)
                .repeatForever(autoreverses: false)
            ) {
                shimmerOffset = 2.0
            }
        }
    }

    @ViewBuilder
    private func shimmerOverlay(width: CGFloat) -> some View {
        if isAnimating {
            LinearGradient(
                colors: [
                    .clear,
                    Color.white.opacity(0.3),
                    .clear
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: width * 0.3)
            .offset(x: width * shimmerOffset)
            .clipped()
        }
    }
}

// MARK: - Neural Trace with Label

struct LabeledNeuralTrace: View {
    var label: String
    var confidence: Double
    var showPercentage: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Text(label)
                    .font(NeuralFont.labelMedium())
                    .foregroundColor(.onSurfaceVariant)

                Spacer()

                if showPercentage {
                    Text("\(Int(confidence * 100))%")
                        .font(NeuralFont.monoSmall())
                        .foregroundColor(.neuralPrimary)
                }
            }

            NeuralTraceView(confidence: confidence)
        }
    }
}

#Preview {
    VStack(spacing: 30) {
        LabeledNeuralTrace(label: "LEARNING_CONFIDENCE", confidence: 0.72)
        LabeledNeuralTrace(label: "SYNC_INTEGRITY", confidence: 0.924)
        LabeledNeuralTrace(label: "NEURAL_GROWTH", confidence: 0.45)
    }
    .padding()
    .background(Color.surface)
}
