import SwiftUI

// MARK: - Security Vault View
// Module 3: Quantum Security & Panic Mode.
// The ultimate protection layer.
// Follows DESIGN.md: tonal elevation, no 1px borders, atmospheric depth.

struct SecurityVaultView: View {
    @EnvironmentObject var orchestrator: NeuralOrchestrator
    @State private var showPanicConfirmation: Bool = false
    @State private var panicCountdown: Int = 0

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: Spacing.xxxl) {

                // MARK: Header
                headerSection

                // MARK: Security Status
                securityStatusSection

                // MARK: Encryption Metrics
                encryptionMetricsSection

                // MARK: Panic Protocol
                panicSection

                // MARK: Security Logs
                securityLogsSection
            }
            .padding(.horizontal, Spacing.xl)
            .padding(.top, Spacing.lg)
            .padding(.bottom, Spacing.huge)
        }
        .background(Color.surface)
        .alert("PANIC_PROTOCOL", isPresented: $showPanicConfirmation) {
            Button("CANCEL", role: .cancel) { }
            Button("ACTIVATE", role: .destructive) {
                orchestrator.activatePanicProtocol()
            }
        } message: {
            Text("This will lock all systems, halt all operations, and initiate data purge. This action requires manual recovery.")
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("SECURITY VAULT")
                .font(NeuralFont.displaySmall())
                .tracking(-0.64)
                .foregroundColor(.onSurface)

            Text("QUANTUM_ENCRYPTION // PANIC_PROTOCOL")
                .font(NeuralFont.monoSmall())
                .tracking(3)
                .foregroundColor(orchestrator.isPanicActive ? .neuralError : .neuralPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Security Status

    private var securityStatusSection: some View {
        VStack(spacing: Spacing.xl) {
            // Shield icon
            ZStack {
                Circle()
                    .fill(
                        orchestrator.isPanicActive
                            ? Color.neuralError.opacity(0.1)
                            : Color.neuralSuccess.opacity(0.1)
                    )
                    .frame(width: 120, height: 120)

                Image(systemName: orchestrator.isPanicActive ? "lock.shield.fill" : "checkmark.shield.fill")
                    .font(.system(size: 48))
                    .foregroundColor(orchestrator.isPanicActive ? .neuralError : .neuralSuccess)

                // Outer glow ring
                Circle()
                    .stroke(
                        orchestrator.isPanicActive
                            ? Color.neuralError.opacity(0.2)
                            : Color.neuralSuccess.opacity(0.2),
                        lineWidth: 2
                    )
                    .blur(radius: 4)
                    .frame(width: 130, height: 130)
            }

            // Status label
            Text(orchestrator.isPanicActive ? "SYSTEM_LOCKED" : "ALL_SYSTEMS_SECURE")
                .capsLabelStyle()

            // Status chips
            HStack(spacing: Spacing.sm) {
                ProcessChip(
                    label: orchestrator.isPanicActive ? "LOCKED" : "ACTIVE",
                    icon: orchestrator.isPanicActive ? "xmark.circle.fill" : "circle.fill",
                    accentColor: orchestrator.isPanicActive ? .neuralError : .neuralSuccess,
                    isActive: true
                )
                ProcessChip(label: "AES-256", icon: "key.fill")
                ProcessChip(label: "QUANTUM", icon: "atom")
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Encryption Metrics

    private var encryptionMetricsSection: some View {
        MetricInsightCard(
            title: "ENCRYPTION_STATUS",
            metrics: [
                ("ALGORITHM", "AES-256-GCM"),
                ("KEY_ROTATION", "Every 60s"),
                ("INTEGRITY", orchestrator.isPanicActive ? "LOCKED" : "VERIFIED"),
                ("LAST_SCAN", "0.3s ago"),
                ("THREATS_BLOCKED", "2,847"),
                ("CERTIFICATES", "VALID")
            ],
            accentColor: orchestrator.isPanicActive ? .neuralError : .neuralPrimary
        )
    }

    // MARK: - Panic Section

    private var panicSection: some View {
        VStack(spacing: Spacing.xl) {
            if orchestrator.isPanicActive {
                // Locked state — show recovery button
                VStack(spacing: Spacing.lg) {
                    Text("PANIC_PROTOCOL_ACTIVE")
                        .font(NeuralFont.headlineMedium())
                        .foregroundColor(.neuralError)

                    Text("All operations halted. Data purge in progress.")
                        .font(NeuralFont.bodyMedium())
                        .foregroundColor(.onSurfaceVariant)
                        .multilineTextAlignment(.center)

                    Button("INITIATE_RECOVERY") {
                        orchestrator.deactivatePanicProtocol()
                    }
                    .buttonStyle(.neuralSecondary)
                }
            } else {
                // Normal state — show panic button
                VStack(spacing: Spacing.lg) {
                    Text("EMERGENCY_CONTROLS")
                        .font(NeuralFont.headlineMedium())
                        .foregroundColor(.onSurface)

                    Text("Activating panic protocol will lock all systems and initiate data purge.")
                        .font(NeuralFont.bodySmall())
                        .foregroundColor(.onSurfaceVariant)
                        .multilineTextAlignment(.center)

                    Button {
                        showPanicConfirmation = true
                    } label: {
                        HStack(spacing: Spacing.sm) {
                            Image(systemName: "exclamationmark.triangle.fill")
                            Text("ACTIVATE_PANIC_PROTOCOL")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.neuralDanger)
                }
            }
        }
        .padding(Spacing.xxl)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.lg)
                .fill(Color.surfaceContainerLow)
        )
    }

    // MARK: - Security Logs

    private var securityLogsSection: some View {
        let securityLogs = orchestrator.systemLogs.filter {
            $0.module == "SECURITY" || $0.level == .critical || $0.level == .error
        }

        return VStack(alignment: .leading, spacing: Spacing.lg) {
            HStack {
                Text("SECURITY_LOG")
                    .font(NeuralFont.headlineMedium())
                    .foregroundColor(.onSurface)

                Spacer()

                Text("\(securityLogs.count) ENTRIES")
                    .font(NeuralFont.monoSmall())
                    .foregroundColor(.onSurfaceVariant)
            }

            if securityLogs.isEmpty {
                Text("No security events recorded.")
                    .font(NeuralFont.bodyMedium())
                    .foregroundColor(.onSurfaceVariant)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, Spacing.xxl)
            } else {
                VStack(spacing: 0) {
                    LogListView(entries: securityLogs, maxEntries: 10)
                }
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
            }
        }
    }
}

#Preview {
    SecurityVaultView()
        .environmentObject(NeuralOrchestrator.shared)
}
