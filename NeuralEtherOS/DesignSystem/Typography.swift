import SwiftUI

// MARK: - Typography System
// "The Editorial Machine" — Space Grotesk (headlines) + Inter (body) + JetBrains Mono (logs)

enum NeuralFont {

    // MARK: - Display & Headlines (Space Grotesk — "Authoritative Voice")

    /// Display Large: 3.5rem (56pt), tight tracking
    static func displayLarge() -> Font {
        .custom("SpaceGrotesk-Bold", size: 56, relativeTo: .largeTitle)
    }

    /// Display Medium: 2.5rem (40pt)
    static func displayMedium() -> Font {
        .custom("SpaceGrotesk-Bold", size: 40, relativeTo: .title)
    }

    /// Display Small: 2rem (32pt)
    static func displaySmall() -> Font {
        .custom("SpaceGrotesk-SemiBold", size: 32, relativeTo: .title2)
    }

    /// Headline Large: 1.5rem (24pt)
    static func headlineLarge() -> Font {
        .custom("SpaceGrotesk-Medium", size: 24, relativeTo: .headline)
    }

    /// Headline Medium: 1.25rem (20pt)
    static func headlineMedium() -> Font {
        .custom("SpaceGrotesk-Medium", size: 20, relativeTo: .headline)
    }

    // MARK: - Body & UI (Inter — functional legibility)

    /// Body Large: 1rem (16pt)
    static func bodyLarge() -> Font {
        .custom("Inter-Regular", size: 16, relativeTo: .body)
    }

    /// Body Medium: 0.875rem (14pt) — primary body text
    static func bodyMedium() -> Font {
        .custom("Inter-Regular", size: 14, relativeTo: .body)
    }

    /// Body Small: 0.75rem (12pt)
    static func bodySmall() -> Font {
        .custom("Inter-Regular", size: 12, relativeTo: .caption)
    }

    // MARK: - Labels

    /// Label Large: 0.875rem (14pt), medium weight
    static func labelLarge() -> Font {
        .custom("Inter-Medium", size: 14, relativeTo: .subheadline)
    }

    /// Label Medium: 0.75rem (12pt)
    static func labelMedium() -> Font {
        .custom("Inter-Medium", size: 12, relativeTo: .caption)
    }

    /// Label Small: 0.6875rem (11pt)
    static func labelSmall() -> Font {
        .custom("Inter-Medium", size: 11, relativeTo: .caption2)
    }

    // MARK: - Monospaced / Logic Accent (JetBrains Mono — "The Agent's Raw Thought")

    /// Mono Large: 14pt — code blocks
    static func monoLarge() -> Font {
        .custom("JetBrainsMono-Regular", size: 14, relativeTo: .body)
    }

    /// Mono Medium: 12pt — logs, memory addresses
    static func monoMedium() -> Font {
        .custom("JetBrainsMono-Regular", size: 12, relativeTo: .caption)
    }

    /// Mono Small: 11pt — timestamps, automation strings
    static func monoSmall() -> Font {
        .custom("JetBrainsMono-Regular", size: 11, relativeTo: .caption2)
    }

    // MARK: - Fallbacks (system fonts if custom fonts not bundled)

    /// Fallback display using system design
    static func systemDisplay() -> Font {
        .system(size: 56, weight: .bold, design: .default)
    }

    static func systemHeadline() -> Font {
        .system(size: 24, weight: .semibold, design: .default)
    }

    static func systemBody() -> Font {
        .system(size: 14, weight: .regular, design: .default)
    }

    static func systemMono() -> Font {
        .system(size: 12, weight: .regular, design: .monospaced)
    }
}

// MARK: - Text Style Modifiers

struct DisplayTextStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(NeuralFont.displayLarge())
            .tracking(-1.12) // -0.02em * 56pt
            .foregroundColor(.onSurface)
    }
}

struct HeadlineTextStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(NeuralFont.headlineLarge())
            .tracking(-0.48) // -0.02em * 24pt
            .foregroundColor(.onSurface)
    }
}

struct MonoLogTextStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(NeuralFont.monoSmall())
            .foregroundColor(.onSurfaceVariant)
    }
}

struct CapsLabelStyle: ViewModifier {
    var spacing: CGFloat = 3

    func body(content: Content) -> some View {
        content
            .font(NeuralFont.labelSmall())
            .tracking(spacing)
            .textCase(.uppercase)
            .foregroundColor(.neuralPrimary)
    }
}

extension View {
    func displayStyle() -> some View { modifier(DisplayTextStyle()) }
    func headlineStyle() -> some View { modifier(HeadlineTextStyle()) }
    func monoLogStyle() -> some View { modifier(MonoLogTextStyle()) }
    func capsLabelStyle(spacing: CGFloat = 3) -> some View { modifier(CapsLabelStyle(spacing: spacing)) }
}
