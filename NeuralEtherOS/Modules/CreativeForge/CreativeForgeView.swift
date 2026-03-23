import SwiftUI

// MARK: - Creative Forge View
// Module 2: AI Generation — handles synthesis of Code, Video, Imagery, Audio, 3D.
// Uses the design system: no divider lines, tonal elevation, gradient actions.

struct CreativeForgeView: View {
    @EnvironmentObject var orchestrator: NeuralOrchestrator
    @State private var searchQuery: String = ""

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: Spacing.xxxl) {

                // MARK: Header
                headerSection

                // MARK: Search
                GhostTextField(
                    placeholder: "SEARCH_SYNTHESIS_MODULES",
                    text: $searchQuery,
                    icon: "magnifyingglass"
                )

                // MARK: Task List
                taskListSection

                // MARK: Synthesis Stats
                synthesisStatsSection
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
            Text("CREATIVE FORGE")
                .font(NeuralFont.displaySmall())
                .tracking(-0.64)
                .foregroundColor(.onSurface)

            Text("AI_SYNTHESIS_ENGINE // \(filteredTasks.count) MODULES")
                .font(NeuralFont.monoSmall())
                .tracking(3)
                .foregroundColor(.neuralPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Task List

    private var filteredTasks: [ForgeTask] {
        if searchQuery.isEmpty {
            return orchestrator.forgeTasks
        }
        return orchestrator.forgeTasks.filter {
            $0.name.localizedCaseInsensitiveContains(searchQuery)
        }
    }

    private var taskListSection: some View {
        VStack(spacing: Spacing.md) {
            ForEach(filteredTasks) { task in
                ForgeTaskRow(task: task) {
                    orchestrator.startForgeTask(id: task.id)
                }
            }
        }
    }

    // MARK: - Synthesis Stats

    private var synthesisStatsSection: some View {
        MetricInsightCard(
            title: "FORGE_METRICS",
            metrics: [
                ("MODULES_ONLINE", "\(orchestrator.forgeTasks.filter { $0.status != .locked }.count)"),
                ("COMPLETED", "\(orchestrator.forgeTasks.filter { $0.status == .completed }.count)"),
                ("IN_PROGRESS", "\(orchestrator.forgeTasks.filter { $0.status == .synthesizing }.count)"),
                ("TOTAL_TEMPLATES", "4,892"),
                ("GPU_ALLOCATION", "87%")
            ]
        )
    }
}

// MARK: - Forge Task Row

struct ForgeTaskRow: View {
    let task: ForgeTask
    var onSynthesize: () -> Void

    var body: some View {
        VStack(spacing: Spacing.md) {
            HStack(spacing: Spacing.lg) {
                // Icon
                Image(systemName: task.icon)
                    .font(.system(size: 20))
                    .foregroundColor(iconColor)
                    .frame(width: 40, height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: CornerRadius.md)
                            .fill(Color.surfaceContainerHighest)
                    )

                // Task info
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(task.name)
                        .font(NeuralFont.monoMedium())
                        .foregroundColor(.onSurface)

                    Text(task.status.label)
                        .font(NeuralFont.monoSmall())
                        .foregroundColor(statusColor)
                }

                Spacer()

                // Action button
                actionButton
            }

            // Progress bar (if synthesizing)
            if task.status == .synthesizing {
                NeuralTraceView(confidence: task.progress, isAnimating: true)
            }
        }
        .padding(Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.lg)
                .fill(Color.surfaceContainerLow)
        )
        .neuralGlowingBorder(isActive: task.status == .synthesizing)
    }

    @ViewBuilder
    private var actionButton: some View {
        switch task.status {
        case .idle:
            Button("SYNTHESIZE", action: onSynthesize)
                .buttonStyle(.neuralPrimary)
        case .synthesizing:
            Text("\(Int(task.progress * 100))%")
                .font(NeuralFont.monoMedium())
                .foregroundColor(.neuralPrimary)
        case .completed:
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 24))
                .foregroundColor(.neuralSuccess)
        case .locked:
            Image(systemName: "lock.fill")
                .font(.system(size: 20))
                .foregroundColor(.neuralError)
        }
    }

    private var iconColor: Color {
        switch task.status {
        case .idle: return .neuralPrimary
        case .synthesizing: return .neuralPrimary
        case .completed: return .neuralSuccess
        case .locked: return .neuralError
        }
    }

    private var statusColor: Color {
        switch task.status {
        case .idle: return .onSurfaceVariant
        case .synthesizing: return .neuralPrimary
        case .completed: return .neuralSuccess
        case .locked: return .neuralError
        }
    }
}

#Preview {
    CreativeForgeView()
        .environmentObject(NeuralOrchestrator.shared)
}
