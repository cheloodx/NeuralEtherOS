import SwiftUI

// MARK: - Main Container View
// Root navigation using TabView with custom Neural Ether styling.

struct MainContainerView: View {
    @EnvironmentObject var orchestrator: NeuralOrchestrator
    @State private var selectedTab: Tab = .dashboard

    enum Tab: String, CaseIterable {
        case dashboard = "SOVEREIGN"
        case forge = "FORGE"
        case search = "SEARCH"
        case security = "VAULT"
        case deploy = "DEPLOY"
        case creator = "CREATOR"

        var icon: String {
            switch self {
            case .dashboard: return "brain.head.profile"
            case .forge: return "bolt.fill"
            case .search: return "magnifyingglass"
            case .security: return "lock.shield"
            case .deploy: return "shippingbox"
            case .creator: return "crown.fill"
            }
        }
    }

    var body: some View {
        ZStack {
            // Global background
            Color.surface
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Content area
                Group {
                    switch selectedTab {
                    case .dashboard:
                        DashboardView()
                    case .forge:
                        CreativeForgeView()
                    case .search:
                        NeuralSearchView()
                    case .security:
                        SecurityVaultView()
                    case .deploy:
                        DeploymentHubView()
                    case .creator:
                        CreatorPanelView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Custom Tab Bar
                customTabBar
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Custom Tab Bar

    private var customTabBar: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.rawValue) { tab in
                tabButton(for: tab)
            }
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.top, Spacing.md)
        .padding(.bottom, Spacing.xl)
        .background(
            Color.surfaceContainerLow
                .ignoresSafeArea(edges: .bottom)
        )
        .overlay(
            // Top ghost border
            Rectangle()
                .fill(Color.outlineVariant.opacity(0.1))
                .frame(height: 1),
            alignment: .top
        )
    }

    private func tabButton(for tab: Tab) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: Spacing.xs) {
                Image(systemName: tab.icon)
                    .font(.system(size: 16))
                    .foregroundColor(selectedTab == tab ? .neuralPrimary : .onSurfaceVariant)

                Text(tab.rawValue)
                    .font(.system(size: 8, weight: .medium, design: .monospaced))
                    .tracking(0.5)
                    .foregroundColor(selectedTab == tab ? .neuralPrimary : .onSurfaceVariant)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.sm)
            .background(
                selectedTab == tab
                    ? Color.neuralPrimary.opacity(0.08)
                    : Color.clear
            )
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    MainContainerView()
        .environmentObject(NeuralOrchestrator.shared)
}
