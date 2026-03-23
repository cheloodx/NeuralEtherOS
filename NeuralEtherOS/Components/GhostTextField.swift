import SwiftUI

// MARK: - Ghost Text Field
// Per DESIGN.md Section 5: "Input Fields"
// Ghost style: only bottom-border (1px) using outline-variant at 20%.
// Focused: border glows primary, surface-bright wash fills background.

struct GhostTextField: View {
    var placeholder: String
    @Binding var text: String
    var icon: String?
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: Spacing.md) {
            // Optional leading icon
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(isFocused ? .neuralPrimary : .onSurfaceVariant)
            }

            // Text field
            TextField("", text: $text, prompt: promptText)
                .font(NeuralFont.bodyMedium())
                .foregroundColor(.onSurface)
                .focused($isFocused)
                .textFieldStyle(PlainTextFieldStyle())
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
        .background(
            // Surface-bright wash when focused
            Color.surfaceBright
                .opacity(isFocused ? 1.0 : 0.0)
                .animation(.easeInOut(duration: 0.2), value: isFocused)
        )
        .overlay(
            // Bottom border only
            VStack {
                Spacer()
                Rectangle()
                    .fill(isFocused ? Color.neuralPrimary : Color.outlineVariant.opacity(0.2))
                    .frame(height: 1)
                    .shadow(
                        color: isFocused ? Color.neuralPrimary.opacity(0.4) : .clear,
                        radius: isFocused ? 4 : 0,
                        y: 0
                    )
            }
        )
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }

    private var promptText: Text {
        Text(placeholder)
            .font(NeuralFont.bodyMedium())
            .foregroundColor(.onSurfaceVariant.opacity(0.5))
    }
}

#Preview {
    VStack(spacing: 30) {
        GhostTextField(
            placeholder: "ENTER_SEARCH_QUERY",
            text: .constant(""),
            icon: "magnifyingglass"
        )
        GhostTextField(
            placeholder: "NODE_ADDRESS",
            text: .constant("192.168.1.42"),
            icon: "network"
        )
        GhostTextField(
            placeholder: "API_KEY",
            text: .constant("")
        )
    }
    .padding()
    .background(Color.surface)
}
