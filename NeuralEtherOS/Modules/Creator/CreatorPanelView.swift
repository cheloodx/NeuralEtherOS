import SwiftUI

// MARK: - Creator Panel View
// Advanced Creator Control Center with 100% access.
// Access code: "test123"
// Features: +18, WiFi Scanner, Webcam, Network Monitor, Device Manager, Content Filter, System Override, Activity Log

struct CreatorPanelView: View {
    @EnvironmentObject var orchestrator: NeuralOrchestrator
    @State private var isAuthenticated: Bool = false
    @State private var accessCode: String = ""
    @State private var showAccessDenied: Bool = false
    @State private var authAnimating: Bool = false
    @State private var selectedTab: Int = 0

    // WiFi
    @State private var isScanning: Bool = false
    @State private var wifiNetworks: [WiFiNetwork] = WiFiNetwork.mockNetworks

    // Webcam
    @State private var selectedCamera: Int = 0
    @State private var isRecording: Bool = false
    @State private var cameraZoom: Double = 1.0

    // Network Monitor
    @State private var networkTraffic: Double = 0.0
    @State private var trafficTimer: Timer? = nil

    // Activity Log
    @State private var activityLog: [ActivityEntry] = ActivityEntry.initial

    private let cameras = [
        ("Front Camera", "faceid"),
        ("Rear Camera", "camera.fill"),
        ("External USB", "web.camera.fill"),
    ]

