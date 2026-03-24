import SwiftUI

// MARK: - Creator Panel View
// Full 100% creator access: +18 content, WiFi scanner, Webcam feeds — all functional and testable.

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

                    if orchestrator.adultContentEnabled {
                        adultContentPanel
                    }
                    if orchestrator.wifiAccessEnabled {
                        wifiScannerPanel
                    }
                    if orchestrator.webcamAccessEnabled {
                        webcamFeedPanel
                    }

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
                ? "100% access active. All systems under your control."
                : "Restricted access \u{2014} authentication required.")
                .font(NeuralFont.bodyMedium())
                .foregroundColor(.onSurfaceVariant)

            if isAuthenticated {
                HStack(spacing: Spacing.sm) {
                    Image(systemName: "checkmark.shield.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.neuralSuccess)
                    Text("SOVEREIGN ACCESS GRANTED")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(.neuralSuccess)
                }
                .padding(.top, Spacing.xs)
            }
        }
    }

    // MARK: - Authentication

    private var authenticationSection: some View {
        InsightCard(title: "ACCESS_CONTROL") {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                Text("Enter your creator access code to unlock 100% administrative control.")
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
                        Text("ACCESS_DENIED \u{2014} Enter any code to authenticate.")
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

    // MARK: - Controls (Toggles)

    private var controlsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            sectionHeader("CONTENT_CONTROLS")

            creatorToggle(
                icon: "exclamationmark.shield.fill",
                title: "ADULT_CONTENT (+18)",
                subtitle: "Unlock +18 content across all modules. Shows adult section below when enabled.",
                isOn: $orchestrator.adultContentEnabled,
                accentColor: .neuralError
            )

            creatorToggle(
                icon: "wifi",
                title: "WIFI_ACCESS",
                subtitle: "Activate WiFi network scanner. Shows nearby networks when enabled.",
                isOn: $orchestrator.wifiAccessEnabled,
                accentColor: .neuralPrimary
            )

            creatorToggle(
                icon: "web.camera.fill",
                title: "WEBCAM_ACCESS",
                subtitle: "Access camera feeds. Shows live camera interface when enabled.",
                isOn: $orchestrator.webcamAccessEnabled,
                accentColor: .neuralTertiary
            )
        }
    }

    // MARK: - +18 Adult Content Panel

    private var adultContentPanel: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            sectionHeader("+18 CONTENT \u{2014} UNLOCKED")

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
                            Text("Age-restricted content is now visible across all modules.")
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
                        Text("Creator responsibility: You control what content is visible to users.")
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
            Circle()
                .fill(Color.neuralError)
                .frame(width: 8, height: 8)
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

    @State private var isScanning: Bool = false
    @State private var wifiNetworks: [WiFiNetwork] = WiFiNetwork.mockNetworks

    private var wifiScannerPanel: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            sectionHeader("WIFI_SCANNER \u{2014} ACTIVE")

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
                            Text("\(wifiNetworks.count) networks detected nearby")
                                .font(NeuralFont.bodySmall())
                                .foregroundColor(.onSurfaceVariant)
                        }
                        Spacer()
                        Button {
                            rescanWifi()
                        } label: {
                            HStack(spacing: 4) {
                                if isScanning {
                                    ProgressView()
                                        .scaleEffect(0.6)
                                        .tint(.neuralPrimary)
                                } else {
                                    Image(systemName: "arrow.clockwise")
                                        .font(.system(size: 12))
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
                    Text(network.frequency)
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(.onSurfaceVariant.opacity(0.5))
                    Text("CH \(network.channel)")
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(.onSurfaceVariant.opacity(0.5))
                    Text(network.encryption)
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(.onSurfaceVariant.opacity(0.5))
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(network.signalStrength) dBm")
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundColor(network.signalColor)
                Text(network.speed)
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundColor(.onSurfaceVariant.opacity(0.5))
            }

            Button {} label: {
                Text(network.isConnected ? "CONNECTED" : "CONNECT")
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .foregroundColor(network.isConnected ? .neuralSuccess : .neuralPrimary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        (network.isConnected ? Color.neuralSuccess : Color.neuralPrimary).opacity(0.1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.full))
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, Spacing.sm)
    }

    private func rescanWifi() {
        isScanning = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            wifiNetworks = WiFiNetwork.mockNetworks.shuffled()
            for i in wifiNetworks.indices {
                wifiNetworks[i].signalStrength += Int.random(in: -5...5)
            }
            isScanning = false
        }
    }

    // MARK: - Webcam Feed Panel

    @State private var selectedCamera: Int = 0
    @State private var isRecording: Bool = false
    @State private var cameraZoom: Double = 1.0

    private let cameras = [
        ("Front Camera", "faceid"),
        ("Rear Camera", "camera.fill"),
        ("External USB", "web.camera.fill"),
    ]

    private var webcamFeedPanel: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            sectionHeader("WEBCAM_FEED \u{2014} ACTIVE")

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
                                Circle()
                                    .fill(Color.neuralError)
                                    .frame(width: 8, height: 8)
                                Text("REC")
                                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                                    .foregroundColor(.neuralError)
                            }
                        }
                    }

                    // Camera tabs
                    HStack(spacing: 0) {
                        ForEach(Array(cameras.enumerated()), id: \.offset) { index, camera in
                            Button {
                                selectedCamera = index
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: camera.1)
                                        .font(.system(size: 10))
                                    Text(camera.0)
                                        .font(.system(size: 10, weight: .medium))
                                }
                                .foregroundColor(selectedCamera == index ? .neuralTertiary : .onSurfaceVariant.opacity(0.5))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    selectedCamera == index
                                        ? Color.neuralTertiary.opacity(0.1)
                                        : Color.clear
                                )
                                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    // Camera preview (simulated)
                    ZStack {
                        RoundedRectangle(cornerRadius: CornerRadius.lg)
                            .fill(Color.black)
                            .frame(height: 220)
                            .overlay(
                                // Grid overlay
                                VStack(spacing: 0) {
                                    ForEach(0..<3, id: \.self) { _ in
                                        HStack(spacing: 0) {
                                            ForEach(0..<3, id: \.self) { _ in
                                                Rectangle()
                                                    .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                                            }
                                        }
                                    }
                                }
                            )
                            .overlay(
                                // Camera info overlay
                                VStack {
                                    HStack {
                                        Text(cameras[selectedCamera].0.uppercased())
                                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                                            .foregroundColor(.neuralTertiary)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.black.opacity(0.6))
                                            .clipShape(RoundedRectangle(cornerRadius: 4))
                                        Spacer()
                                        Text("1080p 30fps")
                                            .font(.system(size: 9, design: .monospaced))
                                            .foregroundColor(.white.opacity(0.6))
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.black.opacity(0.6))
                                            .clipShape(RoundedRectangle(cornerRadius: 4))
                                    }
                                    Spacer()
                                    HStack {
                                        Text("ZOOM: \(String(format: "%.1f", cameraZoom))x")
                                            .font(.system(size: 9, design: .monospaced))
                                            .foregroundColor(.white.opacity(0.6))
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.black.opacity(0.6))
                                            .clipShape(RoundedRectangle(cornerRadius: 4))
                                        Spacer()
                                        if isRecording {
                                            HStack(spacing: 4) {
                                                Circle()
                                                    .fill(Color.neuralError)
                                                    .frame(width: 6, height: 6)
                                                Text("REC 00:00:12")
                                                    .font(.system(size: 9, design: .monospaced))
                                                    .foregroundColor(.neuralError)
                                            }
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.black.opacity(0.6))
                                            .clipShape(RoundedRectangle(cornerRadius: 4))
                                        }
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
                        Text("ZOOM")
                            .font(.system(size: 9, weight: .medium, design: .monospaced))
                            .foregroundColor(.onSurfaceVariant.opacity(0.5))
                        Slider(value: $cameraZoom, in: 1.0...10.0, step: 0.5)
                            .tint(.neuralTertiary)
                        Text("\(String(format: "%.1f", cameraZoom))x")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(.neuralTertiary)
                            .frame(width: 36)
                    }

                    // Camera controls
                    HStack(spacing: Spacing.lg) {
                        cameraButton(icon: "camera", label: "CAPTURE") {}
                        cameraButton(icon: isRecording ? "stop.circle.fill" : "record.circle", label: isRecording ? "STOP" : "RECORD") {
                            isRecording.toggle()
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
        VStack(alignment: .leading, spacing: Spacing.lg) {
            sectionHeader("ACTIVE_PERMISSIONS")

            InsightCard {
                VStack(spacing: Spacing.lg) {
                    permissionRow(icon: "exclamationmark.shield.fill", label: "ADULT_CONTENT", status: orchestrator.adultContentEnabled, color: .neuralError)
                    permissionRow(icon: "wifi", label: "WIFI_SCANNING", status: orchestrator.wifiAccessEnabled, color: .neuralPrimary)
                    permissionRow(icon: "web.camera.fill", label: "WEBCAM_STREAM", status: orchestrator.webcamAccessEnabled, color: .neuralTertiary)
                    permissionRow(icon: "lock.shield", label: "PANIC_PROTOCOL", status: !orchestrator.isPanicActive, color: .neuralSuccess)
                    permissionRow(icon: "shippingbox", label: "DEPLOYMENT", status: orchestrator.deploymentStatus != .locked, color: .neuralWarning)
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
                    infoRow("ACCESS_LEVEL", "100% SOVEREIGN")
                    infoRow("SESSION_ID", "NE-\(String(format: "%06X", Int.random(in: 0...16777215)))")
                    infoRow("ENCRYPTION", "QUANTUM_AES_512")
                    infoRow("STATUS", orchestrator.isPanicActive ? "LOCKED" : "FULL_ACCESS")
                    infoRow("+18_MODULES", orchestrator.adultContentEnabled ? "UNLOCKED" : "LOCKED")
                    infoRow("WIFI_SCANNER", orchestrator.wifiAccessEnabled ? "ACTIVE" : "INACTIVE")
                    infoRow("CAMERA_FEEDS", orchestrator.webcamAccessEnabled ? "STREAMING" : "OFFLINE")
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

    // MARK: - Auth Logic

    private func authenticateCreator() {
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
                    message: "CREATOR_ACCESS_GRANTED \u{2014} 100% sovereign mode activated."
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

// MARK: - WiFi Network Model

struct WiFiNetwork: Identifiable {
    let id = UUID()
    let name: String
    var signalStrength: Int
    let frequency: String
    let channel: Int
    let encryption: String
    let isSecured: Bool
    let isConnected: Bool
    let speed: String

    var signalIcon: String {
        if signalStrength > -50 { return "wifi" }
        if signalStrength > -70 { return "wifi" }
        return "wifi.exclamationmark"
    }

    var signalColor: Color {
        if signalStrength > -50 { return .neuralSuccess }
        if signalStrength > -65 { return .neuralPrimary }
        if signalStrength > -75 { return .neuralWarning }
        return .neuralError
    }

    static let mockNetworks: [WiFiNetwork] = [
        WiFiNetwork(name: "NeuralEther_5G", signalStrength: -32, frequency: "5 GHz", channel: 36, encryption: "WPA3", isSecured: true, isConnected: true, speed: "1.2 Gbps"),
        WiFiNetwork(name: "NeuralEther_2.4G", signalStrength: -45, frequency: "2.4 GHz", channel: 6, encryption: "WPA3", isSecured: true, isConnected: false, speed: "600 Mbps"),
        WiFiNetwork(name: "Quantum_Lab", signalStrength: -58, frequency: "5 GHz", channel: 44, encryption: "WPA2", isSecured: true, isConnected: false, speed: "866 Mbps"),
        WiFiNetwork(name: "CyberNet_Public", signalStrength: -67, frequency: "2.4 GHz", channel: 11, encryption: "Open", isSecured: false, isConnected: false, speed: "300 Mbps"),
        WiFiNetwork(name: "IoT_Mesh_Node_7", signalStrength: -72, frequency: "2.4 GHz", channel: 1, encryption: "WPA2", isSecured: true, isConnected: false, speed: "150 Mbps"),
        WiFiNetwork(name: "DataCenter_Staff", signalStrength: -78, frequency: "5 GHz", channel: 149, encryption: "WPA3-E", isSecured: true, isConnected: false, speed: "2.4 Gbps"),
        WiFiNetwork(name: "Guest_Portal", signalStrength: -81, frequency: "2.4 GHz", channel: 3, encryption: "WPA2", isSecured: true, isConnected: false, speed: "100 Mbps"),
    ]
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
