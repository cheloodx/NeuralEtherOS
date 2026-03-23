import SwiftUI

// MARK: - Color Tokens
// Based on DESIGN.md "The Cognitive Layer" specification

extension Color {
    // MARK: Surface Hierarchy ("Polarized Glass" layers)
    /// Base surface — the void: #0A0E17
    static let surface = Color(hex: "#0A0E17")
    /// Primary containers: #0F131D
    static let surfaceContainerLow = Color(hex: "#0F131D")
    /// Active / Elevated elements: #202633
    static let surfaceContainerHighest = Color(hex: "#202633")
    /// Deep nesting — infinite depth: #000000
    static let surfaceContainerLowest = Color(hex: "#000000")
    /// Glassmorphism base (use at 60% opacity + blur)
    static let surfaceVariant = Color(hex: "#1A1F2E")
    /// Bright wash for focused inputs
    static let surfaceBright = Color(hex: "#2A3040")

    // MARK: Primary Palette
    /// Primary accent: #69DAFF
    static let neuralPrimary = Color(hex: "#69DAFF")
    /// Primary container / gradient start: #00CFFC
    static let neuralPrimaryContainer = Color(hex: "#00CFFC")
    /// Electric blue: #00D1FF
    static let electricBlue = Color(hex: "#00D1FF")

    // MARK: Secondary & Tertiary
    /// Secondary container for chips: #3A485B
    static let secondaryContainer = Color(hex: "#3A485B")
    /// Tertiary accent (warm complement)
    static let neuralTertiary = Color(hex: "#A78BFA")

    // MARK: On-Surface (Text)
    /// High-emphasis text on surface
    static let onSurface = Color(hex: "#E1E3E8")
    /// Medium-emphasis text
    static let onSurfaceVariant = Color(hex: "#8E939E")

    // MARK: Outline
    /// Ghost border at 15% opacity: #444852
    static let outlineVariant = Color(hex: "#444852")

    // MARK: Status Colors
    static let neuralSuccess = Color(hex: "#34D399")
    static let neuralWarning = Color(hex: "#FBBF24")
    static let neuralError = Color(hex: "#F87171")
}

// MARK: - Gradient Tokens

extension LinearGradient {
    /// Signature "powered from within" gradient for primary actions.
    /// primary-container (#00CFFC) → primary (#69DAFF) at 135°
    static let neuralPrimaryGradient = LinearGradient(
        colors: [Color.neuralPrimaryContainer, Color.neuralPrimary],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Neural Trace gradient: primary → tertiary
    static let neuralTraceGradient = LinearGradient(
        colors: [Color.neuralPrimary, Color.neuralTertiary],
        startPoint: .leading,
        endPoint: .trailing
    )
}

// MARK: - Spacing Tokens

enum Spacing {
    static let xs: CGFloat = 4    // spacing-1
    static let sm: CGFloat = 8    // spacing-2
    static let md: CGFloat = 12   // spacing-3
    static let lg: CGFloat = 16   // spacing-4
    static let xl: CGFloat = 20   // spacing-5
    static let xxl: CGFloat = 24  // spacing-6
    static let xxxl: CGFloat = 32 // spacing-8
    static let huge: CGFloat = 40 // spacing-10
    static let massive: CGFloat = 80 // spacing-20
}

// MARK: - Corner Radius Tokens

enum CornerRadius {
    static let sm: CGFloat = 4    // md in design spec (0.25rem)
    static let md: CGFloat = 6    // 0.375rem
    static let lg: CGFloat = 10
    static let xl: CGFloat = 16
    static let full: CGFloat = 100 // pill shape
}

// MARK: - Shadow Tokens

extension View {
    /// Ambient atmospheric glow — tinted with primary color, ultra-diffused
    func neuralAmbientShadow() -> some View {
        self.shadow(
            color: Color.neuralPrimary.opacity(0.04),
            radius: 20,
            x: 0,
            y: 20
        )
    }

    /// Glowing border for active/learning states — fiber-optic edge
    func neuralGlowingBorder(isActive: Bool = true) -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: CornerRadius.lg)
                .stroke(Color.neuralPrimary.opacity(isActive ? 0.6 : 0), lineWidth: 1)
                .blur(radius: 4)
        )
    }
}
