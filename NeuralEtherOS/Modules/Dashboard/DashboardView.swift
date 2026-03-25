import SwiftUI

// MARK: - Dashboard View (The Sovereign Hub)
// Main visualization of the agent's growth, sync level, and real-time stats.
// Per DESIGN.md: asymmetrical layouts, breathing room, "Living Lab" aesthetic.

struct DashboardView: View {
    @EnvironmentObject var orchestrator: NeuralOrchestrator
    @State private var animateRing: Bool = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: Spacing.xxl) {

                // MARK: - Header
                headerSection

                // MARK: - Sync Ring + Quick Stats
                heroSection

                // MARK: - Status Chips
                statusChipsSection

                // MARK: - Real-time Stats Grid
                statsGridSection

                // MARK: - Confidence Scores
                confidenceSection

                // MARK: - System Logs
                logsSection
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.top, Spacing.md)
            .padding(.bottom, Spacing.huge)
        }
        .background(Color.surface)
        .onAppear { withAnimation(.easeInOut(duration: 1.2)) { animateRing = true } }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text("NEURAL ETHER")
                    .font(NeuralFont.displaySmall())
                    .tracking(-0.64)
                    .foregroundColor(.onSurface)

                Text("SOVEREIGN_HUB")
                    .font(NeuralFont.monoSmall())
                    .tracking(3)
                    .foregroundColor(.neuralPrimary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.neuralSuccess)
                        .frame(width: 8, height: 8)
                    Text("LIVE")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(.neuralSuccess)
                }

                Text("v2.6.0")
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .foregroundColor(.onSurfaceVariant.opacity(0.4))
            }
        }
    }

    // MARK: - Hero (Sync Ring + Quick Info)

    private var heroSection: some View {
        VStack(spacing: Spacing.lg) {
            ZStack {
                // Outer glow ring
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [Color.neuralPrimary.opacity(0.15), Color.neuralPrimary.opacity(0.03)],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 2
                    )
                    .frame(width: 220, height: 220)
                    .scaleEffect(animateRing ? 1.0 : 0.9)
                    .opacity(animateRing ? 1.0 : 0.0)

                CircularProgressView(progress: orchestrator.syncLevel)
                    .frame(width: 180, height: 180)
                    .overlay(
                        VStack(spacing: 2) {
                            Text("\(Int(orchestrator.syncLevel * 100))")
                                .font(.system(size: 48, weight: .ultraLight, design: .rounded))
                                .foregroundColor(.onSurface)
                            Text("SYNC %")
                                .font(.system(size: 9, weight: .bold, design: .monospaced))
                                .tracking(3)
                                .foregroundColor(.neuralPrimary)
                        }
                    )
            }

            // Mini stats row under ring
            HStack(spacing: Spacing.xl) {
                miniStat(value: "\(orchestrator.activeNodes)", label: "NODES", icon: "globe")
                miniDivider
                miniStat(value: "\(orchestrator.growthRate / 1000)k", label: "GROWTH", icon: "arrow.up.right")
                miniDivider
                miniStat(value: String(format: "%.2f", orchestrator.latency), label: "MS", icon: "bolt.fill")
            }
            .padding(.horizontal, Spacing.lg)

            Text("NEURAL_HYPER_GROWTH_ACTIVE")
                .capsLabelStyle()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.lg)
    }

    private func miniStat(value: String, label: String, icon: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .foregroundColor(.neuralPrimary.opacity(0.6))
            Text(value)
                .font(.system(size: 20, weight: .light, design: .monospaced))
                .foregroundColor(.onSurface)
            Text(label)
                .font(.system(size: 7, weight: .bold, design: .monospaced))
                .tracking(1.5)
                .foregroundColor(.onSurfaceVariant.opacity(0.4))
        }
    }

    private var miniDivider: some View {
        Rectangle()
            .fill(Color.outlineVariant.opacity(0.1))
            .frame(width: 1, height: 36)
    }

    // MARK: - Status Chips

    private var statusChipsSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.sm) {
                ProcessChip(
                    label: "ONLINE",
                    icon: "circle.fill",
                    accentColor: .neuralSuccess,
                    isActive: true
                )
                ProcessChip(
                    label: "\(orchestrator.activeNodes) NODES",
                    icon: "globe"
                )
                ProcessChip(
                    label: "\(orchestrator.growthRate / 1000)kX GROWTH",
                    icon: "arrow.up.right"
                )
                ProcessChip(
                    label: "QUANTUM_ENC",
                    icon: "lock.fill"
                )
                ProcessChip(
                    label: "47 CENTERS",
                    icon: "server.rack"
                )
                ProcessChip(
                    label: "12M+ SOURCES",
                    icon: "doc.text.magnifyingglass"
                )
            }
        }
    }

    // MARK: - Stats Grid (2x2)

    private var statsGridSection: some View {
        VStack(spacing: Spacing.md) {
            HStack(spacing: Spacing.md) {
                StatBox(
                    label: "COUNTRIES",
                    value: "\(orchestrator.activeNodes)",
                    showGlow: true
                )
                StatBox(
                    label: "VELOCITY",
                    value: "\(orchestrator.growthRate / 1000)kX"
                )
            }
            HStack(spacing: Spacing.md) {
                StatBox(
                    label: "LATENCY",
                    value: String(format: "%.1fms", orchestrator.latency)
                )
                StatBox(
                    label: "DATA CENTERS",
                    value: "47"
                )
            }
        }
    }

    // MARK: - Confidence Scores

    private var sortedConfidenceScores: [(key: String, value: Double)] {
        orchestrator.confidenceScores.sorted(by: { $0.key < $1.key })
    }

    private var confidenceSection: some View {
        InsightCard(title: "CONFIDENCE_VECTORS") {
            VStack(spacing: Spacing.lg) {
                ForEach(Array(sortedConfidenceScores.enumerated()), id: \.offset) { _, entry in
                    LabeledNeuralTrace(
                        label: entry.key,
                        confidence: entry.value
                    )
                }
            }
        }
    }

    // MARK: - System Logs

    private var logsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "list.bullet.rectangle")
                        .font(.system(size: 14))
                        .foregroundColor(.neuralPrimary)
                    Text("SYSTEM_LOG")
                        .font(NeuralFont.headlineMedium())
                        .foregroundColor(.onSurface)
                }

                Spacer()

                Text("\(orchestrator.systemLogs.count) ENTRIES")
                    .font(NeuralFont.monoSmall())
                    .foregroundColor(.onSurfaceVariant)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.surfaceContainerLow)
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.full))
            }

            VStack(spacing: 0) {
                LogListView(entries: orchestrator.systemLogs, maxEntries: 15)
            }
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
        }
    }
}

#Preview {
    DashboardView()
        .environmentObject(NeuralOrchestrator.shared)
}
