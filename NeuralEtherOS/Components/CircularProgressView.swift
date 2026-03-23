import SwiftUI

// MARK: - Circular Progress View
// Animated ring with gradient fill matching Neural Ether design tokens.

struct CircularProgressView: View {
    /// Progress value from 0.0 to 1.0
    var progress: Double
    /// Line width of the ring
    var lineWidth: CGFloat = 8
    /// Whether to show glow effect
    var showGlow: Bool = true

    @State private var animatedProgress: Double = 0

    var body: some View {
        ZStack {
            // Background track ring
            Circle()
                .stroke(
                    Color.surfaceContainerHighest,
                    lineWidth: lineWidth
                )

            // Progress ring with gradient
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    AngularGradient(
                        colors: [
                            Color.neuralPrimaryContainer,
                            Color.neuralPrimary,
                            Color.neuralTertiary,
                            Color.neuralPrimary,
                            Color.neuralPrimaryContainer
                        ],
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360)
                    ),
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))

            // Glow layer
            if showGlow {
                Circle()
                    .trim(from: 0, to: animatedProgress)
                    .stroke(
                        Color.neuralPrimary.opacity(0.3),
                        style: StrokeStyle(
                            lineWidth: lineWidth + 6,
                            lineCap: .round
                        )
                    )
                    .blur(radius: 6)
                    .rotationEffect(.degrees(-90))
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(.easeInOut(duration: 0.6)) {
                animatedProgress = newValue
            }
        }
    }
}

#Preview {
    ZStack {
        Color.surface.ignoresSafeArea()
        CircularProgressView(progress: 0.924)
            .frame(width: 200, height: 200)
            .overlay(
                VStack(spacing: 4) {
                    Text("92%")
                        .font(NeuralFont.displaySmall())
                        .foregroundColor(.onSurface)
                    Text("SYNC_LEVEL")
                        .font(NeuralFont.monoSmall())
                        .tracking(2)
                        .foregroundColor(.neuralPrimary)
                }
            )
    }
}