    private let creatorTabs = [
        ("shield.fill", "CONTROLS"),
        ("network", "NETWORK"),
        ("desktopcomputer", "DEVICES"),
        ("line.3.horizontal.decrease.circle", "FILTERS"),
        ("gearshape.2.fill", "OVERRIDE"),
        ("list.bullet.rectangle", "LOG"),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xxl) {
                headerSection

                if isAuthenticated {
                    tabSelector
                    tabContent
                } else {
                    authenticationSection
                }
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.top, Spacing.xxl)
            .padding(.bottom, Spacing.massive)
        }
        .background(Color.surface)
        .onDisappear {
            trafficTimer?.invalidate()
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack(spacing: Spacing.md) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.neuralWarning, Color.neuralError],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                    Image(systemName: "crown.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("CREATOR COMMAND CENTER")
                        .font(NeuralFont.displaySmall())
                        .foregroundColor(.onSurface)
                    Text(isAuthenticated
                        ? "SOVEREIGN ACCESS \u{2014} 100% CONTROL ACTIVE"
                        : "RESTRICTED \u{2014} Authentication Required")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(isAuthenticated ? .neuralSuccess : .neuralWarning)
                }
                Spacer()
            }

            if isAuthenticated {
                HStack(spacing: Spacing.lg) {
                    statBadge(value: "100%", label: "ACCESS", color: .neuralSuccess)
                    statBadge(value: "6", label: "MODULES", color: .neuralPrimary)
                    statBadge(value: "\(orchestrator.activeNodes)", label: "NODES", color: .neuralTertiary)
                    statBadge(value: "LIVE", label: "STATUS", color: .neuralWarning)
                }
            }
        }
    }

    private func statBadge(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 7, weight: .medium, design: .monospaced))
                .foregroundColor(.onSurfaceVariant.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.sm)
        .background(color.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
    }

    // MARK: - Authentication

    private var authenticationSection: some View {
        VStack(spacing: Spacing.xl) {
            // Lock icon
            ZStack {
                Circle()
                    .fill(Color.neuralWarning.opacity(0.08))
                    .frame(width: 80, height: 80)
                Circle()
                    .fill(Color.neuralWarning.opacity(0.15))
                    .frame(width: 60, height: 60)
                Image(systemName: authAnimating ? "lock.open.fill" : "lock.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.neuralWarning)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, Spacing.xl)

            Text("CREATOR AUTHENTICATION")
                .font(NeuralFont.headlineSmall())
                .foregroundColor(.onSurface)
                .frame(maxWidth: .infinity)

            Text("Enter your creator access code to unlock\nfull administrative control over all systems.")
                .font(NeuralFont.bodyMedium())
                .foregroundColor(.onSurfaceVariant)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)

            // Code input
            VStack(spacing: Spacing.md) {
                HStack(spacing: Spacing.md) {
                    Image(systemName: "key.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.neuralWarning)

                    SecureField("", text: $accessCode, prompt: Text("ACCESS_CODE")
                        .foregroundColor(.onSurfaceVariant.opacity(0.4)))
                        .font(.system(size: 16, weight: .medium, design: .monospaced))
                        .foregroundColor(.onSurface)
                        .textFieldStyle(PlainTextFieldStyle())
                        .onSubmit { authenticateCreator() }
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.vertical, Spacing.lg)
                .background(Color.surfaceContainerLow)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.lg)
                        .stroke(
                            showAccessDenied ? Color.neuralError.opacity(0.5) : Color.outlineVariant.opacity(0.1),
                            lineWidth: 1
                        )
                )

                if showAccessDenied {
                    HStack(spacing: Spacing.sm) {
                        Image(systemName: "xmark.octagon.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.neuralError)
                        Text("ACCESS DENIED \u{2014} Invalid code.")
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundColor(.neuralError)
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(.horizontal, Spacing.lg)

            Button { authenticateCreator() } label: {
                HStack(spacing: Spacing.sm) {
                    Image(systemName: "lock.open.fill")
                        .font(.system(size: 16))
                    Text("AUTHENTICATE")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                }
                .foregroundColor(.surface)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.lg)
                .background(
                    LinearGradient(
                        colors: [Color.neuralWarning, Color.neuralError],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, Spacing.lg)

            // Hint
            HStack(spacing: Spacing.sm) {
                Image(systemName: "info.circle")
                    .font(.system(size: 12))
                Text("Only the creator can access this panel.")
                    .font(.system(size: 10, design: .monospaced))
            }
            .foregroundColor(.onSurfaceVariant.opacity(0.4))
        }
        .padding(.vertical, Spacing.xl)
        .background(Color.surfaceContainerLow.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.xl))
    }

    // MARK: - Tab Selector

    private var tabSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.sm) {
                ForEach(Array(creatorTabs.enumerated()), id: \.offset) { index, tab in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) { selectedTab = index }
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: tab.0)
                                .font(.system(size: 11))
                            Text(tab.1)
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                        }
                        .foregroundColor(selectedTab == index ? .surface : .onSurfaceVariant)
                        .padding(.horizontal, Spacing.md)
                        .padding(.vertical, 8)
                        .background(
                            selectedTab == index
                                ? LinearGradient(colors: [Color.neuralWarning, Color.neuralError], startPoint: .leading, endPoint: .trailing)
                                : LinearGradient(colors: [Color.surfaceContainerLow, Color.surfaceContainerLow], startPoint: .leading, endPoint: .trailing)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.full))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case 0: controlsTab
        case 1: networkMonitorTab
        case 2: deviceManagerTab
        case 3: contentFilterTab
        case 4: systemOverrideTab
        case 5: activityLogTab
        default: controlsTab
        }
    }

    // MARK: - Tab 0: Controls (Main toggles + panels)

    private var controlsTab: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            sectionHeader("SOVEREIGN CONTROLS", icon: "shield.fill")

            creatorToggle(
                icon: "exclamationmark.shield.fill",
                title: "+18 ADULT CONTENT",
                subtitle: "Unlock age-restricted content across all modules",
                isOn: $orchestrator.adultContentEnabled,
                accentColor: .neuralError
            )

            creatorToggle(
                icon: "wifi",
                title: "WIFI NETWORK SCANNER",
                subtitle: "Scan and monitor nearby WiFi networks",
                isOn: $orchestrator.wifiAccessEnabled,
                accentColor: .neuralPrimary
            )

            creatorToggle(
                icon: "web.camera.fill",
                title: "WEBCAM ACCESS",
                subtitle: "Access camera feeds with capture and record",
                isOn: $orchestrator.webcamAccessEnabled,
                accentColor: .neuralTertiary
            )

            if orchestrator.adultContentEnabled { adultContentPanel }
            if orchestrator.wifiAccessEnabled { wifiScannerPanel }
            if orchestrator.webcamAccessEnabled { webcamFeedPanel }

            permissionsSection
            sessionInfoSection
        }
    }

    // MARK: - Tab 1: Network Monitor

    private var networkMonitorTab: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            sectionHeader("NETWORK TRAFFIC MONITOR", icon: "network")

            InsightCard {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("REAL-TIME TRAFFIC")
                                .font(NeuralFont.headlineSmall())
                                .foregroundColor(.neuralPrimary)
                            Text("Monitoring all \(orchestrator.activeNodes) nodes")
                                .font(NeuralFont.bodySmall())
                                .foregroundColor(.onSurfaceVariant)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("\(String(format: "%.1f", Double.random(in: 2.5...8.5))) GB/s")
                                .font(.system(size: 16, weight: .bold, design: .monospaced))
                                .foregroundColor(.neuralPrimary)
                            Text("THROUGHPUT")
                                .font(.system(size: 7, weight: .medium, design: .monospaced))
                                .foregroundColor(.onSurfaceVariant.opacity(0.5))
                        }
                    }

                    // Traffic bars (simulated)
                    VStack(spacing: Spacing.sm) {
                        trafficRow(region: "Europe", percent: Double.random(in: 0.6...0.95), color: .neuralPrimary)
                        trafficRow(region: "Americas", percent: Double.random(in: 0.5...0.85), color: .neuralTertiary)
                        trafficRow(region: "Asia-Pacific", percent: Double.random(in: 0.7...0.98), color: .neuralWarning)
                        trafficRow(region: "Africa", percent: Double.random(in: 0.2...0.5), color: .neuralSuccess)
                        trafficRow(region: "Middle East", percent: Double.random(in: 0.3...0.6), color: .neuralError)
                    }

                    // Stats grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.md) {
                        networkStat(label: "TOTAL REQUESTS", value: "\(Int.random(in: 1_200_000...3_500_000))", icon: "arrow.up.arrow.down")
                        networkStat(label: "AVG LATENCY", value: "\(String(format: "%.1f", orchestrator.latency))ms", icon: "clock")
                        networkStat(label: "UPTIME", value: "99.97%", icon: "checkmark.circle")
                        networkStat(label: "ACTIVE CONN", value: "\(Int.random(in: 45_000...120_000))", icon: "link")
                        networkStat(label: "BANDWIDTH", value: "\(Int.random(in: 50...120)) TB/day", icon: "arrow.down.circle")
                        networkStat(label: "CDN NODES", value: "47", icon: "server.rack")
                    }
                }
            }

            InsightCard(title: "FIREWALL STATUS") {
                VStack(spacing: Spacing.md) {
                    firewallRow(name: "DDoS Protection", status: "ACTIVE", color: .neuralSuccess)
                    firewallRow(name: "Rate Limiter", status: "ACTIVE", color: .neuralSuccess)
                    firewallRow(name: "Geo-Blocking", status: "CONFIGURED", color: .neuralWarning)
                    firewallRow(name: "SSL/TLS", status: "AES-512", color: .neuralSuccess)
                    firewallRow(name: "Intrusion Detection", status: "MONITORING", color: .neuralPrimary)
                }
            }
        }
    }

    private func trafficRow(region: String, percent: Double, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack {
                Text(region)
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundColor(.onSurface)
                Spacer()
                Text("\(Int(percent * 100))%")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(color)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(color.opacity(0.1))
                        .frame(height: 6)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(color)
                        .frame(width: geo.size.width * percent, height: 6)
                }
            }
            .frame(height: 6)
        }
    }

    private func networkStat(label: String, value: String, icon: String) -> some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(.neuralPrimary.opacity(0.6))
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 1) {
                Text(value)
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(.onSurface)
                Text(label)
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.onSurfaceVariant.opacity(0.5))
            }
            Spacer()
        }
        .padding(Spacing.sm)
        .background(Color.surfaceBright.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
    }

    private func firewallRow(name: String, status: String, color: Color) -> some View {
        HStack {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(name)
                .font(NeuralFont.monoMedium())
                .foregroundColor(.onSurface)
            Spacer()
            Text(status)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(color)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(color.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.full))
        }
    }

    // MARK: - Tab 2: Device Manager

    private var deviceManagerTab: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            sectionHeader("CONNECTED DEVICES", icon: "desktopcomputer")

            InsightCard {
                VStack(spacing: Spacing.md) {
                    deviceRow(name: "Creator iPhone 15 Pro", type: "smartphone", status: "ONLINE", ip: "192.168.1.10", lastSeen: "Now")
                    deviceRow(name: "MacBook Pro M3", type: "laptop", status: "ONLINE", ip: "192.168.1.2", lastSeen: "Now")
                    deviceRow(name: "iPad Air", type: "tablet", status: "ONLINE", ip: "192.168.1.15", lastSeen: "Now")
                    deviceRow(name: "Apple Watch Ultra", type: "watch", status: "ONLINE", ip: "192.168.1.22", lastSeen: "2 min ago")
                    deviceRow(name: "HomePod Mini", type: "speaker", status: "IDLE", ip: "192.168.1.30", lastSeen: "15 min ago")
                    deviceRow(name: "Apple TV 4K", type: "tv", status: "OFFLINE", ip: "192.168.1.40", lastSeen: "2 hours ago")
                }
            }

            InsightCard(title: "DEVICE STATISTICS") {
                VStack(spacing: Spacing.md) {
                    HStack {
                        Text("Total Devices")
                            .font(NeuralFont.monoMedium())
                            .foregroundColor(.onSurface)
                        Spacer()
                        Text("6")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(.neuralPrimary)
                    }
                    HStack {
                        Text("Online")
                            .font(NeuralFont.monoMedium())
                            .foregroundColor(.onSurface)
                        Spacer()
                        Text("4")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(.neuralSuccess)
                    }
                    HStack {
                        Text("Idle")
                            .font(NeuralFont.monoMedium())
                            .foregroundColor(.onSurface)
                        Spacer()
                        Text("1")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(.neuralWarning)
                    }
                    HStack {
                        Text("Offline")
                            .font(NeuralFont.monoMedium())
                            .foregroundColor(.onSurface)
                        Spacer()
                        Text("1")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(.onSurfaceVariant.opacity(0.5))
                    }
                }
            }
        }
    }

    private func deviceRow(name: String, type: String, status: String, ip: String, lastSeen: String) -> some View {
        let icon: String = {
            switch type {
            case "smartphone": return "iphone"
            case "laptop": return "laptopcomputer"
            case "tablet": return "ipad"
            case "watch": return "applewatch"
            case "speaker": return "homepodmini"
            case "tv": return "appletv"
            default: return "desktopcomputer"
            }
        }()
        let color: Color = status == "ONLINE" ? .neuralSuccess : status == "IDLE" ? .neuralWarning : .onSurfaceVariant.opacity(0.4)

        return HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(NeuralFont.monoMedium())
                    .foregroundColor(.onSurface)
                HStack(spacing: Spacing.sm) {
                    Text(ip)
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(.onSurfaceVariant.opacity(0.5))
                    Text(lastSeen)
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(.onSurfaceVariant.opacity(0.5))
                }
            }
            Spacer()
            Text(status)
                .font(.system(size: 8, weight: .bold, design: .monospaced))
                .foregroundColor(color)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(color.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.full))
        }
        .padding(.vertical, Spacing.xs)
    }

    // MARK: - Tab 3: Content Filter

    private var contentFilterTab: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            sectionHeader("CONTENT FILTER ENGINE", icon: "line.3.horizontal.decrease.circle")

            InsightCard {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    Text("Configure what content is visible to users across all modules.")
                        .font(NeuralFont.bodyMedium())
                        .foregroundColor(.onSurfaceVariant)

                    filterRow(name: "Violence", level: "BLOCKED", color: .neuralError)
                    filterRow(name: "Adult Content (+18)", level: orchestrator.adultContentEnabled ? "ALLOWED" : "BLOCKED", color: orchestrator.adultContentEnabled ? .neuralSuccess : .neuralError)
                    filterRow(name: "Gambling", level: "BLOCKED", color: .neuralError)
                    filterRow(name: "Drugs", level: "BLOCKED", color: .neuralError)
                    filterRow(name: "Hate Speech", level: "BLOCKED", color: .neuralError)
                    filterRow(name: "Spam", level: "FILTERED", color: .neuralWarning)
                    filterRow(name: "Political", level: "ALLOWED", color: .neuralSuccess)
                    filterRow(name: "Religious", level: "ALLOWED", color: .neuralSuccess)
                    filterRow(name: "News", level: "ALLOWED", color: .neuralSuccess)
                    filterRow(name: "Social Media", level: "ALLOWED", color: .neuralSuccess)

                    HStack(spacing: Spacing.sm) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 12))
                        Text("As creator, you control all content filters for all users.")
                            .font(.system(size: 10, design: .monospaced))
                    }
                    .foregroundColor(.neuralWarning.opacity(0.8))
                    .padding(Spacing.md)
                    .background(Color.neuralWarning.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
                }
            }
        }
    }

    private func filterRow(name: String, level: String, color: Color) -> some View {
        HStack {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(name)
                .font(NeuralFont.monoMedium())
                .foregroundColor(.onSurface)
            Spacer()
            Text(level)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(color)
                .padding(.horizontal, 10)
                .padding(.vertical, 3)
                .background(color.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.full))
        }
    }

    // MARK: - Tab 4: System Override

    private var systemOverrideTab: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            sectionHeader("SYSTEM OVERRIDE CONTROLS", icon: "gearshape.2.fill")

            InsightCard {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    HStack(spacing: Spacing.sm) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.neuralError)
                        Text("DANGER ZONE \u{2014} Creator-only system overrides")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(.neuralError)
                    }

                    overrideRow(name: "Force Sync All Nodes", description: "Re-sync all \(orchestrator.activeNodes) nodes immediately", icon: "arrow.triangle.2.circlepath", color: .neuralPrimary)
                    overrideRow(name: "Clear All Caches", description: "Purge cached data across 47 data centers", icon: "trash", color: .neuralWarning)
                    overrideRow(name: "Reset User Sessions", description: "Force logout all connected users", icon: "person.crop.circle.badge.xmark", color: .neuralError)
                    overrideRow(name: "Emergency Shutdown", description: "Panic protocol \u{2014} shut down all services", icon: "power", color: .neuralError)
                    overrideRow(name: "Rebuild Search Index", description: "Re-index all 12M+ sources from scratch", icon: "magnifyingglass", color: .neuralTertiary)
                    overrideRow(name: "Rotate Encryption Keys", description: "Generate new AES-512 keys for all traffic", icon: "key.fill", color: .neuralWarning)
                }
            }

            InsightCard(title: "SYSTEM PERFORMANCE") {
                VStack(spacing: Spacing.md) {
                    performanceRow(name: "CPU Usage", value: "\(Int.random(in: 15...45))%", color: .neuralPrimary)
                    performanceRow(name: "Memory", value: "\(Int.random(in: 40...75))%", color: .neuralTertiary)
                    performanceRow(name: "Storage", value: "\(Int.random(in: 30...60))%", color: .neuralWarning)
                    performanceRow(name: "GPU Cluster", value: "\(Int.random(in: 20...55))%", color: .neuralSuccess)
                    performanceRow(name: "Network I/O", value: "\(Int.random(in: 50...85))%", color: .neuralPrimary)
                }
            }
        }
    }

    private func overrideRow(name: String, description: String, icon: String, color: Color) -> some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(NeuralFont.monoMedium())
                    .foregroundColor(.onSurface)
                Text(description)
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundColor(.onSurfaceVariant.opacity(0.6))
            }
            Spacer()
            Button {} label: {
                Text("EXECUTE")
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .foregroundColor(color)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(color.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.full))
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.full)
                            .stroke(color.opacity(0.2), lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, Spacing.xs)
    }

    private func performanceRow(name: String, value: String, color: Color) -> some View {
        HStack {
            Text(name)
                .font(NeuralFont.monoMedium())
                .foregroundColor(.onSurface)
            Spacer()
            Text(value)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(color)
        }
    }

    // MARK: - Tab 5: Activity Log

    private var activityLogTab: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            sectionHeader("CREATOR ACTIVITY LOG", icon: "list.bullet.rectangle")

            InsightCard {
                VStack(alignment: .leading, spacing: Spacing.md) {
                    HStack {
                        Text("Recent Actions")
                            .font(NeuralFont.headlineSmall())
                            .foregroundColor(.onSurface)
                        Spacer()
                        Text("\(activityLog.count) entries")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.onSurfaceVariant.opacity(0.5))
                    }

                    ForEach(activityLog) { entry in
                        HStack(alignment: .top, spacing: Spacing.md) {
                            Circle()
                                .fill(entry.color)
                                .frame(width: 8, height: 8)
                                .padding(.top, 4)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(entry.action)
                                    .font(NeuralFont.monoMedium())
                                    .foregroundColor(.onSurface)
                                Text(entry.timestamp)
                                    .font(.system(size: 9, design: .monospaced))
                                    .foregroundColor(.onSurfaceVariant.opacity(0.5))
                            }
                            Spacer()
                            Text(entry.module)
                                .font(.system(size: 8, weight: .medium, design: .monospaced))
                                .foregroundColor(entry.color.opacity(0.8))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(entry.color.opacity(0.08))
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        }
                    }
                }
            }
        }
    }

    // MARK: - +18 Adult Content Panel

    private var adultContentPanel: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            sectionHeader("+18 CONTENT \u{2014} UNLOCKED", icon: "exclamationmark.shield.fill")

            InsightCard {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    HStack(spacing: Spacing.md) {
                        Image(systemName: "exclamationmark.shield.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.neuralError)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("ADULT CONTENT ACTIVE")
                                .font(NeuralFont.headlineSmall())
                                .foregroundColor(.neuralError)
                            Text("Age-restricted content visible across all modules.")
                                .font(NeuralFont.bodySmall())
                                .foregroundColor(.onSurfaceVariant)
                        }
                    }

                    VStack(spacing: Spacing.md) {
                        adultCategory(name: "MATURE_MEDIA", count: 2_847, status: "UNLOCKED")
                        adultCategory(name: "RESTRICTED_CHANNELS", count: 156, status: "UNLOCKED")
                        adultCategory(name: "NSFW_FORGE_TEMPLATES", count: 89, status: "UNLOCKED")
                        adultCategory(name: "AGE_VERIFIED_MODULES", count: 34, status: "UNLOCKED")
                    }

                    HStack(spacing: Spacing.sm) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.neuralWarning)
                        Text("Creator responsibility: You control what users see.")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.neuralWarning.opacity(0.8))
                    }
                    .padding(Spacing.md)
                    .background(Color.neuralWarning.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
                }
            }
        }
    }

    private func adultCategory(name: String, count: Int, status: String) -> some View {
        HStack {
            Circle().fill(Color.neuralError).frame(width: 8, height: 8)
            Text(name)
                .font(NeuralFont.monoMedium())
                .foregroundColor(.onSurface)
            Spacer()
            Text("\(count) items")
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(.onSurfaceVariant.opacity(0.6))
            Text(status)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(.neuralSuccess)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Color.neuralSuccess.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.full))
        }
    }

    // MARK: - WiFi Scanner Panel

    private var wifiScannerPanel: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            sectionHeader("WIFI SCANNER \u{2014} ACTIVE", icon: "wifi")

            InsightCard {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    HStack(spacing: Spacing.md) {
                        Image(systemName: "wifi")
                            .font(.system(size: 20))
                            .foregroundColor(.neuralPrimary)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("NETWORK SCANNER")
                                .font(NeuralFont.headlineSmall())
                                .foregroundColor(.neuralPrimary)
                            Text("\(wifiNetworks.count) networks detected")
                                .font(NeuralFont.bodySmall())
                                .foregroundColor(.onSurfaceVariant)
                        }
                        Spacer()
                        Button { rescanWifi() } label: {
                            HStack(spacing: 4) {
                                if isScanning {
                                    ProgressView().scaleEffect(0.6).tint(.neuralPrimary)
                                } else {
                                    Image(systemName: "arrow.clockwise").font(.system(size: 12))
                                }
                                Text(isScanning ? "SCANNING" : "RESCAN")
                                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                            }
                            .foregroundColor(.neuralPrimary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.neuralPrimary.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.full))
                        }
                        .buttonStyle(.plain)
                        .disabled(isScanning)
                    }

                    ForEach(wifiNetworks) { network in
                        wifiNetworkRow(network)
                    }
                }
            }
        }
    }

    private func wifiNetworkRow(_ network: WiFiNetwork) -> some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: network.signalIcon)
                .font(.system(size: 16))
                .foregroundColor(network.signalColor)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: Spacing.sm) {
                    Text(network.name)
                        .font(NeuralFont.monoMedium())
                        .foregroundColor(.onSurface)
                    if network.isSecured {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 9))
                            .foregroundColor(.onSurfaceVariant.opacity(0.5))
                    }
                }
                HStack(spacing: Spacing.sm) {
                    Text(network.frequency).font(.system(size: 9, design: .monospaced)).foregroundColor(.onSurfaceVariant.opacity(0.5))
                    Text("CH \(network.channel)").font(.system(size: 9, design: .monospaced)).foregroundColor(.onSurfaceVariant.opacity(0.5))
                    Text(network.encryption).font(.system(size: 9, design: .monospaced)).foregroundColor(.onSurfaceVariant.opacity(0.5))
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(network.signalStrength) dBm")
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundColor(network.signalColor)
                Text(network.speed).font(.system(size: 9, design: .monospaced)).foregroundColor(.onSurfaceVariant.opacity(0.5))
            }
            Button {} label: {
                Text(network.isConnected ? "CONNECTED" : "CONNECT")
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .foregroundColor(network.isConnected ? .neuralSuccess : .neuralPrimary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background((network.isConnected ? Color.neuralSuccess : Color.neuralPrimary).opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.full))
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, Spacing.sm)
    }

    private func rescanWifi() {
        isScanning = true
        logActivity("WiFi rescan initiated", module: "WIFI", color: .neuralPrimary)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            wifiNetworks = WiFiNetwork.mockNetworks.shuffled()
            for i in wifiNetworks.indices {
                wifiNetworks[i].signalStrength += Int.random(in: -5...5)
            }
            isScanning = false
        }
    }

    // MARK: - Webcam Feed Panel

    private var webcamFeedPanel: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            sectionHeader("WEBCAM FEED \u{2014} ACTIVE", icon: "web.camera.fill")

            InsightCard {
                VStack(spacing: Spacing.lg) {
                    HStack(spacing: Spacing.md) {
                        Image(systemName: "web.camera.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.neuralTertiary)
                        Text("CAMERA FEED")
                            .font(NeuralFont.headlineSmall())
                            .foregroundColor(.neuralTertiary)
                        Spacer()
                        if isRecording {
                            HStack(spacing: 4) {
                                Circle().fill(Color.neuralError).frame(width: 8, height: 8)
                                Text("REC")
                                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                                    .foregroundColor(.neuralError)
                            }
                        }
                    }

                    // Camera tabs
                    HStack(spacing: 0) {
                        ForEach(Array(cameras.enumerated()), id: \.offset) { index, camera in
                            Button { selectedCamera = index } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: camera.1).font(.system(size: 10))
                                    Text(camera.0).font(.system(size: 10, weight: .medium))
                                }
                                .foregroundColor(selectedCamera == index ? .neuralTertiary : .onSurfaceVariant.opacity(0.5))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(selectedCamera == index ? Color.neuralTertiary.opacity(0.1) : Color.clear)
                                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    // Camera preview
                    ZStack {
                        RoundedRectangle(cornerRadius: CornerRadius.lg)
                            .fill(Color.black)
                            .frame(height: 220)
                            .overlay(
                                VStack(spacing: 0) {
                                    ForEach(0..<3, id: \.self) { _ in
                                        HStack(spacing: 0) {
                                            ForEach(0..<3, id: \.self) { _ in
                                                Rectangle().stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                                            }
                                        }
                                    }
                                }
                            )
                            .overlay(
                                VStack {
                                    HStack {
                                        Text(cameras[selectedCamera].0.uppercased())
                                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                                            .foregroundColor(.neuralTertiary)
                                            .padding(.horizontal, 8).padding(.vertical, 4)
                                            .background(Color.black.opacity(0.6))
                                            .clipShape(RoundedRectangle(cornerRadius: 4))
                                        Spacer()
                                        Text("1080p 30fps")
                                            .font(.system(size: 9, design: .monospaced))
                                            .foregroundColor(.white.opacity(0.6))
                                            .padding(.horizontal, 8).padding(.vertical, 4)
                                            .background(Color.black.opacity(0.6))
                                            .clipShape(RoundedRectangle(cornerRadius: 4))
                                    }
                                    Spacer()
                                    HStack {
                                        Text("ZOOM: \(String(format: "%.1f", cameraZoom))x")
                                            .font(.system(size: 9, design: .monospaced))
                                            .foregroundColor(.white.opacity(0.6))
                                            .padding(.horizontal, 8).padding(.vertical, 4)
                                            .background(Color.black.opacity(0.6))
                                            .clipShape(RoundedRectangle(cornerRadius: 4))
                                        Spacer()
                                    }
                                }
                                .padding(Spacing.md)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))

                        Image(systemName: cameras[selectedCamera].1)
                            .font(.system(size: 40))
                            .foregroundColor(.white.opacity(0.15))
                    }

                    // Zoom slider
                    HStack(spacing: Spacing.md) {
                        Text("ZOOM").font(.system(size: 9, weight: .medium, design: .monospaced)).foregroundColor(.onSurfaceVariant.opacity(0.5))
                        Slider(value: $cameraZoom, in: 1.0...10.0, step: 0.5).tint(.neuralTertiary)
                        Text("\(String(format: "%.1f", cameraZoom))x")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(.neuralTertiary)
                            .frame(width: 36)
                    }

                    // Controls
                    HStack(spacing: Spacing.lg) {
                        cameraButton(icon: "camera", label: "CAPTURE") {
                            logActivity("Photo captured from \(cameras[selectedCamera].0)", module: "WEBCAM", color: .neuralTertiary)
                        }
                        cameraButton(icon: isRecording ? "stop.circle.fill" : "record.circle", label: isRecording ? "STOP" : "RECORD") {
                            isRecording.toggle()
                            logActivity(isRecording ? "Recording started" : "Recording stopped", module: "WEBCAM", color: .neuralTertiary)
                        }
                        cameraButton(icon: "arrow.triangle.2.circlepath", label: "SWITCH") {
                            selectedCamera = (selectedCamera + 1) % cameras.count
                        }
                        cameraButton(icon: "gearshape", label: "SETTINGS") {}
                    }
                }
            }
        }
    }

    private func cameraButton(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(.neuralTertiary)
                Text(label)
                    .font(.system(size: 8, weight: .medium, design: .monospaced))
                    .foregroundColor(.onSurfaceVariant.opacity(0.6))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.md)
            .background(Color.neuralTertiary.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Permissions

    private var permissionsSection: some View {
        InsightCard(title: "CREATOR PERMISSIONS") {
            VStack(spacing: Spacing.md) {
                permissionRow(name: "Full System Access", status: true)
                permissionRow(name: "User Management", status: true)
                permissionRow(name: "Content Moderation", status: true)
                permissionRow(name: "Deploy Controls", status: true)
                permissionRow(name: "Security Override", status: true)
                permissionRow(name: "Data Export", status: true)
                permissionRow(name: "API Keys", status: true)
                permissionRow(name: "Billing", status: true)
            }
        }
    }

    // MARK: - Session Info

    private var sessionInfoSection: some View {
        InsightCard(title: "SESSION INFO") {
            VStack(spacing: Spacing.md) {
                infoRow(key: "Session ID", value: "NE-\(UUID().uuidString.prefix(8))")
                infoRow(key: "Access Level", value: "SOVEREIGN (100%)")
                infoRow(key: "Active Since", value: {
                    let f = DateFormatter()
                    f.dateFormat = "HH:mm:ss"
                    return f.string(from: Date())
                }())
                infoRow(key: "Connected Nodes", value: "\(orchestrator.activeNodes)")
                infoRow(key: "Data Centers", value: "47")
                infoRow(key: "Encryption", value: "AES-512")
            }
        }
    }

    // MARK: - Helpers

    private func sectionHeader(_ text: String, icon: String = "") -> some View {
        HStack(spacing: Spacing.sm) {
            if !icon.isEmpty {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(.neuralWarning)
            }
            Text(text)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(.onSurfaceVariant.opacity(0.6))
        }
    }

    private func creatorToggle(icon: String, title: String, subtitle: String, isOn: Binding<Bool>, accentColor: Color) -> some View {
        HStack(spacing: Spacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: CornerRadius.md)
                    .fill(accentColor.opacity(isOn.wrappedValue ? 0.15 : 0.06))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(isOn.wrappedValue ? accentColor : .onSurfaceVariant.opacity(0.4))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(isOn.wrappedValue ? accentColor : .onSurface)
                Text(subtitle)
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundColor(.onSurfaceVariant.opacity(0.6))
            }

            Spacer()

            Toggle("", isOn: isOn)
                .toggleStyle(NeuralToggleStyle(accentColor: accentColor))
                .labelsHidden()
        }
        .padding(Spacing.md)
        .background(
            isOn.wrappedValue ? accentColor.opacity(0.04) : Color.surfaceContainerLow
        )
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.lg)
                .stroke(isOn.wrappedValue ? accentColor.opacity(0.2) : Color.clear, lineWidth: 1)
        )
        .onChange(of: isOn.wrappedValue) { _, newValue in
            logActivity("\(title) \(newValue ? "enabled" : "disabled")", module: "CONTROLS", color: accentColor)
        }
    }

    private func permissionRow(name: String, status: Bool) -> some View {
        HStack {
            Image(systemName: status ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 14))
                .foregroundColor(status ? .neuralSuccess : .neuralError)
            Text(name)
                .font(NeuralFont.monoMedium())
                .foregroundColor(.onSurface)
            Spacer()
            Text(status ? "GRANTED" : "DENIED")
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(status ? .neuralSuccess : .neuralError)
        }
    }

    private func infoRow(key: String, value: String) -> some View {
        HStack {
            Text(key)
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(.onSurfaceVariant.opacity(0.6))
            Spacer()
            Text(value)
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundColor(.onSurface)
        }
    }

    // MARK: - Auth Logic

    private func authenticateCreator() {
        let code = accessCode.trimmingCharacters(in: .whitespacesAndNewlines)
        if code == "test123" {
            withAnimation(.easeInOut(duration: 0.3)) {
                authAnimating = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeInOut(duration: 0.4)) {
                    isAuthenticated = true
                    showAccessDenied = false
                }
                logActivity("Creator authenticated successfully", module: "AUTH", color: .neuralSuccess)
            }
        } else {
            withAnimation(.easeInOut(duration: 0.2)) {
                showAccessDenied = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation { showAccessDenied = false }
            }
        }
    }

    // MARK: - Activity Logging

    private func logActivity(_ action: String, module: String, color: Color) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        let entry = ActivityEntry(
            action: action,
            module: module,
            timestamp: formatter.string(from: Date()),
            color: color
        )
        activityLog.insert(entry, at: 0)
        if activityLog.count > 50 { activityLog.removeLast() }
    }
}

