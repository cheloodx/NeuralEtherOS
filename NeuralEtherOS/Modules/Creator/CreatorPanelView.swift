import SwiftUI

// MARK: - Creator Panel View
// HACKER TERMINAL THEME — Green-on-black terminal aesthetic
// Access code: "test123"
// Features: Terminal, WiFi Scanner, Webcam, Network Monitor, Device Manager, Content Filter, System Override, Activity Log, File System, Exploit Tools

struct CreatorPanelView: View {
    @EnvironmentObject var orchestrator: NeuralOrchestrator
    @State private var isAuthenticated: Bool = false
    @State private var accessCode: String = ""
    @State private var showAccessDenied: Bool = false
    @State private var authAnimating: Bool = false
    @State private var selectedTab: Int = 0

    // Terminal
    @State private var terminalLines: [TerminalLine] = []
    @State private var terminalInput: String = ""
    @State private var cursorBlink: Bool = true

    // WiFi
    @State private var isScanning: Bool = false
    @State private var wifiNetworks: [WiFiNetwork] = WiFiNetwork.mockNetworks
    @State private var crackingNetworkId: UUID? = nil
    @State private var crackProgress: Double = 0.0
    @State private var crackedPasswords: [UUID: String] = [:]
    @State private var crackPhase: String = "INITIALIZING..."
    @State private var crackTimer: Timer? = nil
    @State private var showCrackedPassword: UUID? = nil
    @State private var bruteForceChars: String = ""

    // CCTV / Webcam Scanner
    @State private var selectedCamera: Int = 0
    @State private var isRecording: Bool = false
    @State private var cameraZoom: Double = 1.0
    @State private var cctvCameras: [CCTVCamera] = CCTVCamera.mockCameras
    @State private var isScanningCCTV: Bool = false
    @State private var cctvScanProgress: Double = 0.0
    @State private var selectedCCTV: CCTVCamera? = nil
    @State private var cctvViewMode: Int = 0  // 0 = list, 1 = grid, 2 = map
    @State private var cctvConnectedCount: Int = 12
    @State private var cctvRecordingIds: Set<UUID> = []

    // Matrix rain
    @State private var matrixColumns: [MatrixColumn] = []
    @State private var matrixTimer: Timer? = nil

    // Activity Log
    @State private var activityLog: [ActivityEntry] = ActivityEntry.initial

    // Exploit Tools
    @State private var runningExploit: String? = nil
    @State private var exploitProgress: Double = 0.0
    @State private var exploitResults: [String] = []
    @State private var exploitPhase: String = ""

    // Device Manager
    @State private var deviceStates: [String: String] = [
        "Creator iPhone 15 Pro": "ONLINE",
        "MacBook Pro M3": "ONLINE",
        "iPad Pro 12.9": "ONLINE",
        "Smart TV LG 4K": "IDLE",
        "Apple Watch Ultra": "SYNCED",
        "HomePod Mini": "STANDBY",
        "Unknown Device": "BLOCKED",
    ]
    @State private var pingResults: [String: String] = [:]
    @State private var selectedDevice: String? = nil

    // File System
    @State private var currentPath: String = "/"
    @State private var fileContent: String? = nil
    @State private var selectedFile: String? = nil

    // Network Monitor
    @State private var networkThroughput: Double = 4.7
    @State private var networkConnections: Int = 78543
    @State private var isRefreshingNetwork: Bool = false
    @State private var trafficData: [(String, Double)] = [
        ("Europe", 0.82), ("Americas", 0.67), ("Asia-Pacific", 0.91),
        ("Africa", 0.34), ("Middle East", 0.48)
    ]

    // System Override
    @State private var overrideBypassRate: Bool = false
    @State private var overrideForceAdmin: Bool = true
    @State private var overrideDisableFirewall: Bool = false
    @State private var overrideRawAPI: Bool = false
    @State private var overrideDebugMode: Bool = true
    @State private var overrideStealthMode: Bool = false
    @State private var cpuUsage: Double = 0.87
    @State private var memUsage: Double = 0.72
    @State private var diskIO: Double = 0.45
    @State private var gpuUsage: Double = 0.93
    @State private var netUsage: Double = 0.68

    // Hacker colors
    private let hackerGreen = Color(hex: "#00FF41")
    private let hackerDarkGreen = Color(hex: "#008F11")
    private let hackerBG = Color(hex: "#0D0208")
    private let hackerDimGreen = Color(hex: "#003B00")
    private let hackerAmber = Color(hex: "#FFB000")
    private let hackerRed = Color(hex: "#FF0033")
    private let hackerCyan = Color(hex: "#00FFFF")

    private let cameras = [
        ("Front Camera", "faceid"),
        ("Rear Camera", "camera.fill"),
        ("External USB", "web.camera.fill"),
    ]

    private let cctvTypes = [
        ("video.fill", "IP Camera"),
        ("web.camera.fill", "CCTV Dome"),
        ("camera.fill", "PTZ Camera"),
        ("eye.fill", "Hidden Cam"),
        ("building.2.fill", "Building Sec"),
        ("car.fill", "Traffic Cam"),
    ]

    private let creatorTabs = [
        ("chevron.left.forwardslash.chevron.right", "TERMINAL"),
        ("wifi", "WIFI"),
        ("web.camera.fill", "WEBCAM"),
        ("network", "NETWORK"),
        ("desktopcomputer", "DEVICES"),
        ("lock.shield", "EXPLOITS"),
        ("folder.fill", "FILES"),
        ("eye.fill", "+18"),
        ("gearshape.2.fill", "OVERRIDE"),
        ("list.bullet.rectangle", "LOG"),
    ]

    var body: some View {
        ZStack {
            hackerBG.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    if isAuthenticated {
                        hackerHeader
                        tabSelector
                        tabContent
                    } else {
                        hackerLoginScreen
                    }
                }
                .padding(.horizontal, Spacing.md)
                .padding(.top, Spacing.lg)
                .padding(.bottom, Spacing.massive)
            }

