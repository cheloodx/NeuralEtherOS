import SwiftUI

// MARK: - Main Container View
// Root navigation with 5 clean tabs — professional iOS tab bar.

struct MainContainerView: View {
    @EnvironmentObject var orchestrator: NeuralOrchestrator
    @State private var selectedTab: Tab = .dashboard

    enum Tab: String, CaseIterable {
        case dashboard = "Home"
        case search = "Search"
        case photo = "Photo"
        case video = "Video"
        case creator = "Creator"

        var icon: String {
            switch self {
            case .dashboard: return "house"
            case .search: return "magnifyingglass"
            case .photo: return "camera"
            case .video: return "film"
            case .creator: return "crown"
            }
        }

        var activeIcon: String {
            switch self {
            case .dashboard: return "house.fill"
            case .search: return "magnifyingglass.circle.fill"
            case .photo: return "camera.fill"
            case .video: return "film.fill"
            case .creator: return "crown.fill"
            }
        }
    }

    var body: some View {
        ZStack {
            Color(hex: "#0A0A1A")
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Group {
                    switch selectedTab {
                    case .dashboard:
                        DashboardView()
                    case .search:
                        NeuralSearchView()
                    case .photo:
                        PhotoEditorView()
                    case .video:
                        VideoEditorView()
                    case .creator:
                        CreatorPanelView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                tabBar
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Professional Tab Bar (5 tabs, evenly spaced)

    private var tabBar: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.rawValue) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: selectedTab == tab ? tab.activeIcon : tab.icon)
                            .font(.system(size: 22, weight: selectedTab == tab ? .semibold : .regular))
                            .foregroundColor(selectedTab == tab ? Color(hex: "#6C63FF") : Color.white.opacity(0.4))
                            .frame(height: 24)

                        Text(tab.rawValue)
                            .font(.system(size: 10, weight: selectedTab == tab ? .semibold : .regular))
                            .foregroundColor(selectedTab == tab ? Color(hex: "#6C63FF") : Color.white.opacity(0.4))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 10)
                    .padding(.bottom, 2)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.bottom, 20)
        .background(
            Color(hex: "#111128")
                .ignoresSafeArea(edges: .bottom)
        )
        .overlay(
            Rectangle()
                .fill(Color.white.opacity(0.06))
                .frame(height: 0.5),
            alignment: .top
        )
    }
}

#Preview {
    MainContainerView()
        .environmentObject(NeuralOrchestrator.shared)
}
