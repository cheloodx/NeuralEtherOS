import SwiftUI

// MARK: - Dashboard View (The Sovereign Hub)
// Main visualization of the agent's growth, sync level, and real-time stats.
// Per DESIGN.md: asymmetrical layouts, breathing room, "Living Lab" aesthetic.

struct DashboardView: View {
    @EnvironmentObject var orchestrator: NeuralOrchestrator

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: Spacing.xxxl) {

                // MARK: - Header
                headerSection

                // MARK: - Sync Ring
                syncRingSection

                // MARK: - Status Chips
                statusChipsSection

                // MARK: - Real-time Stats
                statsSection

                // MARK: - Confidence Scores
                confidenceSection

                // MARK: - System Logs
                logsSection
            }
            .padding(.horizontal, Spacing.xl)
            .padding(.top, Spacing.lg)
            .padding(.bottom, Spacing.huge)
        }
        .background(Color.surface)
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("NEURAL ETHER")
                .font(NeuralFont.displaySmall())
                .tracking(-0.64)
                .foregroundColor(.onSurface)

            Text("SOVEREIGN_HUB // SYSTEM_OVERVIEW")
                .font(NeuralFont.monoSmall())
                .tracking(3)
                .foregroundColor(.neuralPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Sync Ring

    private var syncRingSection: some View {
        VStack(spacing: Spacing.xl) {
            CircularProgressView(progress: orchestrator.syncLevel)
                .frame(width: 200, height: 200)
                .overlay(
                    VStack(spacing: 4) {
                        Text("\(Int(orchestrator.syncLevel * 100))%")
                            .font(NeuralFont.displaySmall())
                            .foregroundColor(.onSurface)

                        Text("SYNC_LEVEL")
                            .font(NeuralFont.monoSmall())
                            .tracking(2)
                            .foregroundColor(.neuralPrimary)
                    }
                )

            Text("NEURAL_HYPER_GROWTH_ACTIVE")
                .capsLabelStyle()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.xl)
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
            }
        }
    }

    // MARK: - Stats

    private var statsSection: some View {
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
            StatBox(
                label: "LATENCY",
                value: String(format: "%.2fms", orchestrator.latency)
            )
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
                Text("SYSTEM_LOG")
                    .font(NeuralFont.headlineMedium())
                    .foregroundColor(.onSurface)

                Spacer()

                Text("\(orchestrator.systemLogs.count) ENTRIES")
                    .font(NeuralFont.monoSmall())
                    .foregroundColor(.onSurfaceVariant)
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