            // Matrix rain overlay when not authenticated
            if !isAuthenticated {
                matrixRainOverlay
                    .allowsHitTesting(false)
            }
        }
        .onAppear { startMatrixRain() }
        .onDisappear { matrixTimer?.invalidate() }
    }

    // MARK: - Matrix Rain Overlay

    private var matrixRainOverlay: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(Array(matrixColumns.enumerated()), id: \.offset) { _, col in
                    Text(col.char)
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(hackerGreen.opacity(col.opacity))
                        .position(x: col.x, y: col.y)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .opacity(0.15)
    }

    private func startMatrixRain() {
        let chars = "01アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲンABCDEF0123456789"
        matrixTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { _ in
            // Stop matrix rain after authentication to save performance
            if isAuthenticated {
                matrixTimer?.invalidate()
                matrixTimer = nil
                matrixColumns.removeAll()
                return
            }
            if matrixColumns.count > 25 { matrixColumns.removeFirst(5) }
            let newCol = MatrixColumn(
                char: String(chars.randomElement() ?? "0"),
                x: CGFloat.random(in: 0...380),
                y: CGFloat.random(in: 0...800),
                opacity: Double.random(in: 0.1...0.8)
            )
            matrixColumns.append(newCol)
        }
    }

    // MARK: - Hacker Login Screen

    private var hackerLoginScreen: some View {
        VStack(spacing: Spacing.xl) {
            Spacer().frame(height: 40)

            // ASCII art skull
            VStack(spacing: 0) {
                Text("    ██████╗ ██████╗  ██████╗ ████████╗")
                Text("    ██╔══██╗██╔══██╗██╔═══██╗╚══██╔══╝")
                Text("    ██████╔╝██████╔╝██║   ██║   ██║   ")
                Text("    ██╔══██╗██╔══██╗██║   ██║   ██║   ")
                Text("    ██║  ██║██║  ██║╚██████╔╝   ██║   ")
                Text("    ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝    ╚═╝   ")
            }
            .font(.system(size: 6, weight: .regular, design: .monospaced))
            .foregroundColor(hackerGreen.opacity(0.6))
            .frame(maxWidth: .infinity)

            // Terminal box
            VStack(alignment: .leading, spacing: Spacing.sm) {
                HStack(spacing: Spacing.sm) {
                    Circle().fill(hackerRed).frame(width: 8, height: 8)
                    Circle().fill(hackerAmber).frame(width: 8, height: 8)
                    Circle().fill(hackerGreen).frame(width: 8, height: 8)
                    Spacer()
                    Text("root@neural-ether:~")
                        .font(.system(size: 9, weight: .medium, design: .monospaced))
                        .foregroundColor(hackerDimGreen)
                }
                .padding(.horizontal, Spacing.md)
                .padding(.top, Spacing.sm)

                Divider().background(hackerDimGreen)

                // Terminal output
                VStack(alignment: .leading, spacing: 4) {
                    termLine("[SYSTEM] Neural Ether OS v3.7.1", color: hackerDimGreen)
                    termLine("[SYSTEM] Initializing secure shell...", color: hackerDimGreen)
                    termLine("[SYSTEM] Encryption: AES-512-GCM", color: hackerDimGreen)
                    termLine("[WARNING] Unauthorized access detected", color: hackerAmber)
                    termLine("[FIREWALL] Blocking external intrusion...", color: hackerRed)
                    termLine("", color: hackerGreen)
                    termLine("root@neural-ether:~ $ ENTER CREATOR ACCESS CODE", color: hackerGreen)
                }
                .padding(.horizontal, Spacing.md)

                // Code input
                HStack(spacing: Spacing.sm) {
                    Text(">_")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(hackerGreen)

                    SecureField("", text: $accessCode, prompt: Text("********")
                        .foregroundColor(hackerDimGreen))
                        .font(.system(size: 16, weight: .medium, design: .monospaced))
                        .foregroundColor(hackerGreen)
                        .textFieldStyle(PlainTextFieldStyle())
                        .onSubmit { authenticateCreator() }

                    Text(cursorBlink ? "\u{2588}" : " ")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(hackerGreen)
                        .onAppear {
                            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                                cursorBlink.toggle()
                            }
                        }
                }
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.md)

                if showAccessDenied {
                    HStack(spacing: Spacing.sm) {
                        Text("[ACCESS DENIED]")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(hackerRed)
                        Text("Invalid credentials. Attempt logged.")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(hackerRed.opacity(0.7))
                    }
                    .padding(.horizontal, Spacing.md)
                    .transition(.opacity)
                }

                // Authenticate button
                Button { authenticateCreator() } label: {
                    HStack(spacing: Spacing.sm) {
                        Text("$")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                        Text("sudo authenticate --force")
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                    }
                    .foregroundColor(hackerBG)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.md)
                    .background(hackerGreen)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, Spacing.md)
                .padding(.bottom, Spacing.md)
            }
            .background(hackerBG)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(hackerGreen.opacity(0.3), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .shadow(color: hackerGreen.opacity(0.15), radius: 20)

            // Warning text
            HStack(spacing: Spacing.sm) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 12))
                Text("Authorized personnel only. All access is logged.")
                    .font(.system(size: 10, design: .monospaced))
            }
            .foregroundColor(hackerAmber.opacity(0.5))
            .frame(maxWidth: .infinity)
        }
    }

    private func termLine(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .regular, design: .monospaced))
            .foregroundColor(color)
    }

    // MARK: - Hacker Header (after auth)

    private var hackerHeader: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack(spacing: Spacing.md) {
                // Skull icon
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(hackerGreen.opacity(0.08))
                        .frame(width: 44, height: 44)
                    Text("\u{2620}")
                        .font(.system(size: 24))
                }

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: Spacing.sm) {
                        Text("root@neural-ether")
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .foregroundColor(hackerGreen)
                        Text("#")
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .foregroundColor(hackerAmber)
                    }
                    Text("CREATOR MODE \u{2014} 100% ACCESS GRANTED")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(hackerGreen.opacity(0.6))
                }
                Spacer()

                // Logout
                Button {
                    withAnimation { isAuthenticated = false }
                    accessCode = ""
                } label: {
                    VStack(spacing: 2) {
                        Image(systemName: "power")
                            .font(.system(size: 16))
                        Text("EXIT")
                            .font(.system(size: 7, weight: .bold, design: .monospaced))
                    }
                    .foregroundColor(hackerRed)
                }
                .buttonStyle(.plain)
            }

            // Stats bar
            HStack(spacing: Spacing.sm) {
                hackerStat("ACCESS", "100%", hackerGreen)
                hackerStat("MODULES", "10", hackerCyan)
                hackerStat("NODES", "\(orchestrator.activeNodes)", hackerAmber)
                hackerStat("THREATS", "0", hackerRed)
                hackerStat("UPTIME", "99.9%", hackerGreen)
            }
        }
    }

    private func hackerStat(_ label: String, _ value: String, _ color: Color) -> some View {
        VStack(spacing: 1) {
            Text(value)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 6, weight: .medium, design: .monospaced))
                .foregroundColor(color.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.xs)
        .background(color.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 3))
        .overlay(RoundedRectangle(cornerRadius: 3).stroke(color.opacity(0.15), lineWidth: 0.5))
    }

    // MARK: - Tab Selector

    private var tabSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 4) {
                ForEach(Array(creatorTabs.enumerated()), id: \.offset) { index, tab in
                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) { selectedTab = index }
                    } label: {
                        HStack(spacing: 3) {
                            if tab.0 == ">_" {
                                Text(">_")
                                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                            } else {
                                Image(systemName: tab.0)
                                    .font(.system(size: 9))
                            }
                            Text(tab.1)
                                .font(.system(size: 8, weight: .bold, design: .monospaced))
                        }
                        .foregroundColor(selectedTab == index ? hackerBG : hackerGreen.opacity(0.6))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(selectedTab == index ? hackerGreen : hackerGreen.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 3))
                        .overlay(
                            RoundedRectangle(cornerRadius: 3)
                                .stroke(hackerGreen.opacity(selectedTab == index ? 0 : 0.2), lineWidth: 0.5)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case 0: terminalTab
        case 1: wifiTab.onAppear {
            if !isScanning {
                rescanWifi()
            }
        }
        case 2: webcamTab
        case 3: networkMonitorTab
        case 4: deviceManagerTab
        case 5: exploitToolsTab
        case 6: fileSystemTab
        case 7: adultContentTab
        case 8: systemOverrideTab
        case 9: activityLogTab
        default: terminalTab
        }
    }

    // MARK: - Tab 0: Terminal

    private var terminalTab: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Terminal window chrome
            HStack(spacing: Spacing.sm) {
                Circle().fill(hackerRed).frame(width: 8, height: 8)
                Circle().fill(hackerAmber).frame(width: 8, height: 8)
                Circle().fill(hackerGreen).frame(width: 8, height: 8)
                Spacer()
                Text("bash \u{2014} root@neural-ether \u{2014} 80x24")
                    .font(.system(size: 8, weight: .medium, design: .monospaced))
                    .foregroundColor(hackerDimGreen)
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(hackerDimGreen.opacity(0.15))

            // Terminal output
            ScrollView {
                VStack(alignment: .leading, spacing: 2) {
                    // Boot sequence
                    Text("Neural Ether OS v3.7.1 \u{2014} Creator Shell")
                        .foregroundColor(hackerGreen)
                    Text("Type 'help' for available commands")
                        .foregroundColor(hackerDimGreen)
                    Text("")

                    ForEach(Array(terminalLines.enumerated()), id: \.offset) { _, line in
                        HStack(alignment: .top, spacing: 0) {
                            if line.isCommand {
                                Text("root@neural-ether:~$ ")
                                    .foregroundColor(hackerGreen)
                            }
                            Text(line.text)
                                .foregroundColor(line.color)
                        }
                    }

                    // Input line
                    HStack(spacing: 0) {
                        Text("root@neural-ether:~$ ")
                            .foregroundColor(hackerGreen)
                        TextField("", text: $terminalInput, prompt: Text("")
                            .foregroundColor(hackerDimGreen))
                            .foregroundColor(hackerGreen)
                            .textFieldStyle(PlainTextFieldStyle())
                            .onSubmit { executeCommand() }
                        Text(cursorBlink ? "\u{2588}" : " ")
                            .foregroundColor(hackerGreen)
                    }
                }
                .font(.system(size: 11, weight: .regular, design: .monospaced))
                .padding(Spacing.md)
            }
            .frame(minHeight: 280)
            .background(hackerBG)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(hackerGreen.opacity(0.2), lineWidth: 0.5)
            )
        }
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    private func executeCommand() {
        let cmd = terminalInput.trimmingCharacters(in: .whitespaces).lowercased()
        terminalLines.append(TerminalLine(text: terminalInput, color: hackerGreen, isCommand: true))
        terminalInput = ""

        switch cmd {
        case "help":
            addOutput("Available commands:", hackerCyan)
            addOutput("  help           \u{2014} Show this help", hackerDimGreen)
            addOutput("  status         \u{2014} System status", hackerDimGreen)
            addOutput("  scan wifi      \u{2014} Scan WiFi networks", hackerDimGreen)
            addOutput("  scan ports     \u{2014} Port scanner", hackerDimGreen)
            addOutput("  scan cctv      \u{2014} Scan CCTV cameras", hackerDimGreen)
            addOutput("  devices        \u{2014} List connected devices", hackerDimGreen)
            addOutput("  ping <ip>      \u{2014} Ping a host", hackerDimGreen)
            addOutput("  whoami         \u{2014} Current user info", hackerDimGreen)
            addOutput("  ifconfig       \u{2014} Network interfaces", hackerDimGreen)
            addOutput("  nmap           \u{2014} Network mapper", hackerDimGreen)
            addOutput("  ps aux         \u{2014} Running processes", hackerDimGreen)
            addOutput("  netstat        \u{2014} Network connections", hackerDimGreen)
            addOutput("  ls             \u{2014} List files", hackerDimGreen)
            addOutput("  cat <file>     \u{2014} View file content", hackerDimGreen)
            addOutput("  cat /etc/keys  \u{2014} View encryption keys", hackerDimGreen)
            addOutput("  top            \u{2014} System performance", hackerDimGreen)
            addOutput("  uname -a       \u{2014} System information", hackerDimGreen)
            addOutput("  uptime         \u{2014} System uptime", hackerDimGreen)
            addOutput("  clear          \u{2014} Clear terminal", hackerDimGreen)
            addOutput("  hack           \u{2014} \u{26A0} Penetration test", hackerDimGreen)
            addOutput("  matrix         \u{2014} Matrix mode", hackerDimGreen)
            addOutput("  exit           \u{2014} Close terminal session", hackerDimGreen)
        case "status":
            addOutput("[SYSTEM STATUS]", hackerCyan)
            addOutput("  CPU:      87.3% \u{2588}\u{2588}\u{2588}\u{2588}\u{2588}\u{2588}\u{2588}\u{2588}\u{2591}\u{2591}", hackerGreen)
            addOutput("  RAM:      12.4 / 16.0 GB", hackerGreen)
            addOutput("  DISK:     234 / 512 GB SSD", hackerGreen)
            addOutput("  NETWORK:  \(String(format: "%.1f", Double.random(in: 2.5...8.5))) Gbps", hackerGreen)
            addOutput("  NODES:    \(orchestrator.activeNodes) active", hackerAmber)
            addOutput("  UPTIME:   47d 12h 33m", hackerGreen)
            addOutput("  THREATS:  0 detected", hackerGreen)
        case "whoami":
            addOutput("root (uid=0) \u{2014} CREATOR", hackerGreen)
            addOutput("Access Level: SOVEREIGN (100%)", hackerAmber)
            addOutput("Encryption: AES-512-GCM", hackerGreen)
            addOutput("Session: \(UUID().uuidString.prefix(8))", hackerDimGreen)
        case "scan wifi":
            addOutput("[WIFI SCANNER] Scanning nearby networks...", hackerCyan)
            for net in wifiNetworks {
                let bar = String(repeating: "\u{2588}", count: net.signal / 10)
                addOutput("  \(net.name.padding(toLength: 20, withPad: " ", startingAt: 0)) \(bar) \(net.signal)dBm  \(net.secured ? "\u{1F512}" : "\u{1F513}")", net.secured ? hackerGreen : hackerRed)
            }
        case "scan ports":
            addOutput("[PORT SCANNER] Scanning 192.168.1.0/24...", hackerCyan)
            addOutput("  PORT   STATE    SERVICE", hackerAmber)
            addOutput("  22     open     ssh", hackerGreen)
            addOutput("  80     open     http", hackerGreen)
            addOutput("  443    open     https", hackerGreen)
            addOutput("  3306   closed   mysql", hackerRed)
            addOutput("  5432   open     postgresql", hackerGreen)
            addOutput("  8080   open     http-proxy", hackerAmber)
            addOutput("  8443   filtered https-alt", hackerAmber)
            addOutput("  9090   open     neural-api", hackerGreen)
            addOutput("Scan complete: 8 ports checked, 6 open", hackerCyan)
        case "ifconfig":
            addOutput("eth0: flags=4163<UP,BROADCAST,RUNNING>", hackerCyan)
            addOutput("  inet 192.168.1.42  netmask 255.255.255.0", hackerGreen)
            addOutput("  inet6 fe80::1 prefixlen 64", hackerGreen)
            addOutput("  ether 00:1A:2B:3C:4D:5E  txqueuelen 1000", hackerDimGreen)
            addOutput("  RX bytes: \(Int.random(in: 100_000...999_999)) TX bytes: \(Int.random(in: 50_000...500_000))", hackerDimGreen)
            addOutput("", hackerGreen)
            addOutput("wlan0: flags=4163<UP,BROADCAST,RUNNING>", hackerCyan)
            addOutput("  inet 10.0.0.1  netmask 255.255.255.0", hackerGreen)
            addOutput("  ether AA:BB:CC:DD:EE:FF", hackerDimGreen)
        case "nmap":
            addOutput("Starting Nmap 7.94 ( https://nmap.org )", hackerCyan)
            addOutput("Scanning 192.168.1.0/24 [1000 ports]", hackerGreen)
            addOutput("Discovered hosts:", hackerAmber)
            addOutput("  192.168.1.1   \u{2014} Router (Cisco)", hackerGreen)
            addOutput("  192.168.1.10  \u{2014} iPhone 15 Pro", hackerGreen)
            addOutput("  192.168.1.15  \u{2014} MacBook Pro M3", hackerGreen)
            addOutput("  192.168.1.22  \u{2014} Smart TV (LG)", hackerGreen)
            addOutput("  192.168.1.30  \u{2014} Unknown Device", hackerAmber)
            addOutput("  192.168.1.42  \u{2014} Neural Ether Server", hackerCyan)
            addOutput("Nmap done: 256 IPs scanned in 4.2s", hackerDimGreen)
        case "ps aux":
            addOutput("USER    PID  %CPU %MEM COMMAND", hackerAmber)
            addOutput("root    1    0.0  0.1  neural-ether-core", hackerGreen)
            addOutput("root    42   87.3 12.0 ai-search-engine", hackerGreen)
            addOutput("root    77   2.1  3.4  photo-editor", hackerGreen)
            addOutput("root    88   4.5  5.2  video-encoder", hackerGreen)
            addOutput("root    99   0.3  0.5  firewall-daemon", hackerGreen)
            addOutput("root    123  1.2  2.1  webcam-stream", hackerGreen)
            addOutput("root    456  0.8  1.0  wifi-monitor", hackerGreen)
            addOutput("root    789  0.1  0.2  log-collector", hackerDimGreen)
        case "netstat":
            addOutput("Active connections:", hackerCyan)
            addOutput("Proto  Local           Foreign         State", hackerAmber)
            addOutput("TCP    0.0.0.0:443     *:*             LISTEN", hackerGreen)
            addOutput("TCP    192.168.1.42:80 45.33.32.1:443  ESTABLISHED", hackerGreen)
            addOutput("TCP    10.0.0.1:9090   172.16.0.5:22   ESTABLISHED", hackerGreen)
            addOutput("UDP    0.0.0.0:5353    *:*             ", hackerDimGreen)
            addOutput("  \(Int.random(in: 45000...120000)) active connections", hackerAmber)
        case "hack":
            addOutput("[PENETRATION TEST] Initializing...", hackerRed)
            addOutput("  \u{26A0} Scanning target vulnerabilities...", hackerAmber)
            addOutput("  [1/5] Port scanning.............. DONE", hackerGreen)
            addOutput("  [2/5] Service enumeration........ DONE", hackerGreen)
            addOutput("  [3/5] Vulnerability assessment... DONE", hackerGreen)
            addOutput("  [4/5] Exploit generation......... DONE", hackerAmber)
            addOutput("  [5/5] Report generation.......... DONE", hackerGreen)
            addOutput("", hackerGreen)
            addOutput("  Vulnerabilities found: 0 critical, 2 medium, 5 low", hackerAmber)
            addOutput("  System security score: 94/100 (EXCELLENT)", hackerGreen)
        case "matrix":
            addOutput("", hackerGreen)
            for _ in 0..<5 {
                let matrixRow = (0..<40).map { _ in String("01".randomElement()!) }.joined()
                addOutput(matrixRow, hackerGreen)
            }
            addOutput("", hackerGreen)
            addOutput("Wake up, Neo...", hackerGreen)
        case "scan cctv":
            addOutput("[CCTV SCANNER] Scanning 1km radius...", hackerCyan)
            addOutput("  Frequency: All bands (2.4/5/6 GHz)", hackerDimGreen)
            for cam in cameras.prefix(5) {
                addOutput("  [FOUND] \(cam.name) @ \(cam.ip):\(cam.port) (\(cam.distance)m) \u{2014} \(cam.vulnerability)", cam.isOnline ? hackerGreen : hackerRed)
            }
            addOutput("  ...and \(max(0, cameras.count - 5)) more cameras detected", hackerDimGreen)
            addOutput("Scan complete: \(cameras.count) cameras in range", hackerCyan)
        case "devices":
            addOutput("[DEVICE MANAGER] Connected devices:", hackerCyan)
            for dev in deviceList {
                let st = deviceStates[dev.0] ?? "UNKNOWN"
                let c: Color = st == "BLOCKED" ? hackerRed : st == "ONLINE" ? hackerGreen : hackerAmber
                addOutput("  \(dev.2.padding(toLength: 16, withPad: " ", startingAt: 0)) \(dev.0.padding(toLength: 24, withPad: " ", startingAt: 0)) [\(st)]", c)
            }
        case "top":
            addOutput("[SYSTEM MONITOR]", hackerCyan)
            addOutput("  CPU:     \(Int(cpuUsage * 100))% \(String(repeating: "\u{2588}", count: Int(cpuUsage * 10)))\(String(repeating: "\u{2591}", count: 10 - Int(cpuUsage * 10)))", cpuUsage > 0.9 ? hackerRed : hackerGreen)
            addOutput("  MEMORY:  \(Int(memUsage * 100))% \(String(repeating: "\u{2588}", count: Int(memUsage * 10)))\(String(repeating: "\u{2591}", count: 10 - Int(memUsage * 10)))", memUsage > 0.9 ? hackerRed : hackerCyan)
            addOutput("  DISK:    \(Int(diskIO * 100))% \(String(repeating: "\u{2588}", count: Int(diskIO * 10)))\(String(repeating: "\u{2591}", count: 10 - Int(diskIO * 10)))", hackerAmber)
            addOutput("  GPU:     \(Int(gpuUsage * 100))% \(String(repeating: "\u{2588}", count: Int(gpuUsage * 10)))\(String(repeating: "\u{2591}", count: 10 - Int(gpuUsage * 10)))", gpuUsage > 0.9 ? hackerRed : hackerGreen)
            addOutput("  NETWORK: \(Int(netUsage * 100))% \(String(repeating: "\u{2588}", count: Int(netUsage * 10)))\(String(repeating: "\u{2591}", count: 10 - Int(netUsage * 10)))", hackerCyan)
        case "ls":
            addOutput("root@neural-ether:/\(currentPath) $ ls -la", hackerCyan)
            let entries = fsStructure[currentPath] ?? fsStructure["/"] ?? []
            for e in entries {
                addOutput("  \(e.0)  root  \(e.1.padding(toLength: 8, withPad: " ", startingAt: 0))  \(e.2)", e.5 ? hackerCyan : hackerGreen)
            }
        case "uname -a":
            addOutput("Neural-Ether-OS 3.7.1 (kernel 6.8.0-neural) aarch64 ARM64", hackerGreen)
            addOutput("Build: 2026.03.24-sovereign #1 SMP PREEMPT", hackerDimGreen)
            addOutput("AI Engine: v12.4M sources | 175 countries", hackerCyan)
        case "uptime":
            addOutput("17:29:25 up 47 days, 12:33, 1 user, load avg: 0.87, 0.72, 0.68", hackerGreen)
        case "exit":
            addOutput("Closing session... Goodbye, Creator.", hackerAmber)
            addOutput("[SESSION TERMINATED]", hackerRed)
        case "clear":
            terminalLines.removeAll()
        default:
            if cmd.hasPrefix("ping ") {
                let target = String(cmd.dropFirst(5)).trimmingCharacters(in: .whitespaces)
                addOutput("PING \(target) 56 data bytes", hackerCyan)
                for i in 1...4 {
                    let ms = String(format: "%.1f", Double.random(in: 1.0...45.0))
                    addOutput("  \(i): reply from \(target): bytes=64 time=\(ms)ms TTL=64", hackerGreen)
                }
                addOutput("--- \(target) ping statistics ---", hackerDimGreen)
                addOutput("4 packets sent, 4 received, 0% loss", hackerGreen)
            } else if cmd.hasPrefix("cat ") {
                let file = String(cmd.dropFirst(4)).trimmingCharacters(in: .whitespaces)
                if file == "/etc/keys" {
                    addOutput("[ENCRYPTION KEYS]", hackerCyan)
                    addOutput("  RSA-4096:  \(UUID().uuidString)", hackerGreen)
                    addOutput("  AES-512:   \(UUID().uuidString)", hackerGreen)
                    addOutput("  ECDSA:     \(UUID().uuidString.prefix(16))...", hackerGreen)
                } else {
                    let key = file.components(separatedBy: "/").last ?? file
                    if let content = fsFileContents[key] {
                        for line in content.components(separatedBy: "\n") {
                            addOutput(line, hackerGreen)
                        }
                    } else {
                        addOutput("cat: \(file): No such file or directory", hackerRed)
                    }
                }
            } else {
            if cmd.isEmpty {
                // do nothing
            } else {
                addOutput("bash: \(cmd): command not found", hackerRed)
                addOutput("Type 'help' for available commands", hackerDimGreen)
            }
            }
        }

        logActivity("TERMINAL: \(cmd)")
    }

    private func addOutput(_ text: String, _ color: Color) {
        terminalLines.append(TerminalLine(text: text, color: color, isCommand: false))
    }

    // MARK: - Tab 1: WiFi Scanner + Password Finder

    private var wifiTab: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            hackerSection("WIFI PASSWORD FINDER", icon: "wifi")

            // Status bar
            HStack(spacing: Spacing.sm) {
                Circle().fill(hackerGreen).frame(width: 6, height: 6)
                Text("WIFI ADAPTER: MONITOR MODE")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(hackerGreen)
                Spacer()
                Text("\(wifiNetworks.count) TARGETS")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(hackerAmber)
            }
            .padding(Spacing.sm)
            .background(hackerGreen.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 3))

            // Scan button
            Button { rescanWifi() } label: {
                HStack(spacing: Spacing.sm) {
                    if isScanning {
                        ProgressView().tint(hackerBG).scaleEffect(0.8)
                    } else {
                        Image(systemName: "antenna.radiowaves.left.and.right")
                            .font(.system(size: 14))
                    }
                    Text(isScanning ? "SCANNING NETWORKS..." : "$ airodump-ng --scan-all")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                }
                .foregroundColor(hackerBG)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.md)
                .background(hackerGreen)
                .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            .buttonStyle(.plain)

            // Cracking progress view
            if let crackId = crackingNetworkId,
               let net = wifiNetworks.first(where: { $0.id == crackId }) {
                wifiCrackingView(network: net)
            }

            // Network list
            ForEach(Array(wifiNetworks.enumerated()), id: \.element.id) { _, network in
                wifiNetworkRow(network: network)
            }

            // Cracked passwords summary
            if !crackedPasswords.isEmpty {
                wifiCrackedSummary
            }
        }
    }

    private func wifiCrackingView(network: WiFiNetwork) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Image(systemName: "lock.open.trianglebadge.exclamationmark")
                    .font(.system(size: 12))
                    .foregroundColor(hackerRed)
                Text("CRACKING: \(network.name)")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(hackerRed)
                Spacer()
                Button {
                    stopCracking()
                } label: {
                    Text("ABORT")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(hackerRed)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .overlay(RoundedRectangle(cornerRadius: 3).stroke(hackerRed, lineWidth: 1))
                }
                .buttonStyle(.plain)
            }

            Text(crackPhase)
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .foregroundColor(hackerAmber)

            // Brute force character display
            Text(bruteForceChars)
                .font(.system(size: 8, design: .monospaced))
                .foregroundColor(hackerGreen.opacity(0.6))
                .lineLimit(2)

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(hackerRed.opacity(0.1))
                    RoundedRectangle(cornerRadius: 2)
                        .fill(
                            LinearGradient(
                                colors: [hackerRed, hackerAmber, hackerGreen],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * crackProgress)
                }
            }
            .frame(height: 6)

            HStack {
                Text("\(Int(crackProgress * 100))%")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(hackerAmber)
                Spacer()
                Text("HANDSHAKE CAPTURED")
                    .font(.system(size: 8, design: .monospaced))
                    .foregroundColor(crackProgress > 0.1 ? hackerGreen : hackerDimGreen)
            }
        }
        .padding(Spacing.md)
        .background(hackerRed.opacity(0.05))
        .overlay(RoundedRectangle(cornerRadius: 4).stroke(hackerRed.opacity(0.3), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }

    private var wifiCrackedSummary: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Image(systemName: "key.fill")
                    .font(.system(size: 12))
                    .foregroundColor(hackerGreen)
                Text("CRACKED PASSWORDS (\(crackedPasswords.count))")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(hackerGreen)
            }

            ForEach(wifiNetworks.filter { crackedPasswords[$0.id] != nil }, id: \.id) { net in
                HStack {
                    Image(systemName: "wifi")
                        .font(.system(size: 10))
                        .foregroundColor(hackerGreen)
                    Text(net.name)
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(hackerGreen)
                    Spacer()
                    if showCrackedPassword == net.id {
                        Text(crackedPasswords[net.id] ?? "")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(hackerAmber)
                    } else {
                        Text("********")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(hackerDimGreen)
                    }
                    Button {
                        if showCrackedPassword == net.id {
                            showCrackedPassword = nil
                        } else {
                            showCrackedPassword = net.id
                        }
                    } label: {
                        Image(systemName: showCrackedPassword == net.id ? "eye.slash" : "eye")
                            .font(.system(size: 10))
                            .foregroundColor(hackerGreen)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(Spacing.md)
        .background(hackerGreen.opacity(0.05))
        .overlay(RoundedRectangle(cornerRadius: 4).stroke(hackerGreen.opacity(0.2), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }

    private func wifiNetworkRow(network: WiFiNetwork) -> some View {
        VStack(spacing: Spacing.sm) {
            HStack {
                Image(systemName: network.signalIcon)
                    .font(.system(size: 14))
                    .foregroundColor(network.signalColor)
                VStack(alignment: .leading, spacing: 1) {
                    Text(network.name)
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(hackerGreen)
                    Text("MAC: \(network.mac) | CH: \(network.channel)")
                        .font(.system(size: 8, design: .monospaced))
                        .foregroundColor(hackerDimGreen)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 1) {
                    Text("\(network.signal) dBm")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(network.signal > -50 ? hackerGreen : hackerAmber)
                    Text(network.secured ? "\u{1F512} \(network.encryption)" : "\u{1F513} OPEN")
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .foregroundColor(network.secured ? hackerGreen : hackerRed)
                }
            }

            // Signal bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(hackerGreen.opacity(0.1))
                    RoundedRectangle(cornerRadius: 2)
                        .fill(hackerGreen)
                        .frame(width: geo.size.width * CGFloat(min(100, 100 + network.signal)) / 100.0)
                }
            }
            .frame(height: 4)

            // Password crack button / status
            if network.secured {
                if crackedPasswords[network.id] != nil {
                    HStack(spacing: Spacing.sm) {
                        Image(systemName: "checkmark.shield.fill")
                            .font(.system(size: 10))
                            .foregroundColor(hackerGreen)
                        Text("PASSWORD FOUND")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(hackerGreen)
                        Spacer()
                        Button {
                            if showCrackedPassword == network.id {
                                showCrackedPassword = nil
                            } else {
                                showCrackedPassword = network.id
                            }
                        } label: {
                            HStack(spacing: 3) {
                                Image(systemName: showCrackedPassword == network.id ? "eye.slash" : "eye")
                                    .font(.system(size: 9))
                                Text(showCrackedPassword == network.id ? (crackedPasswords[network.id] ?? "") : "REVEAL")
                                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                            }
                            .foregroundColor(hackerAmber)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(hackerAmber.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 3))
                        }
                        .buttonStyle(.plain)
                    }
                } else if crackingNetworkId == network.id {
                    HStack(spacing: Spacing.sm) {
                        ProgressView().tint(hackerRed).scaleEffect(0.7)
                        Text("CRACKING...")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(hackerRed)
                    }
                } else {
                    Button {
                        startCracking(network: network)
                    } label: {
                        HStack(spacing: Spacing.sm) {
                            Image(systemName: "key.fill")
                                .font(.system(size: 10))
                            Text("$ crack-password --target \(network.name)")
                                .font(.system(size: 9, weight: .bold, design: .monospaced))
                        }
                        .foregroundColor(hackerRed)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(hackerRed.opacity(0.08))
                        .overlay(RoundedRectangle(cornerRadius: 3).stroke(hackerRed.opacity(0.3), lineWidth: 0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 3))
                    }
                    .buttonStyle(.plain)
                    .disabled(crackingNetworkId != nil)
                    .opacity(crackingNetworkId != nil ? 0.4 : 1.0)
                }
            } else {
                HStack(spacing: Spacing.sm) {
                    Image(systemName: "lock.open.fill")
                        .font(.system(size: 10))
                        .foregroundColor(hackerAmber)
                    Text("OPEN NETWORK — NO PASSWORD")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(hackerAmber)
                }
            }
        }
        .padding(Spacing.md)
        .background(crackedPasswords[network.id] != nil ? hackerGreen.opacity(0.04) : hackerGreen.opacity(0.02))
        .overlay(RoundedRectangle(cornerRadius: 4).stroke(
            crackedPasswords[network.id] != nil ? hackerGreen.opacity(0.3) :
            crackingNetworkId == network.id ? hackerRed.opacity(0.3) :
            hackerGreen.opacity(0.1), lineWidth: 0.5))
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }

    private func rescanWifi() {
        isScanning = true
        logActivity("WIFI_SCAN_STARTED: monitor mode active")
        // Generate fresh signal strengths and shuffle
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeInOut(duration: 0.2)) {
                // Update signals dynamically
                for i in wifiNetworks.indices {
                    wifiNetworks[i].signal = Int.random(in: -80 ... -20)
                }
                wifiNetworks.shuffle()
                isScanning = false
            }
            logActivity("WIFI_SCAN_COMPLETE: \(wifiNetworks.count) networks found")
        }
    }

    private func startCracking(network: WiFiNetwork) {
        crackingNetworkId = network.id
        crackProgress = 0.0
        crackPhase = "CAPTURING HANDSHAKE..."
        bruteForceChars = ""
        logActivity("CRACK_START: \(network.name) [\(network.encryption)]")

        let phases = [
            (0.05, "CAPTURING HANDSHAKE..."),
            (0.12, "HANDSHAKE CAPTURED — ANALYZING..."),
            (0.20, "LOADING WORDLIST: rockyou.txt (14M entries)"),
            (0.30, "DEAUTH ATTACK SENT — PMKID CAPTURED"),
            (0.45, "BRUTE FORCE: TESTING COMBINATIONS..."),
            (0.55, "HASHCAT MODE: WPA2-CCMP"),
            (0.65, "DICTIONARY ATTACK IN PROGRESS..."),
            (0.75, "KEY CANDIDATES FOUND: NARROWING..."),
            (0.85, "FINAL VERIFICATION..."),
            (0.95, "DECRYPTING KEY..."),
            (1.0, "PASSWORD CRACKED!"),
        ]

        var totalDelay: Double = 0.0
        for (i, phase) in phases.enumerated() {
            let delay = Double(i) * 0.3 + Double.random(in: 0.1...0.2)
            totalDelay = delay
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeInOut(duration: 0.15)) {
                    crackProgress = phase.0
                    crackPhase = phase.1
                }
                // Brute force chars simulation
                let chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%&*"
                bruteForceChars = String((0..<40).map { _ in chars.randomElement()! })
            }
        }

        // Final: reveal password
        DispatchQueue.main.asyncAfter(deadline: .now() + totalDelay + 0.4) {
            if crackingNetworkId == network.id {
                crackedPasswords[network.id] = network.password
                crackingNetworkId = nil
                crackProgress = 0.0
                bruteForceChars = ""
                crackPhase = ""
                logActivity("CRACK_SUCCESS: \(network.name) — PASSWORD FOUND")
            }
        }
    }

    private func stopCracking() {
        if let netId = crackingNetworkId,
           let net = wifiNetworks.first(where: { $0.id == netId }) {
            logActivity("CRACK_ABORTED: \(net.name)")
        }
        crackingNetworkId = nil
        crackProgress = 0.0
        crackPhase = ""
        bruteForceChars = ""
    }

    // MARK: - Tab 2: CCTV / Webcam Scanner

    private var webcamTab: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            hackerSection("CCTV / CAMERA SCANNER", icon: "video.fill")

            // Status bar
            HStack(spacing: Spacing.sm) {
                Circle().fill(isScanningCCTV ? hackerAmber : hackerGreen).frame(width: 6, height: 6)
                Text("RADIUS: 1.0 KM")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(hackerGreen)
                Spacer()
                Text("\(cctvCameras.count) CAMERAS FOUND")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(hackerAmber)
                Text("\(cctvConnectedCount) CONNECTED")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(hackerGreen)
            }
            .padding(Spacing.sm)
            .background(hackerGreen.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 3))

            // Scan button
            Button { scanForCCTV() } label: {
                HStack(spacing: Spacing.sm) {
                    if isScanningCCTV {
                        ProgressView().tint(hackerBG).scaleEffect(0.8)
                    } else {
                        Image(systemName: "antenna.radiowaves.left.and.right")
                            .font(.system(size: 14))
                    }
                    Text(isScanningCCTV ? "SCANNING 1KM RADIUS..." : "$ nmap -sV --script=rtsp-url-brute 192.168.0.0/16")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                }
                .foregroundColor(hackerBG)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.md)
                .background(isScanningCCTV ? hackerAmber : hackerGreen)
                .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            .buttonStyle(.plain)
            .disabled(isScanningCCTV)

            // Scan progress
            if isScanningCCTV {
                VStack(alignment: .leading, spacing: 4) {
                    Text("SCANNING RTSP/ONVIF/HTTP STREAMS...")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(hackerAmber)
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2).fill(hackerAmber.opacity(0.1))
                            RoundedRectangle(cornerRadius: 2)
                                .fill(hackerAmber)
                                .frame(width: geo.size.width * cctvScanProgress)
                        }
                    }
                    .frame(height: 4)
                }
            }

            // View mode selector
            if !cctvCameras.isEmpty {
                HStack(spacing: Spacing.sm) {
                    ForEach([(0, "list.bullet", "LIST"), (1, "square.grid.2x2", "GRID"), (2, "map", "MAP")], id: \.0) { mode, icon, label in
                        Button { cctvViewMode = mode } label: {
                            HStack(spacing: 3) {
                                Image(systemName: icon).font(.system(size: 9))
                                Text(label).font(.system(size: 8, weight: .bold, design: .monospaced))
                            }
                            .foregroundColor(cctvViewMode == mode ? hackerBG : hackerGreen.opacity(0.6))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                            .background(cctvViewMode == mode ? hackerGreen : hackerGreen.opacity(0.05))
                            .clipShape(RoundedRectangle(cornerRadius: 3))
                        }
                        .buttonStyle(.plain)
                    }
                    Spacer()
                }
            }

            // Selected camera live view
            if let cam = selectedCCTV {
                cctvLiveView(camera: cam)
            }

            // Camera list / grid
            if cctvViewMode == 1 {
                cctvGridView
            } else if cctvViewMode == 2 {
                cctvMapView
            } else {
                ForEach(cctvCameras) { cam in
                    cctvCameraRow(camera: cam)
                }
            }
        }
    }

    @State private var cctvNoiseOffset: Double = 0.0

    private func cctvLiveView(camera: CCTVCamera) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Live feed
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.black)
                    .aspectRatio(16/9, contentMode: .fit)
                    .overlay(
                        ZStack {
                            // Noise/static background (simulates camera feed)
                            VStack(spacing: 0) {
                                ForEach(0..<30, id: \.self) { row in
                                    HStack(spacing: 0) {
                                        ForEach(0..<20, id: \.self) { col in
                                            Rectangle()
                                                .fill(hackerGreen.opacity(Double.random(in: 0.02...0.12)))
                                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        }
                                    }
                                    .frame(maxHeight: .infinity)
                                }
                            }

                            // Center camera icon overlay
                            VStack(spacing: Spacing.sm) {
                                Image(systemName: camera.icon)
                                    .font(.system(size: 36))
                                    .foregroundColor(hackerGreen.opacity(0.5))
                                    .shadow(color: hackerGreen.opacity(0.3), radius: 10)
                                Text("\u{25CF} LIVE \u{2014} \(camera.name)")
                                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                                    .foregroundColor(hackerGreen)
                                Text(camera.streamURL)
                                    .font(.system(size: 7, design: .monospaced))
                                    .foregroundColor(hackerDimGreen)
                                Text("\(camera.resolution) | \(camera.fps) FPS | \(camera.manufacturer)")
                                    .font(.system(size: 7, design: .monospaced))
                                    .foregroundColor(hackerGreen.opacity(0.4))
                            }

                            // Top-left: camera info
                            VStack {
                                HStack {
                                    VStack(alignment: .leading, spacing: 1) {
                                        Text(camera.name)
                                            .font(.system(size: 8, weight: .bold, design: .monospaced))
                                            .foregroundColor(hackerGreen)
                                        Text(camera.ip)
                                            .font(.system(size: 7, design: .monospaced))
                                            .foregroundColor(hackerGreen.opacity(0.5))
                                    }
                                    .padding(4)
                                    .background(Color.black.opacity(0.7))
                                    .clipShape(RoundedRectangle(cornerRadius: 2))
                                    Spacer()

                                    // Recording badge
                                    if cctvRecordingIds.contains(camera.id) {
                                        HStack(spacing: 3) {
                                            Circle().fill(hackerRed).frame(width: 6, height: 6)
                                            Text("REC")
                                                .font(.system(size: 8, weight: .bold, design: .monospaced))
                                                .foregroundColor(hackerRed)
                                        }
                                        .padding(.horizontal, 5)
                                        .padding(.vertical, 2)
                                        .background(Color.black.opacity(0.7))
                                        .clipShape(RoundedRectangle(cornerRadius: 2))
                                    }
                                }
                                .padding(Spacing.sm)
                                Spacer()
                                // Bottom overlay
                                HStack {
                                    Text("\(camera.resolution) @ \(camera.fps)fps")
                                        .font(.system(size: 7, design: .monospaced))
                                        .foregroundColor(hackerGreen.opacity(0.5))
                                    Spacer()
                                    Text("ZOOM: \(String(format: "%.1f", cameraZoom))x")
                                        .font(.system(size: 7, weight: .bold, design: .monospaced))
                                        .foregroundColor(hackerGreen.opacity(0.5))
                                    Spacer()
                                    Text("\(camera.distance)m away")
                                        .font(.system(size: 7, design: .monospaced))
                                        .foregroundColor(hackerAmber.opacity(0.7))
                                }
                                .padding(Spacing.sm)
                                .background(Color.black.opacity(0.6))
                            }
                        }
                    )
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(
                        cctvRecordingIds.contains(camera.id) ? hackerRed.opacity(0.5) : hackerGreen.opacity(0.2), lineWidth: 1))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }

            // Zoom slider
            HStack(spacing: Spacing.md) {
                Text("ZOOM")
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .foregroundColor(hackerGreen.opacity(0.6))
                Slider(value: $cameraZoom, in: 1.0...20.0, step: 0.5)
                    .tint(hackerGreen)
                Text("\(String(format: "%.1f", cameraZoom))x")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(hackerGreen)
                    .frame(width: 40)
            }

            // Controls
            HStack(spacing: Spacing.sm) {
                hackerBtn(icon: "camera.fill", label: "SNAPSHOT") {
                    logActivity("CCTV_SNAPSHOT: \(camera.name)")
                }
                hackerBtn(icon: cctvRecordingIds.contains(camera.id) ? "stop.fill" : "record.circle", label: cctvRecordingIds.contains(camera.id) ? "STOP REC" : "RECORD") {
                    if cctvRecordingIds.contains(camera.id) {
                        cctvRecordingIds.remove(camera.id)
                        logActivity("CCTV_REC_STOP: \(camera.name)")
                    } else {
                        cctvRecordingIds.insert(camera.id)
                        logActivity("CCTV_REC_START: \(camera.name)")
                    }
                }
                hackerBtn(icon: "arrow.down.circle", label: "SAVE") {
                    logActivity("CCTV_SAVE: \(camera.name)")
                }
                hackerBtn(icon: "xmark.circle", label: "CLOSE") {
                    selectedCCTV = nil
                }
            }
        }
    }

    private var cctvGridView: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.sm) {
            ForEach(cctvCameras) { cam in
                Button {
                    selectedCCTV = cam
                } label: {
                    VStack(spacing: 4) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.black)
                                .aspectRatio(16/9, contentMode: .fit)
                                .overlay(
                                    VStack(spacing: 2) {
                                        Image(systemName: cam.icon)
                                            .font(.system(size: 18))
                                            .foregroundColor(cam.isOnline ? hackerGreen.opacity(0.4) : hackerRed.opacity(0.3))
                                        // Scanlines
                                        VStack(spacing: 2) {
                                            ForEach(0..<5, id: \.self) { _ in
                                                Rectangle()
                                                    .fill(hackerGreen.opacity(Double.random(in: 0.02...0.06)))
                                                    .frame(height: 1)
                                            }
                                        }
                                    }
                                )
                            // Online indicator
                            VStack {
                                HStack {
                                    Circle().fill(cam.isOnline ? hackerGreen : hackerRed).frame(width: 5, height: 5)
                                    Spacer()
                                    if cctvRecordingIds.contains(cam.id) {
                                        Circle().fill(hackerRed).frame(width: 5, height: 5)
                                    }
                                }
                                .padding(3)
                                Spacer()
                            }
                        }
                        .overlay(RoundedRectangle(cornerRadius: 4).stroke(
                            selectedCCTV?.id == cam.id ? hackerGreen : hackerGreen.opacity(0.1), lineWidth: 0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 4))

                        Text(cam.name)
                            .font(.system(size: 7, weight: .bold, design: .monospaced))
                            .foregroundColor(hackerGreen)
                            .lineLimit(1)
                        Text("\(cam.distance)m")
                            .font(.system(size: 6, design: .monospaced))
                            .foregroundColor(hackerDimGreen)
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var cctvMapView: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Simulated radar/map view
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.black)
                    .aspectRatio(1, contentMode: .fit)
                    .overlay(
                        ZStack {
                            // Concentric circles (radar rings)
                            ForEach([0.2, 0.4, 0.6, 0.8, 1.0], id: \.self) { scale in
                                Circle()
                                    .stroke(hackerGreen.opacity(0.1), lineWidth: 0.5)
                                    .scaleEffect(scale)
                            }

                            // Cross hairs
                            Rectangle()
                                .fill(hackerGreen.opacity(0.08))
                                .frame(width: 1)
                            Rectangle()
                                .fill(hackerGreen.opacity(0.08))
                                .frame(height: 1)

                            // Center point (you)
                            Circle()
                                .fill(hackerCyan)
                                .frame(width: 8, height: 8)
                            Circle()
                                .stroke(hackerCyan.opacity(0.3), lineWidth: 1)
                                .frame(width: 16, height: 16)

                            // Camera dots
                            ForEach(cctvCameras) { cam in
                                let angle = Double(cam.name.hashValue % 360) * .pi / 180
                                let dist = Double(cam.distance) / 1000.0 * 0.4
                                Circle()
                                    .fill(cam.isOnline ? hackerGreen : hackerRed)
                                    .frame(width: 6, height: 6)
                                    .offset(
                                        x: cos(angle) * dist * 150,
                                        y: sin(angle) * dist * 150
                                    )
                            }

                            // Labels
                            VStack {
                                HStack {
                                    Text("250m").font(.system(size: 6, design: .monospaced)).foregroundColor(hackerDimGreen)
                                    Spacer()
                                    Text("500m").font(.system(size: 6, design: .monospaced)).foregroundColor(hackerDimGreen)
                                }
                                Spacer()
                                HStack {
                                    Text("750m").font(.system(size: 6, design: .monospaced)).foregroundColor(hackerDimGreen)
                                    Spacer()
                                    Text("1000m").font(.system(size: 6, design: .monospaced)).foregroundColor(hackerDimGreen)
                                }
                            }
                            .padding(Spacing.sm)
                        }
                    )
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(hackerGreen.opacity(0.2), lineWidth: 0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }

            // Legend
            HStack(spacing: Spacing.md) {
                HStack(spacing: 3) {
                    Circle().fill(hackerCyan).frame(width: 5, height: 5)
                    Text("YOU").font(.system(size: 7, weight: .bold, design: .monospaced)).foregroundColor(hackerCyan)
                }
                HStack(spacing: 3) {
                    Circle().fill(hackerGreen).frame(width: 5, height: 5)
                    Text("ONLINE").font(.system(size: 7, weight: .bold, design: .monospaced)).foregroundColor(hackerGreen)
                }
                HStack(spacing: 3) {
                    Circle().fill(hackerRed).frame(width: 5, height: 5)
                    Text("OFFLINE").font(.system(size: 7, weight: .bold, design: .monospaced)).foregroundColor(hackerRed)
                }
            }
        }
    }

    private func cctvCameraRow(camera: CCTVCamera) -> some View {
        Button {
            selectedCCTV = camera
            logActivity("CCTV_ACCESS: \(camera.name) [\(camera.ip)]")
        } label: {
            VStack(spacing: Spacing.sm) {
                HStack {
                    // Status dot
                    Circle()
                        .fill(camera.isOnline ? hackerGreen : hackerRed)
                        .frame(width: 8, height: 8)

                    Image(systemName: camera.icon)
                        .font(.system(size: 14))
                        .foregroundColor(camera.isOnline ? hackerGreen : hackerRed.opacity(0.5))

                    VStack(alignment: .leading, spacing: 1) {
                        Text(camera.name)
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(hackerGreen)
                        Text("IP: \(camera.ip) | PORT: \(camera.port)")
                            .font(.system(size: 7, design: .monospaced))
                            .foregroundColor(hackerDimGreen)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 1) {
                        Text("\(camera.distance)m")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(camera.distance < 300 ? hackerGreen : hackerAmber)
                        Text(camera.type)
                            .font(.system(size: 7, weight: .bold, design: .monospaced))
                            .foregroundColor(hackerDimGreen)
                    }
                }

                // Details row
                HStack(spacing: Spacing.md) {
                    HStack(spacing: 2) {
                        Image(systemName: "lock.open.fill").font(.system(size: 7))
                        Text(camera.vulnerability)
                            .font(.system(size: 7, weight: .bold, design: .monospaced))
                    }
                    .foregroundColor(camera.vulnerability == "OPEN" ? hackerRed : hackerAmber)

                    HStack(spacing: 2) {
                        Image(systemName: "video.fill").font(.system(size: 7))
                        Text(camera.resolution)
                            .font(.system(size: 7, design: .monospaced))
                    }
                    .foregroundColor(hackerDimGreen)

                    HStack(spacing: 2) {
                        Image(systemName: "building.2.fill").font(.system(size: 7))
                        Text(camera.location)
                            .font(.system(size: 7, design: .monospaced))
                    }
                    .foregroundColor(hackerDimGreen)

                    Spacer()

                    if cctvRecordingIds.contains(camera.id) {
                        HStack(spacing: 2) {
                            Circle().fill(hackerRed).frame(width: 4, height: 4)
                            Text("REC")
                                .font(.system(size: 7, weight: .bold, design: .monospaced))
                                .foregroundColor(hackerRed)
                        }
                    }

                    Text("TAP TO VIEW >")
                        .font(.system(size: 7, weight: .bold, design: .monospaced))
                        .foregroundColor(hackerGreen.opacity(0.5))
                }
            }
            .padding(Spacing.md)
            .background(selectedCCTV?.id == camera.id ? hackerGreen.opacity(0.06) : hackerGreen.opacity(0.02))
            .overlay(RoundedRectangle(cornerRadius: 4).stroke(
                selectedCCTV?.id == camera.id ? hackerGreen.opacity(0.4) :
                camera.isOnline ? hackerGreen.opacity(0.1) : hackerRed.opacity(0.1), lineWidth: 0.5))
            .clipShape(RoundedRectangle(cornerRadius: 4))
        }
        .buttonStyle(.plain)
    }

    private func scanForCCTV() {
        isScanningCCTV = true
        cctvScanProgress = 0.0
        cctvCameras = []
        cctvConnectedCount = 0
        selectedCCTV = nil
        logActivity("CCTV_SCAN_START: radius=1000m protocols=RTSP,ONVIF,HTTP")

        let totalCams = CCTVCamera.mockCameras.count
        let stepDelay = 0.12 // faster scanning

        // Quick initial progress
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation { cctvScanProgress = 0.15 }
        }

        // Add cameras quickly
        for i in 0..<totalCams {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 + Double(i) * stepDelay) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    cctvScanProgress = 0.15 + 0.75 * (Double(i + 1) / Double(totalCams))
                    cctvCameras.append(CCTVCamera.mockCameras[i])
                    if CCTVCamera.mockCameras[i].isOnline {
                        cctvConnectedCount += 1
                    }
                }
                logActivity("CCTV_FOUND: \(CCTVCamera.mockCameras[i].name) [\(CCTVCamera.mockCameras[i].ip)]")
            }
        }

        // Finish fast
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 + Double(totalCams) * stepDelay + 0.2) {
            withAnimation {
                isScanningCCTV = false
                cctvScanProgress = 1.0
            }
            logActivity("CCTV_SCAN_DONE: \(cctvCameras.count) cameras, \(cctvConnectedCount) online")
        }
    }

    // MARK: - Tab 3: Network Monitor

    private var networkMonitorTab: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                hackerSection("NETWORK TRAFFIC MONITOR", icon: "network")
                Spacer()
                Button { refreshNetwork() } label: {
                    HStack(spacing: 4) {
                        if isRefreshingNetwork {
                            ProgressView().tint(hackerGreen).scaleEffect(0.6)
                        } else {
                            Image(systemName: "arrow.clockwise").font(.system(size: 10))
                        }
                        Text("REFRESH")
                            .font(.system(size: 8, weight: .bold, design: .monospaced))
                    }
                    .foregroundColor(hackerGreen)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(hackerGreen.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 3))
                }
                .buttonStyle(.plain)
                .disabled(isRefreshingNetwork)
            }

            // Throughput
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(String(format: "%.1f", networkThroughput)) GB/s")
                        .font(.system(size: 22, weight: .bold, design: .monospaced))
                        .foregroundColor(hackerGreen)
                    Text("THROUGHPUT")
                        .font(.system(size: 8, weight: .medium, design: .monospaced))
                        .foregroundColor(hackerDimGreen)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(networkConnections)")
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(hackerAmber)
                    Text("ACTIVE CONN")
                        .font(.system(size: 8, weight: .medium, design: .monospaced))
                        .foregroundColor(hackerDimGreen)
                }
            }
            .padding(Spacing.md)
            .background(hackerGreen.opacity(0.03))
            .overlay(RoundedRectangle(cornerRadius: 4).stroke(hackerGreen.opacity(0.1), lineWidth: 0.5))
            .clipShape(RoundedRectangle(cornerRadius: 4))

            // Traffic by region
            VStack(spacing: Spacing.sm) {
                ForEach(Array(trafficData.enumerated()), id: \.offset) { _, item in
                    hackerTraffic(item.0, item.1)
                }
            }

            // Firewall
            hackerSection("FIREWALL STATUS", icon: "lock.shield")
            VStack(spacing: Spacing.sm) {
                firewallRow("DDoS Protection", "ACTIVE", hackerGreen)
                firewallRow("Rate Limiter", overrideBypassRate ? "BYPASSED" : "ACTIVE", overrideBypassRate ? hackerAmber : hackerGreen)
                firewallRow("Geo-Blocking", "CONFIGURED", hackerAmber)
                firewallRow("SSL/TLS", "AES-512", hackerGreen)
                firewallRow("Intrusion Detection", overrideStealthMode ? "DISABLED" : "MONITORING", overrideStealthMode ? hackerRed : hackerCyan)
                firewallRow("Firewall", overrideDisableFirewall ? "DISABLED" : "ACTIVE", overrideDisableFirewall ? hackerRed : hackerGreen)
            }

            // Packet log
            hackerSection("LIVE PACKET LOG", icon: "antenna.radiowaves.left.and.right")
            VStack(alignment: .leading, spacing: 2) {
                ForEach(0..<6, id: \.self) { i in
                    let protos = ["TCP", "UDP", "HTTPS", "WSS", "DNS", "RTSP"]
                    let ips = ["45.33.32.1", "172.16.0.\(Int.random(in: 1...254))", "10.0.0.\(Int.random(in: 1...254))", "192.168.1.\(Int.random(in: 1...254))", "8.8.8.8", "1.1.1.1"]
                    HStack(spacing: 4) {
                        Text(protos[i % protos.count])
                            .font(.system(size: 7, weight: .bold, design: .monospaced))
                            .foregroundColor(hackerCyan)
                            .frame(width: 35, alignment: .leading)
                        Text(ips[i % ips.count])
                            .font(.system(size: 7, design: .monospaced))
                            .foregroundColor(hackerGreen.opacity(0.7))
                            .frame(width: 90, alignment: .leading)
                        Text("\(Int.random(in: 64...1500))B")
                            .font(.system(size: 7, design: .monospaced))
                            .foregroundColor(hackerDimGreen)
                        Spacer()
                        Text("\(Int.random(in: 1...50))ms")
                            .font(.system(size: 7, weight: .bold, design: .monospaced))
                            .foregroundColor(hackerAmber)
                    }
                }
            }
            .padding(Spacing.sm)
            .background(hackerBG)
            .overlay(RoundedRectangle(cornerRadius: 4).stroke(hackerGreen.opacity(0.15), lineWidth: 0.5))
            .clipShape(RoundedRectangle(cornerRadius: 4))
        }
    }

    private func refreshNetwork() {
        isRefreshingNetwork = true
        logActivity("NETWORK_REFRESH_START")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                networkThroughput = Double.random(in: 2.5...9.5)
                networkConnections = Int.random(in: 45000...150000)
                trafficData = [
                    ("Europe", Double.random(in: 0.5...0.98)),
                    ("Americas", Double.random(in: 0.4...0.9)),
                    ("Asia-Pacific", Double.random(in: 0.6...0.99)),
                    ("Africa", Double.random(in: 0.15...0.55)),
                    ("Middle East", Double.random(in: 0.2...0.65))
                ]
                isRefreshingNetwork = false
            }
            logActivity("NETWORK_REFRESH_DONE: \(String(format: "%.1f", networkThroughput))GB/s, \(networkConnections) conn")
        }
    }

    private func hackerTraffic(_ region: String, _ percent: Double) -> some View {
        HStack(spacing: Spacing.sm) {
            Text(region)
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .foregroundColor(hackerGreen)
                .frame(width: 80, alignment: .leading)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2).fill(hackerGreen.opacity(0.1))
                    RoundedRectangle(cornerRadius: 2)
                        .fill(hackerGreen)
                        .frame(width: geo.size.width * percent)
                }
            }
            .frame(height: 8)
            Text("\(Int(percent * 100))%")
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(hackerGreen)
                .frame(width: 30, alignment: .trailing)
        }
    }

    private func firewallRow(_ name: String, _ status: String, _ color: Color) -> some View {
        HStack {
            Circle().fill(color).frame(width: 6, height: 6)
            Text(name)
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(hackerGreen.opacity(0.8))
            Spacer()
            Text(status)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(color)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(color.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 3))
        }
    }

    // MARK: - Tab 4: Devices

    private let deviceList: [(String, String, String)] = [
        ("Creator iPhone 15 Pro", "iphone", "192.168.1.10"),
        ("MacBook Pro M3", "laptopcomputer", "192.168.1.15"),
        ("iPad Pro 12.9", "ipad", "192.168.1.20"),
        ("Smart TV LG 4K", "tv", "192.168.1.22"),
        ("Apple Watch Ultra", "applewatch", "BT-PAIRED"),
        ("HomePod Mini", "hifispeaker", "192.168.1.30"),
        ("Unknown Device", "questionmark.circle", "192.168.1.99"),
    ]

    private var deviceManagerTab: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            hackerSection("CONNECTED DEVICES", icon: "desktopcomputer")

            HStack(spacing: Spacing.sm) {
                Circle().fill(hackerGreen).frame(width: 6, height: 6)
                Text("\(deviceList.filter { deviceStates[$0.0] != "BLOCKED" && deviceStates[$0.0] != nil }.count) ACTIVE")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(hackerGreen)
                Spacer()
                Text("\(deviceList.count) TOTAL")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(hackerAmber)
            }
            .padding(Spacing.sm)
            .background(hackerGreen.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 3))

            VStack(spacing: Spacing.sm) {
                ForEach(Array(deviceList.enumerated()), id: \.offset) { _, dev in
                    let name = dev.0
                    let icon = dev.1
                    let ip = dev.2
                    let status = deviceStates[name] ?? "UNKNOWN"
                    let color = statusColor(status)
                    let isSelected = selectedDevice == name

                    VStack(spacing: 0) {
                        Button {
                            withAnimation { selectedDevice = isSelected ? nil : name }
                        } label: {
                            HStack(spacing: Spacing.md) {
                                Image(systemName: icon)
                                    .font(.system(size: 16))
                                    .foregroundColor(color)
                                    .frame(width: 24)
                                VStack(alignment: .leading, spacing: 1) {
                                    Text(name)
                                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                                        .foregroundColor(hackerGreen)
                                    Text(ip)
                                        .font(.system(size: 8, design: .monospaced))
                                        .foregroundColor(hackerDimGreen)
                                }
                                Spacer()
                                Text(status)
                                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                                    .foregroundColor(color)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(color.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 3))
                                Image(systemName: isSelected ? "chevron.up" : "chevron.down")
                                    .font(.system(size: 8))
                                    .foregroundColor(hackerDimGreen)
                            }
                        }
                        .buttonStyle(.plain)
                        .padding(Spacing.sm)

                        if isSelected {
                            VStack(spacing: Spacing.sm) {
                                Divider().background(hackerDimGreen.opacity(0.3))
                                // Action buttons
                                HStack(spacing: Spacing.sm) {
                                    Button {
                                        pingDevice(name: name, ip: ip)
                                    } label: {
                                        HStack(spacing: 3) {
                                            Image(systemName: "dot.radiowaves.left.and.right").font(.system(size: 9))
                                            Text("PING").font(.system(size: 8, weight: .bold, design: .monospaced))
                                        }
                                        .foregroundColor(hackerCyan)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(hackerCyan.opacity(0.1))
                                        .clipShape(RoundedRectangle(cornerRadius: 3))
                                    }
                                    .buttonStyle(.plain)

                                    Button {
                                        withAnimation {
                                            if status == "BLOCKED" {
                                                deviceStates[name] = "ONLINE"
                                                logActivity("DEVICE_UNBLOCKED: \(name)")
                                            } else {
                                                deviceStates[name] = "BLOCKED"
                                                logActivity("DEVICE_BLOCKED: \(name)")
                                            }
                                        }
                                    } label: {
                                        HStack(spacing: 3) {
                                            Image(systemName: status == "BLOCKED" ? "lock.open" : "lock").font(.system(size: 9))
                                            Text(status == "BLOCKED" ? "UNBLOCK" : "BLOCK").font(.system(size: 8, weight: .bold, design: .monospaced))
                                        }
                                        .foregroundColor(status == "BLOCKED" ? hackerGreen : hackerRed)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background((status == "BLOCKED" ? hackerGreen : hackerRed).opacity(0.1))
                                        .clipShape(RoundedRectangle(cornerRadius: 3))
                                    }
                                    .buttonStyle(.plain)

                                    Button {
                                        withAnimation { deviceStates[name] = "STANDBY" }
                                        logActivity("DEVICE_SLEEP: \(name)")
                                    } label: {
                                        HStack(spacing: 3) {
                                            Image(systemName: "moon").font(.system(size: 9))
                                            Text("SLEEP").font(.system(size: 8, weight: .bold, design: .monospaced))
                                        }
                                        .foregroundColor(hackerAmber)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(hackerAmber.opacity(0.1))
                                        .clipShape(RoundedRectangle(cornerRadius: 3))
                                    }
                                    .buttonStyle(.plain)

                                    Spacer()
                                }
                                .padding(.horizontal, Spacing.sm)

                                // Ping result
                                if let result = pingResults[name] {
                                    Text(result)
                                        .font(.system(size: 8, design: .monospaced))
                                        .foregroundColor(hackerGreen)
                                        .padding(Spacing.sm)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(hackerBG)
                                        .clipShape(RoundedRectangle(cornerRadius: 3))
                                        .padding(.horizontal, Spacing.sm)
                                }

                                // Device info
                                VStack(alignment: .leading, spacing: 2) {
                                    HStack {
                                        Text("MAC:").foregroundColor(hackerDimGreen)
                                        Text("\(UUID().uuidString.prefix(17).replacingOccurrences(of: "-", with: ":"))").foregroundColor(hackerGreen)
                                    }
                                    HStack {
                                        Text("LAST SEEN:").foregroundColor(hackerDimGreen)
                                        Text("\(Int.random(in: 1...59))s ago").foregroundColor(hackerAmber)
                                    }
                                    HStack {
                                        Text("BANDWIDTH:").foregroundColor(hackerDimGreen)
                                        Text("\(Int.random(in: 10...500)) KB/s").foregroundColor(hackerCyan)
                                    }
                                }
                                .font(.system(size: 7, design: .monospaced))
                                .padding(.horizontal, Spacing.sm)
                                .padding(.bottom, Spacing.sm)
                            }
                        }
                    }
                    .background(isSelected ? hackerGreen.opacity(0.04) : hackerGreen.opacity(0.02))
                    .overlay(RoundedRectangle(cornerRadius: 4).stroke(
                        isSelected ? hackerGreen.opacity(0.3) : hackerGreen.opacity(0.08), lineWidth: 0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                }
            }
        }
    }

    private func statusColor(_ status: String) -> Color {
        switch status {
        case "ONLINE": return hackerGreen
        case "IDLE": return hackerAmber
        case "SYNCED": return hackerCyan
        case "STANDBY": return hackerDimGreen
        case "BLOCKED": return hackerRed
        default: return hackerDimGreen
        }
    }

    private func pingDevice(name: String, ip: String) {
        logActivity("PING_START: \(ip)")
        pingResults[name] = "PINGING \(ip)..."
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            let ms = Double.random(in: 1.2...45.0)
            let lost = Int.random(in: 0...1)
            pingResults[name] = "PING \(ip): 4 sent, \(4 - lost) received, \(lost * 25)% loss\navg=\(String(format: "%.1f", ms))ms min=\(String(format: "%.1f", ms * 0.7))ms max=\(String(format: "%.1f", ms * 1.4))ms"
            logActivity("PING_DONE: \(ip) \(String(format: "%.1f", ms))ms")
        }
    }

    // MARK: - Tab 5: Exploit Tools

    private var exploitToolsTab: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            hackerSection("EXPLOIT & SECURITY TOOLS", icon: "lock.shield")

            HStack(spacing: Spacing.sm) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(hackerAmber)
                Text("For authorized security testing only")
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundColor(hackerAmber.opacity(0.7))
            }

            // Running exploit progress
            if let running = runningExploit {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    HStack {
                        ProgressView().tint(hackerAmber).scaleEffect(0.7)
                        Text("RUNNING: \(running)")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(hackerAmber)
                        Spacer()
                        Button {
                            withAnimation {
                                runningExploit = nil
                                exploitProgress = 0
                                exploitResults = []
                                exploitPhase = ""
                            }
                            logActivity("EXPLOIT_ABORT: \(running)")
                        } label: {
                            Text("ABORT")
                                .font(.system(size: 8, weight: .bold, design: .monospaced))
                                .foregroundColor(hackerRed)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(hackerRed.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 3))
                        }
                        .buttonStyle(.plain)
                    }

                    Text(exploitPhase)
                        .font(.system(size: 8, design: .monospaced))
                        .foregroundColor(hackerCyan)

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2).fill(hackerAmber.opacity(0.1))
                            RoundedRectangle(cornerRadius: 2)
                                .fill(hackerAmber)
                                .frame(width: geo.size.width * exploitProgress)
                        }
                    }
                    .frame(height: 4)
                }
                .padding(Spacing.md)
                .background(hackerAmber.opacity(0.04))
                .overlay(RoundedRectangle(cornerRadius: 4).stroke(hackerAmber.opacity(0.2), lineWidth: 0.5))
                .clipShape(RoundedRectangle(cornerRadius: 4))
            }

            // Exploit results
            if !exploitResults.isEmpty {
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text("SCAN RESULTS")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(hackerGreen)
                        Spacer()
                        Button {
                            withAnimation { exploitResults = [] }
                        } label: {
                            Text("CLEAR")
                                .font(.system(size: 7, weight: .bold, design: .monospaced))
                                .foregroundColor(hackerDimGreen)
                        }
                        .buttonStyle(.plain)
                    }
                    ForEach(Array(exploitResults.enumerated()), id: \.offset) { _, line in
                        Text(line)
                            .font(.system(size: 8, design: .monospaced))
                            .foregroundColor(line.contains("VULN") || line.contains("CRITICAL") ? hackerRed :
                                           line.contains("WARNING") || line.contains("MEDIUM") ? hackerAmber :
                                           line.contains("OK") || line.contains("SAFE") || line.contains("PASS") ? hackerGreen : hackerGreen.opacity(0.7))
                    }
                }
                .padding(Spacing.md)
                .background(hackerBG)
                .overlay(RoundedRectangle(cornerRadius: 4).stroke(hackerGreen.opacity(0.2), lineWidth: 0.5))
                .clipShape(RoundedRectangle(cornerRadius: 4))
            }

            VStack(spacing: Spacing.sm) {
                exploitTool("PORT SCANNER", "network", "Scan target for open ports", hackerGreen)
                exploitTool("PACKET SNIFFER", "antenna.radiowaves.left.and.right", "Capture network packets", hackerCyan)
                exploitTool("SQL INJECTION TEST", "syringe", "Test SQL injection vulnerabilities", hackerAmber)
                exploitTool("XSS SCANNER", "chevron.left.forwardslash.chevron.right", "Cross-site scripting test", hackerAmber)
                exploitTool("BRUTE FORCE", "key.fill", "Password strength tester", hackerRed)
                exploitTool("WIFI DEAUTH", "wifi.slash", "WiFi deauthentication test", hackerRed)
                exploitTool("DNS SPOOF DETECT", "globe", "Detect DNS spoofing attacks", hackerGreen)
                exploitTool("KEYLOGGER DETECT", "keyboard", "Detect keyloggers on system", hackerGreen)
                exploitTool("ROOTKIT SCANNER", "shield.lefthalf.filled", "Deep scan for rootkits", hackerCyan)
                exploitTool("PHISHING DETECTOR", "envelope.open", "Detect phishing attempts", hackerGreen)
            }
        }
    }

    private func exploitTool(_ name: String, _ icon: String, _ desc: String, _ color: Color) -> some View {
        Button { runExploit(name) } label: {
            HStack(spacing: Spacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(runningExploit == name ? hackerAmber : color)
                    .frame(width: 22)
                VStack(alignment: .leading, spacing: 1) {
                    Text(name)
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(hackerGreen)
                    Text(desc)
                        .font(.system(size: 8, design: .monospaced))
                        .foregroundColor(hackerDimGreen)
                }
                Spacer()
                Text(runningExploit == name ? "RUNNING" : "RUN")
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .foregroundColor(runningExploit == name ? hackerAmber : color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background((runningExploit == name ? hackerAmber : color).opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 3))
            }
            .padding(Spacing.sm)
            .background(runningExploit == name ? hackerAmber.opacity(0.04) : hackerGreen.opacity(0.02))
            .overlay(RoundedRectangle(cornerRadius: 4).stroke(
                runningExploit == name ? hackerAmber.opacity(0.2) : hackerGreen.opacity(0.08), lineWidth: 0.5))
            .clipShape(RoundedRectangle(cornerRadius: 4))
        }
        .buttonStyle(.plain)
        .disabled(runningExploit != nil)
    }

    private func runExploit(_ name: String) {
        runningExploit = name
        exploitProgress = 0.0
        exploitResults = []
        exploitPhase = "Initializing \(name)..."
        logActivity("EXPLOIT_START: \(name)")

        let results = exploitResultsFor(name)
        let stepCount = results.count

        for (i, result) in results.enumerated() {
            let delay = Double(i + 1) * 0.4 + Double.random(in: 0.1...0.3)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                guard runningExploit == name else { return }
                withAnimation(.easeInOut(duration: 0.2)) {
                    exploitProgress = Double(i + 1) / Double(stepCount)
                    exploitPhase = "Step \(i + 1)/\(stepCount): Processing..."
                    exploitResults.append(result)
                }
            }
        }

        // Complete
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(stepCount) * 0.4 + 0.8) {
            guard runningExploit == name else { return }
            withAnimation {
                exploitProgress = 1.0
                exploitPhase = "COMPLETE"
                runningExploit = nil
            }
            logActivity("EXPLOIT_DONE: \(name) \u{2014} \(stepCount) checks")
        }
    }

    private func exploitResultsFor(_ name: String) -> [String] {
        switch name {
        case "PORT SCANNER":
            return [
                "[SCAN] Target: 192.168.1.0/24",
                "[OK] Port 22 (SSH) \u{2014} OPEN \u{2014} OpenSSH 9.2",
                "[OK] Port 80 (HTTP) \u{2014} OPEN \u{2014} nginx/1.25",
                "[OK] Port 443 (HTTPS) \u{2014} OPEN \u{2014} nginx/1.25",
                "[WARNING] Port 3306 (MySQL) \u{2014} OPEN \u{2014} Exposed!",
                "[OK] Port 5432 (PostgreSQL) \u{2014} FILTERED",
                "[OK] Port 8080 (HTTP-Proxy) \u{2014} OPEN",
                "[RESULT] 7 ports scanned, 5 open, 1 filtered, 1 WARNING",
            ]
        case "PACKET SNIFFER":
            return [
                "[CAPTURE] Interface: wlan0 (monitor mode)",
                "[PKT] TCP 192.168.1.10:443 -> 172.217.0.1:443 (TLS 1.3) 1420B",
                "[PKT] UDP 192.168.1.1:53 -> 8.8.8.8:53 (DNS) 64B",
                "[PKT] TCP 192.168.1.15:8080 -> 10.0.0.5:3000 (HTTP) 890B",
                "[PKT] ARP 192.168.1.22 -> broadcast (who-has 192.168.1.1)",
                "[PKT] ICMP 192.168.1.42 -> 1.1.1.1 (echo request) 64B",
                "[RESULT] 847 packets captured, 0 suspicious, traffic SAFE",
            ]
        case "SQL INJECTION TEST":
            return [
                "[TEST] Target: http://192.168.1.42:8080/api",
                "[PASS] GET /api/users?id=1 OR 1=1 \u{2014} BLOCKED",
                "[PASS] POST /api/login \u{2014} Parameterized queries detected",
                "[WARNING] GET /api/search?q=' UNION SELECT \u{2014} MEDIUM risk",
                "[PASS] POST /api/data \u{2014} Input sanitization OK",
                "[RESULT] 4 endpoints tested, 1 MEDIUM risk, 3 SAFE",
            ]
        case "XSS SCANNER":
            return [
                "[SCAN] Testing cross-site scripting vectors...",
                "[PASS] <script>alert(1)</script> \u{2014} BLOCKED by CSP",
                "[PASS] <img onerror=alert(1)> \u{2014} SANITIZED",
                "[WARNING] javascript:void(0) in href \u{2014} MEDIUM risk",
                "[PASS] DOM-based XSS check \u{2014} SAFE",
                "[RESULT] 4 vectors tested, 1 MEDIUM risk, CSP headers present",
            ]
        case "BRUTE FORCE":
            return [
                "[INIT] Loading wordlist: rockyou.txt (14M entries)",
                "[TEST] admin:admin \u{2014} FAILED",
                "[TEST] admin:password123 \u{2014} FAILED",
                "[TEST] root:toor \u{2014} FAILED",
                "[TEST] admin:neural \u{2014} FAILED",
                "[OK] Rate limiter active: 3 attempts/min",
                "[RESULT] PASS \u{2014} Brute force protection is ACTIVE",
            ]
        case "WIFI DEAUTH":
            return [
                "[INIT] Monitor mode: wlan0mon",
                "[SCAN] Detecting access points...",
                "[FOUND] NeuralEther_5G (CH:36) \u{2014} 5 clients",
                "[DEAUTH] Sending deauth frame to FF:FF:FF:FF:FF:FF",
                "[OK] 3/5 clients disconnected temporarily",
                "[RECONNECT] All clients reconnected in 2.3s",
                "[RESULT] Network recovery: FAST \u{2014} WPA3 protection OK",
            ]
        case "DNS SPOOF DETECT":
            return [
                "[CHECK] Querying DNS resolvers...",
                "[OK] 8.8.8.8 (Google) \u{2014} Response matches expected",
                "[OK] 1.1.1.1 (Cloudflare) \u{2014} Response matches expected",
                "[OK] 192.168.1.1 (Local) \u{2014} No spoofing detected",
                "[OK] DNSSEC validation: PASS",
                "[RESULT] DNS is SAFE \u{2014} No spoofing detected",
            ]
        case "KEYLOGGER DETECT":
            return [
                "[SCAN] Checking running processes...",
                "[OK] No suspicious keyboard hooks found",
                "[OK] Input monitoring: System only (no third-party)",
                "[OK] Clipboard access: Normal",
                "[OK] USB HID devices: 2 (keyboard, mouse) \u{2014} verified",
                "[RESULT] System CLEAN \u{2014} No keyloggers detected",
            ]
        case "ROOTKIT SCANNER":
            return [
                "[DEEP SCAN] Checking kernel modules...",
                "[OK] Kernel integrity: VERIFIED",
                "[OK] System calls: No hooks detected",
                "[OK] Hidden processes: None found",
                "[OK] Hidden files: None found",
                "[OK] Network backdoors: None detected",
                "[RESULT] System CLEAN \u{2014} Security score: 98/100",
            ]
        case "PHISHING DETECTOR":
            return [
                "[SCAN] Checking recent emails and URLs...",
                "[OK] 142 URLs checked \u{2014} All legitimate",
                "[WARNING] 2 suspicious sender domains flagged",
                "[OK] SSL certificates: All valid",
                "[OK] Domain age check: All > 1 year",
                "[RESULT] 2 WARNING items flagged for review, 140 SAFE",
            ]
        default:
            return ["[RESULT] Scan complete \u{2014} No issues found"]
        }
    }

    // MARK: - Tab 6: File System

    private let fsStructure: [String: [(String, String, String, String, String, Bool)]] = [
        "/": [
            ("drwxr-xr-x", "4096", "/etc", "folder.fill", "System configuration", true),
            ("drwxr-xr-x", "12288", "/var", "folder.fill", "Variable data", true),
            ("drwx------", "8192", "/data", "folder.fill", "Application data", true),
            ("-rwx------", "2048", "/usr/bin/neural-core", "terminal", "Core binary", false),
            ("lrwxrwxrwx", "24", "/tmp -> /dev/null", "link", "Temp symlink", false),
        ],
        "/etc": [
            ("-rw-r--r--", "2048", "neural.conf", "doc.text", "Main config", false),
            ("-rw-------", "512", "master.key", "key.fill", "Master encryption key", false),
            ("-rw-r--r--", "1024", "firewall.rules", "flame", "Firewall rules", false),
            ("-rw-r--r--", "256", "hosts", "doc.text", "Host mappings", false),
            ("drwxr-xr-x", "4096", "ssl/", "folder.fill", "SSL certificates", true),
        ],
        "/var": [
            ("drwxr-xr-x", "12288", "log/", "folder.fill", "System logs", true),
            ("drwxr-xr-x", "4096", "www/", "globe", "Web root", true),
            ("-rw-r--r--", "8MB", "neural.log", "doc.text", "Main log file", false),
        ],
        "/data": [
            ("-rw-r--r--", "1.2GB", "ai-model.bin", "brain", "AI model weights", false),
            ("-rw-r--r--", "256MB", "search-index.db", "cylinder", "Search database", false),
            ("drwx------", "8192", "users/", "folder.fill.badge.person.crop", "User data", true),
            ("-rw-r--r--", "64MB", "cache.db", "cylinder", "Cache database", false),
        ],
    ]

    private let fsFileContents: [String: String] = [
        "neural.conf": "# Neural Ether OS Configuration\nversion=3.7.1\nmode=sovereign\nai_engine=enabled\nmax_nodes=175\ndata_centers=47\nencryption=AES-512-GCM\nfirewall=active\nlog_level=INFO",
        "master.key": "[ENCRYPTED] AES-512-GCM\nKey ID: NE-MASTER-2026\nFingerprint: 7A:3B:9C:...:F2\nCreated: 2026-01-01\nExpires: 2027-01-01",
        "firewall.rules": "# Firewall Rules\nALLOW TCP 443 IN\nALLOW TCP 80 IN\nALLOW TCP 22 FROM 10.0.0.0/8\nDENY TCP 3306 IN\nALLOW UDP 53 OUT\nDENY ALL IN DEFAULT",
        "hosts": "127.0.0.1 localhost\n192.168.1.42 neural-ether\n10.0.0.1 gateway\n8.8.8.8 dns-primary",
        "neural.log": "[2026-03-24 17:00:01] [INFO] System boot complete\n[2026-03-24 17:00:02] [INFO] AI engine initialized\n[2026-03-24 17:00:03] [INFO] 175 nodes connected\n[2026-03-24 17:00:04] [WARN] High CPU usage: 87%\n[2026-03-24 17:00:05] [INFO] Search index loaded (12.4M sources)",
    ]

    private var fileSystemTab: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            hackerSection("FILE SYSTEM EXPLORER", icon: "folder.fill")

            // Breadcrumb / path bar
            HStack(spacing: 4) {
                Text("root@neural-ether:")
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .foregroundColor(hackerGreen)
                Text(currentPath)
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(hackerCyan)
                Text("$ ls -la")
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundColor(hackerDimGreen)
                Spacer()
                if currentPath != "/" {
                    Button {
                        withAnimation {
                            // Go up one level
                            let parts = currentPath.split(separator: "/").dropLast()
                            currentPath = parts.isEmpty ? "/" : "/" + parts.joined(separator: "/")
                            fileContent = nil
                            selectedFile = nil
                        }
                    } label: {
                        HStack(spacing: 3) {
                            Image(systemName: "arrow.left").font(.system(size: 9))
                            Text("BACK").font(.system(size: 8, weight: .bold, design: .monospaced))
                        }
                        .foregroundColor(hackerAmber)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(hackerAmber.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 3))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(Spacing.sm)
            .background(hackerGreen.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 3))

            // File listing
            VStack(alignment: .leading, spacing: 4) {
                let entries = fsStructure[currentPath] ?? []
                if entries.isEmpty {
                    Text("[empty directory]")
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(hackerDimGreen)
                        .padding(Spacing.md)
                } else {
                    ForEach(Array(entries.enumerated()), id: \.offset) { _, entry in
                        let isDir = entry.5
                        let fileName = entry.2
                        let color: Color = isDir ? hackerCyan : (fileName.contains("key") ? hackerAmber : hackerGreen)
                        Button {
                            if isDir {
                                withAnimation {
                                    let target = fileName.hasSuffix("/") ? String(fileName.dropLast()) : fileName
                                    if currentPath == "/" {
                                        currentPath = target.hasPrefix("/") ? target : "/\(target)"
                                    } else {
                                        currentPath = "\(currentPath)/\(target)"
                                    }
                                    fileContent = nil
                                    selectedFile = nil
                                }
                                logActivity("FS_NAVIGATE: \(currentPath)")
                            } else {
                                withAnimation {
                                    let key = fileName.components(separatedBy: "/").last ?? fileName
                                    selectedFile = fileName
                                    fileContent = fsFileContents[key] ?? "[BINARY DATA] \(entry.1) \u{2014} Cannot display binary content"
                                }
                                logActivity("FS_READ: \(fileName)")
                            }
                        } label: {
                            HStack(spacing: Spacing.sm) {
                                Image(systemName: entry.3)
                                    .font(.system(size: 10))
                                    .foregroundColor(color)
                                    .frame(width: 16)
                                Text(entry.0)
                                    .font(.system(size: 8, design: .monospaced))
                                    .foregroundColor(hackerDimGreen)
                                    .frame(width: 80, alignment: .leading)
                                Text(entry.1)
                                    .font(.system(size: 8, design: .monospaced))
                                    .foregroundColor(hackerDimGreen)
                                    .frame(width: 50, alignment: .trailing)
                                Text(fileName)
                                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                                    .foregroundColor(color)
                                Spacer()
                                if isDir {
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 8))
                                        .foregroundColor(hackerDimGreen)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(Spacing.md)
            .background(hackerBG)
            .overlay(RoundedRectangle(cornerRadius: 4).stroke(hackerGreen.opacity(0.2), lineWidth: 0.5))
            .clipShape(RoundedRectangle(cornerRadius: 4))

            // File content viewer
            if let content = fileContent, let file = selectedFile {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    HStack {
                        Image(systemName: "doc.text").font(.system(size: 10)).foregroundColor(hackerAmber)
                        Text(file)
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(hackerAmber)
                        Spacer()
                        Button {
                            withAnimation { fileContent = nil; selectedFile = nil }
                        } label: {
                            Image(systemName: "xmark").font(.system(size: 10)).foregroundColor(hackerRed)
                        }
                        .buttonStyle(.plain)
                    }
                    Divider().background(hackerDimGreen.opacity(0.3))
                    Text(content)
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(hackerGreen)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(Spacing.md)
                .background(hackerBG)
                .overlay(RoundedRectangle(cornerRadius: 4).stroke(hackerAmber.opacity(0.3), lineWidth: 0.5))
                .clipShape(RoundedRectangle(cornerRadius: 4))
            }
        }
    }

    // MARK: - Tab 7: +18 Content

    @State private var adultCategories: [String: Bool] = [
        "Movies & Shows": true,
        "Live Streaming": true,
        "Premium Content": true,
        "VR Experiences": false,
        "Explicit Images": false,
        "Dating & Chat": true,
    ]
    @State private var adultAgeVerified: Bool = true
    @State private var adultFilterLevel: Double = 3.0
    @State private var adultSelectedCategory: String = "Movies & Shows"

    private var adultContentTab: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            hackerSection("+18 ADULT CONTENT CONTROL", icon: "eye.fill")

            // Age verification
            if !adultAgeVerified {
                VStack(spacing: Spacing.md) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(hackerRed)
                    Text("AGE VERIFICATION REQUIRED")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(hackerRed)
                    Text("You must be 18 or older to access this section.")
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(hackerDimGreen)
                        .multilineTextAlignment(.center)

                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            adultAgeVerified = true
                            orchestrator.adultContentEnabled = true
                        }
                        logActivity("+18_AGE_VERIFIED: User confirmed 18+")
                    } label: {
                        Text("I AM 18+ \u{2014} ENTER")
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                            .foregroundColor(hackerBG)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(hackerRed)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    .buttonStyle(.plain)
                }
                .padding(Spacing.lg)
                .background(hackerRed.opacity(0.05))
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(hackerRed.opacity(0.3), lineWidth: 1))
                .clipShape(RoundedRectangle(cornerRadius: 6))
            } else {
                // Master toggle
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: Spacing.sm) {
                            Circle().fill(orchestrator.adultContentEnabled ? hackerRed : hackerDimGreen).frame(width: 8, height: 8)
                            Text("+18 CONTENT ACCESS")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(hackerGreen)
                        }
                        Text(orchestrator.adultContentEnabled ? "UNLOCKED \u{2014} Content accessible" : "LOCKED \u{2014} All content filtered")
                            .font(.system(size: 8, design: .monospaced))
                            .foregroundColor(orchestrator.adultContentEnabled ? hackerRed : hackerDimGreen)
                    }
                    Spacer()
                    Toggle("", isOn: Binding(
                        get: { orchestrator.adultContentEnabled },
                        set: { newVal in
                            withAnimation(.easeInOut(duration: 0.2)) {
                                orchestrator.adultContentEnabled = newVal
                            }
                            logActivity(newVal ? "+18_CONTENT_UNLOCKED" : "+18_CONTENT_LOCKED")
                        }
                    ))
                    .toggleStyle(HackerToggleStyle())
                    .labelsHidden()
                }
                .padding(Spacing.md)
                .background(orchestrator.adultContentEnabled ? hackerRed.opacity(0.05) : hackerGreen.opacity(0.03))
                .overlay(RoundedRectangle(cornerRadius: 4).stroke(
                    orchestrator.adultContentEnabled ? hackerRed.opacity(0.3) : hackerGreen.opacity(0.1), lineWidth: 0.5))
                .clipShape(RoundedRectangle(cornerRadius: 4))

                if orchestrator.adultContentEnabled {
                    // Category selector (horizontal scroll)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            adultCatBtn("Movies & Shows", icon: "film.fill")
                            adultCatBtn("Live Streaming", icon: "video.fill")
                            adultCatBtn("Premium Content", icon: "star.fill")
                            adultCatBtn("VR Experiences", icon: "eye.circle.fill")
                            adultCatBtn("Explicit Images", icon: "photo.fill")
                            adultCatBtn("Dating & Chat", icon: "bubble.left.and.bubble.right.fill")
                        }
                    }

                    // VISIBLE CONTENT GRID - shows immediately
                    adultContentGrid

                    // Now Playing bar
                    HStack(spacing: Spacing.sm) {
                        Image(systemName: "play.fill").font(.system(size: 10)).foregroundColor(hackerRed)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(adultSelectedCategory) \u{2014} Stream #\(Int.random(in: 1...999))")
                                .font(.system(size: 8, weight: .bold, design: .monospaced))
                                .foregroundColor(hackerAmber)
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 1).fill(hackerRed.opacity(0.1))
                                    RoundedRectangle(cornerRadius: 1).fill(hackerRed.opacity(0.6))
                                        .frame(width: geo.size.width * CGFloat.random(in: 0.1...0.9))
                                }
                            }
                            .frame(height: 3)
                        }
                        Text("\(Int.random(in: 1...59)):" + String(format: "%02d", Int.random(in: 0...59)) + " / " + "\(Int.random(in: 20...90)):" + String(format: "%02d", Int.random(in: 0...59)))
                            .font(.system(size: 7, design: .monospaced))
                            .foregroundColor(hackerDimGreen)
                    }
                    .padding(Spacing.md)
                    .background(hackerRed.opacity(0.03))
                    .clipShape(RoundedRectangle(cornerRadius: 4))

                    // Stats
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 6) {
                        adultStatBox("Total", "\(74476 + Int.random(in: 0...50))")
                        adultStatBox("Live", "\(340 + Int.random(in: 0...20))")
                        adultStatBox("Online", "\(8900 + Int.random(in: 0...200))")
                    }
                } else {
                    VStack(spacing: Spacing.md) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 24))
                            .foregroundColor(hackerDimGreen)
                        Text("CONTENT FILTER ACTIVE")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(hackerDimGreen)
                        Text("Toggle the switch above to unlock")
                            .font(.system(size: 8, design: .monospaced))
                            .foregroundColor(hackerDimGreen)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(Spacing.xl)
                }
            }
        }
    }

    private func adultCatBtn(_ name: String, icon: String) -> some View {
        Button {
            withAnimation { adultSelectedCategory = name }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: icon).font(.system(size: 9))
                Text(name).font(.system(size: 8, weight: .bold, design: .monospaced))
            }
            .foregroundColor(adultSelectedCategory == name ? hackerBG : hackerRed.opacity(0.7))
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(adultSelectedCategory == name ? hackerRed : hackerRed.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 4))
        }
        .buttonStyle(.plain)
    }

    private var adultContentGrid: some View {
        let contentItems: [(String, String, String, Int)] = [
            ("Trending Now", "flame.fill", "18K views", 98),
            ("New Release", "star.fill", "12K views", 95),
            ("Most Popular", "heart.fill", "45K views", 99),
            ("Exclusive HD", "crown.fill", "8.5K views", 92),
            ("Live Premium", "bolt.fill", "3.2K live", 88),
            ("VIP Access", "diamond.fill", "6.1K views", 96),
            ("Top Rated", "trophy.fill", "22K views", 97),
            ("Editor Pick", "wand.and.stars", "15K views", 94),
            ("Hot Today", "sparkles", "31K views", 93),
        ]

        return VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Text("\(adultSelectedCategory.uppercased()) \u{2014} CONTENT")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(hackerAmber)
                Spacer()
                Text("\(contentItems.count) RESULTS")
                    .font(.system(size: 8, design: .monospaced))
                    .foregroundColor(hackerDimGreen)
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(0..<contentItems.count, id: \.self) { i in
                    let item = contentItems[i]
                    Button {
                        logActivity("+18_PLAY: \(adultSelectedCategory) \u{2014} \(item.0)")
                    } label: {
                        VStack(spacing: 0) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(LinearGradient(
                                        colors: [hackerRed.opacity(0.15), Color(hex: "#1A0005")],
                                        startPoint: .top, endPoint: .bottom
                                    ))
                                    .aspectRatio(16.0/10.0, contentMode: .fit)

                                VStack(spacing: 4) {
                                    Image(systemName: item.1)
                                        .font(.system(size: 20))
                                        .foregroundColor(hackerRed.opacity(0.7))
                                    Image(systemName: "play.circle.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.6))
                                }

                                VStack {
                                    Spacer()
                                    HStack {
                                        Spacer()
                                        Text("\(Int.random(in: 5...120)):" + String(format: "%02d", Int.random(in: 0...59)))
                                            .font(.system(size: 6, weight: .bold, design: .monospaced))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 4)
                                            .padding(.vertical, 1)
                                            .background(Color.black.opacity(0.7))
                                            .clipShape(RoundedRectangle(cornerRadius: 2))
                                    }
                                    .padding(3)
                                }

                                VStack {
                                    HStack {
                                        Text("HD")
                                            .font(.system(size: 6, weight: .bold))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 3)
                                            .padding(.vertical, 1)
                                            .background(hackerRed.opacity(0.8))
                                            .clipShape(RoundedRectangle(cornerRadius: 2))
                                        Spacer()
                                    }
                                    .padding(3)
                                    Spacer()
                                }
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 6))

                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.0)
                                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                                    .foregroundColor(hackerAmber)
                                    .lineLimit(1)
                                HStack(spacing: 3) {
                                    Text(item.2)
                                        .font(.system(size: 6, design: .monospaced))
                                        .foregroundColor(hackerDimGreen)
                                    Spacer()
                                    Text("\(item.3)%")
                                        .font(.system(size: 6, weight: .bold, design: .monospaced))
                                        .foregroundColor(hackerGreen)
                                }
                            }
                            .padding(.horizontal, 2)
                            .padding(.top, 4)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(Spacing.md)
        .background(hackerRed.opacity(0.03))
        .overlay(RoundedRectangle(cornerRadius: 4).stroke(hackerRed.opacity(0.15), lineWidth: 0.5))
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }

    private func adultStatBox(_ label: String, _ value: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(hackerRed)
            Text(label)
                .font(.system(size: 7, design: .monospaced))
                .foregroundColor(hackerDimGreen)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(hackerRed.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }

    // MARK: - Tab 8: System Override

    private var systemOverrideTab: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            hackerSection("SYSTEM OVERRIDE", icon: "gearshape.2.fill")

            HStack(spacing: Spacing.sm) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 12)).foregroundColor(hackerRed)
                Text("DANGER ZONE \u{2014} Use with caution")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(hackerRed)
            }

            VStack(spacing: Spacing.sm) {
                overrideToggle("BYPASS RATE LIMITER", $overrideBypassRate, hackerAmber) {
                    logActivity(overrideBypassRate ? "OVERRIDE: Rate limiter BYPASSED" : "OVERRIDE: Rate limiter RESTORED")
                }
                overrideToggle("FORCE ADMIN MODE", $overrideForceAdmin, hackerGreen) {
                    logActivity(overrideForceAdmin ? "OVERRIDE: Admin mode FORCED" : "OVERRIDE: Admin mode NORMAL")
                }
                overrideToggle("DISABLE FIREWALL", $overrideDisableFirewall, hackerRed) {
                    logActivity(overrideDisableFirewall ? "WARNING: Firewall DISABLED" : "OVERRIDE: Firewall RE-ENABLED")
                }
                overrideToggle("RAW API ACCESS", $overrideRawAPI, hackerCyan) {
                    logActivity(overrideRawAPI ? "OVERRIDE: Raw API access ENABLED" : "OVERRIDE: Raw API access DISABLED")
                }
                overrideToggle("DEBUG MODE", $overrideDebugMode, hackerAmber) {
                    logActivity(overrideDebugMode ? "OVERRIDE: Debug mode ON" : "OVERRIDE: Debug mode OFF")
                }
                overrideToggle("STEALTH MODE", $overrideStealthMode, hackerDimGreen) {
                    logActivity(overrideStealthMode ? "OVERRIDE: Stealth mode ACTIVATED" : "OVERRIDE: Stealth mode DEACTIVATED")
                }
            }

            // Performance (live-updating)
            HStack {
                hackerSection("SYSTEM PERFORMANCE", icon: "gauge.with.dots.needle.67percent")
                Spacer()
                Button {
                    withAnimation {
                        cpuUsage = Double.random(in: 0.4...0.99)
                        memUsage = Double.random(in: 0.3...0.95)
                        diskIO = Double.random(in: 0.1...0.8)
                        gpuUsage = Double.random(in: 0.5...0.99)
                        netUsage = Double.random(in: 0.2...0.9)
                    }
                    logActivity("PERF_REFRESH: CPU=\(Int(cpuUsage*100))% MEM=\(Int(memUsage*100))%")
                } label: {
                    HStack(spacing: 3) {
                        Image(systemName: "arrow.clockwise").font(.system(size: 8))
                        Text("REFRESH").font(.system(size: 7, weight: .bold, design: .monospaced))
                    }
                    .foregroundColor(hackerGreen)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(hackerGreen.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 3))
                }
                .buttonStyle(.plain)
            }
            VStack(spacing: Spacing.sm) {
                perfBar("CPU USAGE", cpuUsage, cpuUsage > 0.9 ? hackerRed : hackerGreen)
                perfBar("MEMORY", memUsage, memUsage > 0.9 ? hackerRed : hackerCyan)
                perfBar("DISK I/O", diskIO, hackerAmber)
                perfBar("GPU", gpuUsage, gpuUsage > 0.9 ? hackerRed : hackerGreen)
                perfBar("NETWORK", netUsage, hackerCyan)
            }

            // Kill switch
            hackerSection("EMERGENCY", icon: "bolt.trianglebadge.exclamationmark")
            Button {
                withAnimation {
                    overrideBypassRate = false
                    overrideDisableFirewall = false
                    overrideRawAPI = false
                    overrideStealthMode = false
                }
                logActivity("EMERGENCY: All overrides RESET to safe defaults")
            } label: {
                HStack(spacing: Spacing.sm) {
                    Image(systemName: "exclamationmark.octagon.fill").font(.system(size: 14))
                    Text("RESET ALL OVERRIDES TO SAFE")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                }
                .foregroundColor(hackerBG)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.md)
                .background(hackerRed)
                .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            .buttonStyle(.plain)
        }
    }

    private func overrideToggle(_ label: String, _ isOn: Binding<Bool>, _ color: Color, onChange: @escaping () -> Void = {}) -> some View {
        HStack {
            HStack(spacing: Spacing.sm) {
                Circle().fill(isOn.wrappedValue ? color : hackerDimGreen.opacity(0.5)).frame(width: 6, height: 6)
                Text(label)
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundColor(hackerGreen)
            }
            Spacer()
            Text(isOn.wrappedValue ? "ON" : "OFF")
                .font(.system(size: 7, weight: .bold, design: .monospaced))
                .foregroundColor(isOn.wrappedValue ? color : hackerDimGreen)
            Toggle("", isOn: isOn)
                .toggleStyle(HackerToggleStyle())
                .labelsHidden()
                .onChange(of: isOn.wrappedValue) { _ in onChange() }
        }
        .padding(Spacing.sm)
        .background(isOn.wrappedValue ? color.opacity(0.05) : color.opacity(0.02))
        .overlay(RoundedRectangle(cornerRadius: 4).stroke(
            isOn.wrappedValue ? color.opacity(0.2) : color.opacity(0.08), lineWidth: 0.5))
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }

    private func perfBar(_ label: String, _ value: Double, _ color: Color) -> some View {
        HStack(spacing: Spacing.sm) {
            Text(label)
                .font(.system(size: 8, weight: .medium, design: .monospaced))
                .foregroundColor(hackerGreen.opacity(0.7))
                .frame(width: 70, alignment: .leading)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2).fill(color.opacity(0.1))
                    RoundedRectangle(cornerRadius: 2)
                        .fill(color)
                        .frame(width: geo.size.width * value)
                        .animation(.easeInOut(duration: 0.4), value: value)
                }
            }
            .frame(height: 8)
            Text("\(Int(value * 100))%")
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(color)
                .frame(width: 30, alignment: .trailing)
        }
    }

    // MARK: - Tab 9: Activity Log

    private var activityLogTab: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                hackerSection("ACTIVITY LOG", icon: "list.bullet.rectangle")
                Spacer()
                Button {
                    activityLog.removeAll()
                    logActivity("LOG_CLEARED")
                } label: {
                    Text("CLEAR")
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .foregroundColor(hackerRed)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(hackerRed.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 3))
                }
                .buttonStyle(.plain)
            }

            ForEach(Array(activityLog.enumerated()), id: \.element.id) { _, entry in
                HStack(alignment: .top, spacing: Spacing.sm) {
                    Text(entry.time)
                        .font(.system(size: 8, design: .monospaced))
                        .foregroundColor(hackerDimGreen)
                        .frame(width: 55, alignment: .leading)
                    Circle().fill(entry.color).frame(width: 5, height: 5).padding(.top, 4)
                    Text(entry.message)
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(entry.color)
                }
            }
        }
    }

    // MARK: - Shared Components

    private func hackerSection(_ title: String, icon: String) -> some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(hackerGreen)
            Text(title)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(hackerGreen)
        }
    }

    private func hackerBtn(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(hackerGreen)
                Text(label)
                    .font(.system(size: 7, weight: .bold, design: .monospaced))
                    .foregroundColor(hackerGreen.opacity(0.6))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.md)
            .background(hackerGreen.opacity(0.05))
            .overlay(RoundedRectangle(cornerRadius: 4).stroke(hackerGreen.opacity(0.15), lineWidth: 0.5))
            .clipShape(RoundedRectangle(cornerRadius: 4))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Auth

    private func authenticateCreator() {
        if accessCode == "test123" {
            withAnimation(.easeInOut(duration: 0.3)) {
                authAnimating = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    isAuthenticated = true
                    showAccessDenied = false
                    matrixTimer?.invalidate()
                }
                logActivity("AUTH_SUCCESS \u{2014} Creator access granted")
                orchestrator.systemLogs.insert(
                    LogEntry(timestamp: Date(), level: .info, module: "CREATOR",
                             message: "AUTHENTICATION_SUCCESS \u{2014} Sovereign access granted."),
                    at: 0
                )
            }
        } else {
            withAnimation { showAccessDenied = true }
            logActivity("AUTH_FAILED \u{2014} Invalid code attempt")
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation { showAccessDenied = false }
            }
        }
    }

    private func logActivity(_ message: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        let entry = ActivityEntry(
            time: formatter.string(from: Date()),
            message: message,
            color: message.contains("FAILED") || message.contains("DENIED") ? hackerRed :
                   message.contains("WARNING") ? hackerAmber : hackerGreen
        )
        activityLog.insert(entry, at: 0)
    }
}

