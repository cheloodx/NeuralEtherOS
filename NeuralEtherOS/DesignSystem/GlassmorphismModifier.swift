import SwiftUI

// MARK: - Glassmorphism
// "Polarized Glass" effect per DESIGN.md:
// surface-variant at 60% opacity + backdrop-blur 20px

struct GlassmorphismModifier: ViewModifier {
    var cornerRadius: CGFloat = CornerRadius.lg
    var opacity: Double = 0.6
    var blurRadius: CGFloat = 20

    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    // Frosted glass layer
                    Color.surfaceVariant
                        .opacity(opacity)

                    // Simulated blur backdrop (SwiftUI uses .ultraThinMaterial)
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(.ultraThinMaterial)
                        .opacity(0.3)
                }
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

// MARK: - Ghost Border Modifier
// "Whisper" boundary — outline-variant at 15% opacity

struct GhostBorderModifier: ViewModifier {
    var cornerRadius: CGFloat = CornerRadius.lg

    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.outlineVariant.opacity(0.15), lineWidth: 1)
            )
    }
}

// MARK: - Surface Card Modifier
// Tonal elevation: surface-container-low background with no borders

struct SurfaceCardModifier: ViewModifier {
    var level: SurfaceLevel = .low

    enum SurfaceLevel {
        case lowest, low, high, highest

        var color: Color {
            switch self {
            case .lowest: return .surfaceContainerLowest
            case .low: return .surfaceContainerLow
            case .high: return .surfaceContainerHighest
            case .highest: return .surfaceContainerHighest
            }
        }
    }

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.lg)
                    .fill(level.color)
            )
    }
}

// MARK: - View Extensions

extension View {
    /// Apply glassmorphism effect (floating panels, agent thought-processes)
    func glassmorphism(
        cornerRadius: CGFloat = CornerRadius.lg,
        opacity: Double = 0.6,
        blurRadius: CGFloat = 20
    ) -> some View {
        modifier(GlassmorphismModifier(
            cornerRadius: cornerRadius,
            opacity: opacity,
            blurRadius: blurRadius
        ))
    }

    /// Apply ghost border — barely perceptible boundary
    func ghostBorder(cornerRadius: CGFloat = CornerRadius.lg) -> some View {
        modifier(GhostBorderModifier(cornerRadius: cornerRadius))
    }

    /// Apply tonal surface card — no borders, just color shift
    func surfaceCard(level: SurfaceCardModifier.SurfaceLevel = .low) -> some View {
        modifier(SurfaceCardModifier(level: level))
    }
}
