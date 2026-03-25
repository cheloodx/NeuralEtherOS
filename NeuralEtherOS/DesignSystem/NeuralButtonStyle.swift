import SwiftUI

// MARK: - Primary Button Style
// Gradient fill (primary-container → primary), no border, md corner radius
// Per DESIGN.md Section 5: "Action Buttons"

struct NeuralPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(NeuralFont.labelLarge())
            .foregroundColor(.surfaceContainerLowest)
            .padding(.horizontal, Spacing.xl)
            .padding(.vertical, Spacing.md)
            .background(
                LinearGradient.neuralPrimaryGradient
                    .opacity(configuration.isPressed ? 0.7 : 1.0)
            )
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Secondary Button Style
// secondary-container background, on-surface text

struct NeuralSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(NeuralFont.labelLarge())
            .foregroundColor(.onSurface)
            .padding(.horizontal, Spacing.xl)
            .padding(.vertical, Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.md)
                    .fill(Color.secondaryContainer)
                    .opacity(configuration.isPressed ? 0.7 : 1.0)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Tertiary / Ghost Button Style
// No background, on-surface text. Hover → surface-container-high
// Per DESIGN.md: "Ghost style"

struct NeuralGhostButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(NeuralFont.labelLarge())
            .foregroundColor(.onSurface)
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.md)
                    .fill(Color.surfaceContainerHighest)
                    .opacity(configuration.isPressed ? 1.0 : 0.0)
            )
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Danger Button Style
// For panic/destructive actions

struct NeuralDangerButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(NeuralFont.labelLarge())
            .foregroundColor(.neuralError)
            .padding(.horizontal, Spacing.xl)
            .padding(.vertical, Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.lg)
                    .fill(Color.neuralError.opacity(0.12))
            )
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.lg)
                    .stroke(Color.neuralError.opacity(0.3), lineWidth: 1)
                    .blur(radius: 2)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Unified NeuralButtonStyle with variant

struct NeuralButtonStyle: ButtonStyle {
    enum Variant {
        case primary
        case secondary
        case ghost
        case danger
    }

    var variant: Variant = .primary

    func makeBody(configuration: Configuration) -> some View {
        switch variant {
        case .primary:
            configuration.label
                .font(NeuralFont.labelLarge())
                .foregroundColor(.surfaceContainerLowest)
                .padding(.horizontal, Spacing.xl)
                .padding(.vertical, Spacing.md)
                .background(
                    LinearGradient.neuralPrimaryGradient
                        .opacity(configuration.isPressed ? 0.7 : 1.0)
                )
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
                .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
                .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
        case .secondary:
            configuration.label
                .font(NeuralFont.labelLarge())
                .foregroundColor(.onSurface)
                .padding(.horizontal, Spacing.xl)
                .padding(.vertical, Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: CornerRadius.md)
                        .fill(Color.secondaryContainer)
                        .opacity(configuration.isPressed ? 0.7 : 1.0)
                )
                .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
                .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
        case .ghost:
            configuration.label
                .font(NeuralFont.labelLarge())
                .foregroundColor(.onSurface)
                .padding(.horizontal, Spacing.lg)
                .padding(.vertical, Spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: CornerRadius.md)
                        .fill(Color.surfaceContainerHighest)
                        .opacity(configuration.isPressed ? 1.0 : 0.0)
                )
                .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
        case .danger:
            configuration.label
                .font(NeuralFont.labelLarge())
                .foregroundColor(.neuralError)
                .padding(.horizontal, Spacing.xl)
                .padding(.vertical, Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: CornerRadius.lg)
                        .fill(Color.neuralError.opacity(0.12))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.lg)
                        .stroke(Color.neuralError.opacity(0.3), lineWidth: 1)
                        .blur(radius: 2)
                )
                .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
                .opacity(configuration.isPressed ? 0.8 : 1.0)
                .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
        }
    }
}

// MARK: - Button Style Extensions

extension ButtonStyle where Self == NeuralPrimaryButtonStyle {
    static var neuralPrimary: NeuralPrimaryButtonStyle { NeuralPrimaryButtonStyle() }
}

extension ButtonStyle where Self == NeuralSecondaryButtonStyle {
    static var neuralSecondary: NeuralSecondaryButtonStyle { NeuralSecondaryButtonStyle() }
}

extension ButtonStyle where Self == NeuralGhostButtonStyle {
    static var neuralGhost: NeuralGhostButtonStyle { NeuralGhostButtonStyle() }
}

extension ButtonStyle where Self == NeuralDangerButtonStyle {
    static var neuralDanger: NeuralDangerButtonStyle { NeuralDangerButtonStyle() }
}