// MARK: - Models

struct TerminalLine: Identifiable {
    let id = UUID()
    let text: String
    let color: Color
    let isCommand: Bool
}

struct MatrixColumn: Identifiable {
    let id = UUID()
    let char: String
    let x: CGFloat
    let y: CGFloat
    let opacity: Double
}

struct ActivityEntry: Identifiable {
    let id = UUID()
    let time: String
    let message: String
    var color: Color = Color(hex: "#00FF41")

    static let initial: [ActivityEntry] = [
        ActivityEntry(time: "00:00:00", message: "SYSTEM_BOOT \u{2014} Neural Ether OS initialized"),
        ActivityEntry(time: "00:00:01", message: "FIREWALL_ACTIVE \u{2014} All ports secured"),
        ActivityEntry(time: "00:00:02", message: "AI_ENGINE_READY \u{2014} Search engine online"),
        ActivityEntry(time: "00:00:03", message: "MODULES_LOADED \u{2014} 10 modules active"),
    ]
}

struct WiFiNetwork: Identifiable {
    let id = UUID()
    let name: String
    var signal: Int
    let secured: Bool
    let mac: String
    let channel: Int
    let encryption: String
    let password: String

    var signalIcon: String {
        if signal > -30 { return "wifi" }
        if signal > -50 { return "wifi" }
        if signal > -70 { return "wifi" }
        return "wifi.exclamationmark"
    }

