import SwiftUI

// MARK: - Deployment Hub View
// Module 4: App Store Deployment automation.
// IPA building, progress tracking, and submission.

struct DeploymentHubView: View {
    @EnvironmentObject var orchestrator: NeuralOrchestrator

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: Spacing.xxxl) {

                // MARK: Header
                headerSection

                // MARK: Deployment Status
                deploymentStatusSection

                // MARK: Progress
                progressSection

                // MARK: Build Configuration
                buildConfigSection

                // MARK: Deployment Logs
                deploymentLogsSection
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
            Text("DEPLOYMENT HUB")
                .font(NeuralFont.displaySmall())
                .tracking(-0.64)
                .foregroundColor(.onSurface)

            Text("IPA_BUILD_PIPELINE // APP_STORE_CONNECT")
                .font(NeuralFont.monoSmall())
                .tracking(3)
                .foregroundColor(.neuralPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Deployment Status

    private var deploymentStatusSection: some View {
        VStack(spacing: Spacing.xl) {
            // Status icon
            ZStack {
                Circle()
                    .fill(orchestrator.deploymentStatus.color.opacity(0.1))
                    .frame(width: 100, height: 100)

                Image(systemName: deploymentIcon)
                    .font(.system(size: 40))
                    .foregroundColor(orchestrator.deploymentStatus.color)
                    .symbolEffect(
                        .pulse,
                        isActive: orchestrator.deploymentStatus == .building || orchestrator.deploymentStatus == .uploading
                    )
            }

            // Status label
            Text(orchestrator.deploymentStatus.label)
                .capsLabelStyle()

            // Status chips
            HStack(spacing: Spacing.sm) {
                ProcessChip(
                    label: orchestrator.deploymentStatus.label,
                    icon: "shippingbox",
                    accentColor: orchestrator.deploymentStatus.color,
                    isActive: orchestrator.deploymentStatus != .idle
                )
                ProcessChip(label: "iOS 17.0+", icon: "iphone")
                ProcessChip(label: "RELEASE", icon: "tag")
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var deploymentIcon: String {
        switch orchestrator.deploymentStatus {
        case .idle: return "shippingbox"
        case .building: return "hammer.fill"
        case .uploading: return "icloud.and.arrow.up.fill"
        case .submitted: return "checkmark.circle.fill"
        case .locked: return "lock.fill"
        }
    }

    // MARK: - Progress Section

    private var progressSection: some View {
        VStack(spacing: Spacing.xl) {
            // Progress bar
            VStack(alignment: .leading, spacing: Spacing.sm) {
                HStack {
                    Text(progressLabel)
                        .font(NeuralFont.monoMedium())
                        .foregroundColor(.onSurface)

                    Spacer()

                    Text("\(Int(orchestrator.deploymentProgress * 100))%")
                        .font(NeuralFont.monoMedium())
                        .foregroundColor(.neuralPrimary)
                }

                NeuralTraceView(
                    confidence: orchestrator.deploymentProgress,
                    isAnimating: orchestrator.deploymentStatus == .building || orchestrator.deploymentStatus == .uploading
                )
            }

            // Action button
            deploymentActionButton
        }
        .padding(Spacing.xxl)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.lg)
                .fill(Color.surfaceContainerLow)
        )
    }

    private var progressLabel: String {
        switch orchestrator.deploymentStatus {
        case .idle: return "READY_TO_BUILD"
        case .building: return "BUILDING_IPA_STABLE"
        case .uploading: return "UPLOADING_TO_ASC"
        case .submitted: return "SUBMISSION_COMPLETE"
        case .locked: return "SYSTEM_LOCKED"
        }
    }

    @ViewBuilder
    private var deploymentActionButton: some View {
        switch orchestrator.deploymentStatus {
        case .idle:
            Button {
                orchestrator.startDeployment()
            } label: {
                HStack(spacing: Spacing.sm) {
                    Image(systemName: "arrow.up.circle.fill")
                    Text("PUSH_TO_APP_STORE")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.neuralPrimary)

        case .building, .uploading:
            Button {} label: {
                HStack(spacing: Spacing.sm) {
                    ProgressView()
                        .tint(.onSurfaceVariant)
                    Text("IN_PROGRESS...")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.neuralSecondary)
            .disabled(true)

        case .submitted:
            VStack(spacing: Spacing.md) {
                HStack(spacing: Spacing.sm) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.neuralSuccess)
                    Text("SUBMITTED — AWAITING_REVIEW")
                        .font(NeuralFont.monoMedium())
                        .foregroundColor(.neuralSuccess)
                }

                Button {
                    orchestrator.deploymentStatus = .idle
                    orchestrator.deploymentProgress = 0.0
                } label: {
                    Text("RESET_PIPELINE")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.neuralGhost)
            }

        case .locked:
            HStack(spacing: Spacing.sm) {
                Image(systemName: "lock.fill")
                    .foregroundColor(.neuralError)
                Text("DEPLOYMENT_LOCKED")
                    .font(NeuralFont.monoMedium())
                    .foregroundColor(.neuralError)
            }
        }
    }

    // MARK: - Build Config

    private var buildConfigSection: some View {
        MetricInsightCard(
            title: "BUILD_CONFIGURATION",
            metrics: [
                ("BUNDLE_ID", "com.creator.neuralether.os"),
                ("VERSION", "1.0.0 (42)"),
                ("MIN_TARGET", "iOS 17.0"),
                ("ARCHITECTURE", "arm64"),
                ("SIGNING", "Automatic"),
                ("OPTIMIZATION", "-O (Release)")
            ]
        )
    }

    // MARK: - Deployment Logs

    private var deploymentLogsSection: some View {
        let deployLogs = orchestrator.systemLogs.filter { $0.module == "DEPLOY" }

        return VStack(alignment: .leading, spacing: Spacing.lg) {
            HStack {
                Text("DEPLOYMENT_LOG")
                    .font(NeuralFont.headlineMedium())
                    .foregroundColor(.onSurface)

                Spacer()

                Text("\(deployLogs.count) ENTRIES")
                    .font(NeuralFont.monoSmall())
                    .foregroundColor(.onSurfaceVariant)
            }

            if deployLogs.isEmpty {
                Text("No deployment activity yet.")
                    .font(NeuralFont.bodyMedium())
                    .foregroundColor(.onSurfaceVariant)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, Spacing.xxl)
            } else {
                VStack(spacing: 0) {
                    LogListView(entries: deployLogs, maxEntries: 10)
                }
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
            }
        }
    }
}

#Preview {
    DeploymentHubView()
        .environmentObject(NeuralOrchestrator.shared)
}