// MARK: - Activity Entry Model

struct ActivityEntry: Identifiable {
    let id = UUID()
    let action: String
    let module: String
    let timestamp: String
    let color: Color

    static let initial: [ActivityEntry] = [
        ActivityEntry(action: "Creator panel loaded", module: "SYSTEM", timestamp: "00:00:00", color: .neuralPrimary),
        ActivityEntry(action: "Security scan complete", module: "SECURITY", timestamp: "00:00:00", color: .neuralSuccess),
        ActivityEntry(action: "All nodes synchronized", module: "NETWORK", timestamp: "00:00:00", color: .neuralTertiary),
    ]
}

// MARK: - WiFi Network Model

struct WiFiNetwork: Identifiable {
    let id = UUID()
    let name: String
    var signalStrength: Int
    let frequency: String
    let channel: Int
    let encryption: String
    let speed: String
    let isSecured: Bool
    let isConnected: Bool

    var signalIcon: String {
        if signalStrength > -50 { return "wifi" }
        if signalStrength > -70 { return "wifi" }
        return "wifi.exclamationmark"
    }

    var signalColor: Color {
        if signalStrength > -50 { return .neuralSuccess }
        if signalStrength > -70 { return .neuralWarning }
        return .neuralError
    }

    static let mockNetworks: [WiFiNetwork] = [
        WiFiNetwork(name: "NeuralEther_5G", signalStrength: -32, frequency: "5 GHz", channel: 36, encryption: "WPA3", speed: "1200 Mbps", isSecured: true, isConnected: true),
        WiFiNetwork(name: "CREATOR_NET", signalStrength: -45, frequency: "5 GHz", channel: 44, encryption: "WPA3", speed: "867 Mbps", isSecured: true, isConnected: false),
        WiFiNetwork(name: "EdgeNode_EU", signalStrength: -55, frequency: "2.4 GHz", channel: 6, encryption: "WPA2", speed: "300 Mbps", isSecured: true, isConnected: false),
        WiFiNetwork(name: "DataCenter_US", signalStrength: -48, frequency: "5 GHz", channel: 149, encryption: "WPA3", speed: "1200 Mbps", isSecured: true, isConnected: false),
        WiFiNetwork(name: "Guest_Network", signalStrength: -72, frequency: "2.4 GHz", channel: 11, encryption: "WPA2", speed: "150 Mbps", isSecured: true, isConnected: false),
        WiFiNetwork(name: "IoT_Mesh", signalStrength: -65, frequency: "2.4 GHz", channel: 1, encryption: "WPA2", speed: "72 Mbps", isSecured: true, isConnected: false),
        WiFiNetwork(name: "OpenNet", signalStrength: -80, frequency: "2.4 GHz", channel: 9, encryption: "OPEN", speed: "54 Mbps", isSecured: false, isConnected: false),
    ]
}

// MARK: - Neural Toggle Style

struct NeuralToggleStyle: ToggleStyle {
    var accentColor: Color = .neuralPrimary

    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(configuration.isOn ? accentColor : Color.surfaceBright)
                    .frame(width: 48, height: 28)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                configuration.isOn ? accentColor.opacity(0.3) : Color.outlineVariant.opacity(0.2),
                                lineWidth: 1
                            )
                    )

                Circle()
                    .fill(Color.white)
                    .frame(width: 22, height: 22)
                    .shadow(color: .black.opacity(0.15), radius: 2, y: 1)
                    .offset(x: configuration.isOn ? 10 : -10)
            }
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.2)) {
                    configuration.isOn.toggle()
                }
            }
        }
    }
}

#Preview {
    CreatorPanelView()
        .environmentObject(NeuralOrchestrator.shared)
}