    var signalColor: Color {
        if signal > -50 { return Color(hex: "#00FF41") }
        if signal > -70 { return Color(hex: "#FFB000") }
        return Color(hex: "#FF0033")
    }

    static let mockNetworks: [WiFiNetwork] = [
        WiFiNetwork(name: "NeuralEther_5G", signal: -25, secured: true, mac: "00:1A:2B:3C:4D:5E", channel: 36, encryption: "WPA3", password: "N3ur@l_Eth3r!2026"),
        WiFiNetwork(name: "HomeNetwork_2.4G", signal: -42, secured: true, mac: "AA:BB:CC:DD:EE:FF", channel: 6, encryption: "WPA2", password: "MyH0m3P@ss#99"),
        WiFiNetwork(name: "CafeWiFi_Free", signal: -55, secured: false, mac: "11:22:33:44:55:66", channel: 11, encryption: "OPEN", password: ""),
        WiFiNetwork(name: "Neighbor_5G", signal: -68, secured: true, mac: "77:88:99:AA:BB:CC", channel: 44, encryption: "WPA2", password: "V3c1n_Secur3!x"),
        WiFiNetwork(name: "IoT_Devices", signal: -35, secured: true, mac: "DD:EE:FF:00:11:22", channel: 1, encryption: "WPA", password: "iot12345"),
        WiFiNetwork(name: "Guest_Network", signal: -73, secured: false, mac: "33:44:55:66:77:88", channel: 9, encryption: "OPEN", password: ""),
        WiFiNetwork(name: "5G_Ultra_Fast", signal: -30, secured: true, mac: "99:AA:BB:CC:DD:EE", channel: 149, encryption: "WPA3", password: "Ultr@F@st_5G!#2026"),
        WiFiNetwork(name: "TP-Link_Office", signal: -48, secured: true, mac: "FF:11:22:33:44:55", channel: 3, encryption: "WPA2", password: "0ff1c3_W1F1!pw"),
        WiFiNetwork(name: "Starlink_Sat", signal: -38, secured: true, mac: "AB:CD:EF:12:34:56", channel: 52, encryption: "WPA3", password: "St@rl1nk_S@t#X"),
        WiFiNetwork(name: "HiddenNet_X", signal: -62, secured: true, mac: "12:34:56:78:9A:BC", channel: 100, encryption: "WPA2-EAP", password: "H1dd3n_X_K3y!0"),
    ]
}

