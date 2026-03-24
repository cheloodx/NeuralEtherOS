import SwiftUI

// MARK: - Creator Panel View
// Admin/Creator exclusive controls: +18 content, WiFi access, Webcam access.

struct CreatorPanelView: View {
    @EnvironmentObject var orchestrator: NeuralOrchestrator
    @State private var isAuthenticated: Bool = false
    @State private var accessCode: String = ""
    @State private var showAccessDenied: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xxl) {
                headerSection

                if isAuthenticated {
                    controlsSection
                    permissionsSection
                    sessionInfoSection
                } else {
                    authenticationSection
                }
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.top, Spacing.xxl)
            .padding(.bottom, Spacing.massive)
        }
        .background(Color.surface)
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Image(systemName: "crown.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.neuralWarning)

                Text("CREATOR_PANEL")
                    .font(NeuralFont.displaySmall())
                    .foregroundColor(.onSurface)
            }

            Text(isAuthenticated
                ? "Full administrative control active."
                : "Restricted access — authentication required.")
                .font(NeuralFont.bodyMedium())
                .foregroundColor(.onSurfaceVariant)
        }
    }

    // MARK: - Authentication

    private var authenticationSection: some View {
        InsightCard(title: "ACCESS_CONTROL") {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                Text("Enter your creator access code to unlock administrative controls.")
                    .font(NeuralFont.bodyMedium())
                    .foregroundColor(.onSurfaceVariant)

                HStack(spacing: Spacing.md) {
                    Image(systemName: "key.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.neuralWarning)

                    SecureField("", text: $accessCode, prompt: Text("CREATOR_ACCESS_CODE")
                        .foregroundColor(.onSurfaceVariant.opacity(0.5)))
                        .font(NeuralFont.monoMedium())
                        .foregroundColor(.onSurface)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.vertical, Spacing.md)
                .background(Color.surfaceBright)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))

                if showAccessDenied {
                    HStack(spacing: Spacing.sm) {
                        Image(systemName: "xmark.octagon.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.neuralError)
                        Text("ACCESS_DENIED — Invalid code.")
                            .font(NeuralFont.monoSmall())
                            .foregroundColor(.neuralError)
                    }
                }

                Button {
                    authenticateCreator()
                } label: {
                    HStack {
                        Image(systemName: "lock.open.fill")
                        Text("AUTHENTICATE")
                    }
                }
                .buttonStyle(NeuralButtonStyle(variant: .primary))
            }
        }
    }

    // MARK: - Controls

    private var controlsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            sectionHeader("CONTENT_CONTROLS")

            // +18 Content Toggle
            creatorToggle(
                icon: "exclamationmark.shield.fill",
                title: "ADULT_CONTENT (+18)",
                subtitle: "Enable or disable adult content filtering across all modules.",
                isOn: $orchestrator.adultContentEnabled,
                accentColor: .neuralError
            )

            // WiFi Access Toggle
            creatorToggle(
                icon: "wifi",
                title: "WIFI_ACCESS_CONTROL",
                subtitle: "Grant or revoke WiFi network scanning and connection management.",
                isOn: $orchestrator.wifiAccessEnabled,
                accentColor: .neuralPrimary
            )

            // Webcam Access Toggle
            creatorToggle(
                icon: "web.camera.fill",
                title: "WEBCAM_ACCESS",
                subtitle: "Enable or disable access to connected web cameras and streams.",
                isOn: $orchestrator.webcamAccessEnabled,
                accentColor: .neuralTertiary
            )
        }
    }

    // MARK: - Permissions Overview

    private var permissionsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            sectionHeader("ACTIVE_PERMISSIONS")

            InsightCard {
                VStack(spacing: Spacing.lg) {
                    permissionRow(
                        icon: "exclamationmark.shield.fill",
                        label: "ADULT_CONTENT",
                        status: orchestrator.adultContentEnabled,
                        color: .neuralError
                    )
                    permissionRow(
                        icon: "wifi",
                        label: "WIFI_SCANNING",
                        status: orchestrator.wifiAccessEnabled,
                        color: .neuralPrimary
                    )
                    permissionRow(
                        icon: "web.camera.fill",
                        label: "WEBCAM_STREAM",
                        status: orchestrator.webcamAccessEnabled,
                        color: .neuralTertiary
                    )
                    permissionRow(
                        icon: "lock.shield",
                        label: "PANIC_PROTOCOL",
                        status: !orchestrator.isPanicActive,
                        color: .neuralSuccess
                    )
                    permissionRow(
                        icon: "shippingbox",
                        label: "DEPLOYMENT",
                        status: orchestrator.deploymentStatus != .locked,
                        color: .neuralWarning
                    )
                }
            }
        }
    }

    // MARK: - Session Info

    private var sessionInfoSection: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            sectionHeader("SESSION_INFO")

            InsightCard {
                VStack(alignment: .leading, spacing: Spacing.md) {
                    infoRow("ROLE", "CREATOR / ADMIN")
                    infoRow("ACCESS_LEVEL", "SOVEREIGN")
                    infoRow("SESSION_ID", "NE-\(String(format: "%06X", Int.random(in: 0...16777215)))")
                    infoRow("ENCRYPTION", "QUANTUM_AES_512")
                    infoRow("STATUS", orchestrator.isPanicActive ? "LOCKED" : "ACTIVE")
                }
            }
        }
    }

    // MARK: - Helpers

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(NeuralFont.monoSmall())
            .foregroundColor(.onSurfaceVariant)
            .tracking(1.5)
    }

    private func creatorToggle(
        icon: String,
        title: String,
        subtitle: String,
        isOn: Binding<Bool>,
        accentColor: Color
    ) -> some View {
        HStack(spacing: Spacing.lg) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(isOn.wrappedValue ? accentColor : .onSurfaceVariant.opacity(0.4))
                .frame(width: 32)

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(title)
                    .font(NeuralFont.headlineSmall())
                    .foregroundColor(.onSurface)

                Text(subtitle)
                    .font(NeuralFont.bodySmall())
                    .foregroundColor(.onSurfaceVariant)
                    .lineLimit(2)
            }

            Spacer()

            Toggle("", isOn: isOn)
                .toggleStyle(NeuralToggleStyle(accentColor: accentColor))
                .labelsHidden()
        }
        .padding(Spacing.lg)
        .glassmorphism(cornerRadius: CornerRadius.lg)
    }

    private func permissionRow(icon: String, label: String, status: Bool, color: Color) -> some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(color)
                .frame(width: 24)

            Text(label)
                .font(NeuralFont.monoMedium())
                .foregroundColor(.onSurfaceVariant)

            Spacer()

            Text(status ? "GRANTED" : "DENIED")
                .font(NeuralFont.monoSmall())
                .foregroundColor(status ? .neuralSuccess : .neuralError)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.xs)
                .background(
                    (status ? Color.neuralSuccess : Color.neuralError).opacity(0.12)
                )
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.full))
        }
    }

    private func infoRow(_ key: String, _ value: String) -> some View {
        HStack {
            Text(key)
                .font(NeuralFont.monoSmall())
                .foregroundColor(.onSurfaceVariant)

            Spacer()

            Text(value)
                .font(NeuralFont.monoSmall())
                .foregroundColor(.neuralPrimary)
        }
    }

    // MARK: - Authentication Logic

    private func authenticateCreator() {
        // For demo: any non-empty code grants access
        if !accessCode.isEmpty {
            withAnimation(.easeInOut(duration: 0.3)) {
                isAuthenticated = true
                showAccessDenied = false
            }
            orchestrator.systemLogs.insert(
                LogEntry(
                    timestamp: Date(),
                    level: .info,
                    module: "AUTH",
                    message: "CREATOR_ACCESS_GRANTED — Sovereign mode activated."
                ),
                at: 0
            )
        } else {
            withAnimation {
                showAccessDenied = true
            }
        }
    }
}

// MARK: - Neural Toggle Style

struct NeuralToggleStyle: ToggleStyle {
    var accentColor: Color = .neuralPrimary

    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            ZStack {
                RoundedRectangle(cornerRadius: CornerRadius.full)
                    .fill(configuration.isOn ? accentColor.opacity(0.3) : Color.surfaceContainerHighest)
                    .frame(width: 50, height: 28)
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.full)
                            .stroke(
                                configuration.isOn ? accentColor.opacity(0.6) : Color.outlineVariant.opacity(0.2),
                                lineWidth: 1
                            )
                    )

                Circle()
                    .fill(configuration.isOn ? accentColor : Color.onSurfaceVariant)
                    .frame(width: 22, height: 22)
                    .shadow(color: configuration.isOn ? accentColor.opacity(0.4) : .clear, radius: 4)
                    .offset(x: configuration.isOn ? 11 : -11)
                    .animation(.easeInOut(duration: 0.2), value: configuration.isOn)
            }
            .onTapGesture {
                configuration.isOn.toggle()
            }
        }
    }
}

#Preview {
    CreatorPanelView()
        .environmentObject(NeuralOrchestrator.shared)
}