// MARK: - CCTV Camera Model

struct CCTVCamera: Identifiable {
    let id = UUID()
    let name: String
    let ip: String
    let port: Int
    let type: String
    let icon: String
    let distance: Int // meters
    let location: String
    let resolution: String
    let fps: Int
    let isOnline: Bool
    let vulnerability: String
    let streamURL: String
    let manufacturer: String

    static let mockCameras: [CCTVCamera] = [
        CCTVCamera(name: "Parking_Lot_CAM01", ip: "192.168.1.101", port: 554, type: "IP Camera", icon: "video.fill", distance: 45, location: "Parking B1", resolution: "1080p", fps: 30, isOnline: true, vulnerability: "OPEN", streamURL: "rtsp://192.168.1.101:554/stream1", manufacturer: "Hikvision"),
        CCTVCamera(name: "Lobby_Entrance", ip: "192.168.1.102", port: 554, type: "CCTV Dome", icon: "web.camera.fill", distance: 120, location: "Main Lobby", resolution: "4K", fps: 25, isOnline: true, vulnerability: "DEFAULT_CREDS", streamURL: "rtsp://192.168.1.102:554/ch01", manufacturer: "Dahua"),
        CCTVCamera(name: "Street_Corner_PTZ", ip: "10.0.0.50", port: 8080, type: "PTZ Camera", icon: "camera.fill", distance: 230, location: "Street Corner", resolution: "1080p", fps: 30, isOnline: true, vulnerability: "OPEN", streamURL: "http://10.0.0.50:8080/video", manufacturer: "Axis"),
        CCTVCamera(name: "Cafe_Interior", ip: "192.168.2.15", port: 554, type: "IP Camera", icon: "video.fill", distance: 180, location: "Cafe Ground", resolution: "720p", fps: 15, isOnline: true, vulnerability: "WEP_KEY", streamURL: "rtsp://192.168.2.15:554/live", manufacturer: "TP-Link"),
        CCTVCamera(name: "ATM_Security", ip: "10.0.1.200", port: 443, type: "Hidden Cam", icon: "eye.fill", distance: 310, location: "ATM Zone", resolution: "1080p", fps: 30, isOnline: false, vulnerability: "ENCRYPTED", streamURL: "https://10.0.1.200:443/secure", manufacturer: "Bosch"),
        CCTVCamera(name: "Traffic_Cam_N1", ip: "172.16.0.88", port: 554, type: "Traffic Cam", icon: "car.fill", distance: 420, location: "North Road", resolution: "4K", fps: 30, isOnline: true, vulnerability: "DEFAULT_CREDS", streamURL: "rtsp://172.16.0.88:554/traffic", manufacturer: "Pelco"),
        CCTVCamera(name: "Building_Rear_02", ip: "192.168.1.155", port: 554, type: "Building Sec", icon: "building.2.fill", distance: 85, location: "Rear Gate", resolution: "1080p", fps: 25, isOnline: true, vulnerability: "OPEN", streamURL: "rtsp://192.168.1.155:554/cam02", manufacturer: "Hikvision"),
        CCTVCamera(name: "Pharmacy_Store", ip: "192.168.3.42", port: 80, type: "IP Camera", icon: "video.fill", distance: 550, location: "Pharmacy", resolution: "720p", fps: 15, isOnline: true, vulnerability: "WEP_KEY", streamURL: "http://192.168.3.42:80/mjpg", manufacturer: "Foscam"),
        CCTVCamera(name: "School_Playground", ip: "10.10.0.12", port: 554, type: "CCTV Dome", icon: "web.camera.fill", distance: 680, location: "School Area", resolution: "1080p", fps: 25, isOnline: false, vulnerability: "ENCRYPTED", streamURL: "rtsp://10.10.0.12:554/play", manufacturer: "Samsung"),
        CCTVCamera(name: "Gas_Station_01", ip: "192.168.5.99", port: 554, type: "PTZ Camera", icon: "camera.fill", distance: 740, location: "Gas Station", resolution: "4K", fps: 30, isOnline: true, vulnerability: "DEFAULT_CREDS", streamURL: "rtsp://192.168.5.99:554/fuel", manufacturer: "Dahua"),
        CCTVCamera(name: "Park_East_Gate", ip: "172.16.1.33", port: 8554, type: "IP Camera", icon: "video.fill", distance: 350, location: "East Park", resolution: "1080p", fps: 20, isOnline: true, vulnerability: "OPEN", streamURL: "rtsp://172.16.1.33:8554/park", manufacturer: "Reolink"),
        CCTVCamera(name: "Apartment_Hallway", ip: "192.168.0.200", port: 554, type: "Hidden Cam", icon: "eye.fill", distance: 95, location: "Apt Floor 3", resolution: "720p", fps: 15, isOnline: true, vulnerability: "DEFAULT_CREDS", streamURL: "rtsp://192.168.0.200:554/hall", manufacturer: "Xiaomi"),
        CCTVCamera(name: "Mall_Entrance_W", ip: "10.0.2.75", port: 554, type: "CCTV Dome", icon: "web.camera.fill", distance: 890, location: "Mall West", resolution: "4K", fps: 25, isOnline: true, vulnerability: "WEP_KEY", streamURL: "rtsp://10.0.2.75:554/west", manufacturer: "Hikvision"),
        CCTVCamera(name: "Traffic_Cam_S2", ip: "172.16.0.92", port: 554, type: "Traffic Cam", icon: "car.fill", distance: 960, location: "South Blvd", resolution: "1080p", fps: 30, isOnline: false, vulnerability: "ENCRYPTED", streamURL: "rtsp://172.16.0.92:554/south", manufacturer: "Pelco"),
        CCTVCamera(name: "Restaurant_Back", ip: "192.168.4.18", port: 80, type: "IP Camera", icon: "video.fill", distance: 270, location: "Restaurant", resolution: "720p", fps: 15, isOnline: true, vulnerability: "OPEN", streamURL: "http://192.168.4.18:80/cam", manufacturer: "Foscam"),
    ]
}

// MARK: - Hacker Toggle Style

struct HackerToggleStyle: ToggleStyle {
    private let hackerGreen = Color(hex: "#00FF41")
    private let hackerBG = Color(hex: "#0D0208")

    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(configuration.isOn ? hackerGreen.opacity(0.3) : hackerBG)
                    .frame(width: 44, height: 22)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(configuration.isOn ? hackerGreen : hackerGreen.opacity(0.2), lineWidth: 1)
                    )

                RoundedRectangle(cornerRadius: 3)
                    .fill(configuration.isOn ? hackerGreen : hackerGreen.opacity(0.3))
                    .frame(width: 18, height: 16)
                    .offset(x: configuration.isOn ? 10 : -10)
                    .animation(.easeInOut(duration: 0.15), value: configuration.isOn)
            }
            .onTapGesture { configuration.isOn.toggle() }
        }
    }
}

// MARK: - Insight Card (reused from old code for compatibility)

struct InsightCard<Content: View>: View {
    var title: String?
    @ViewBuilder var content: () -> Content

    init(title: String? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            if let title = title {
                Text(title)
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.onSurfaceVariant.opacity(0.5))
            }
            content()
        }
        .padding(Spacing.lg)
        .background(Color.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
    }
}

// MARK: - Neural Toggle Style (kept for backward compatibility)

struct NeuralToggleStyle: ToggleStyle {
    var accentColor: Color = .neuralPrimary

    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            ZStack {
                RoundedRectangle(cornerRadius: CornerRadius.full)
                    .fill(configuration.isOn ? accentColor.opacity(0.3) : Color.surfaceContainerHighest)
                    .frame(width: 44, height: 26)
                Circle()
                    .fill(configuration.isOn ? accentColor : Color.onSurfaceVariant)
                    .frame(width: 20, height: 20)
                    .offset(x: configuration.isOn ? 10 : -10)
                    .animation(.easeInOut(duration: 0.2), value: configuration.isOn)
            }
            .onTapGesture { configuration.isOn.toggle() }
        }
    }
}

#Preview {
    CreatorPanelView()
        .environmentObject(NeuralOrchestrator.shared)
}
