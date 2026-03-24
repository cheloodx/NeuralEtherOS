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
    @State private var cctvCameras: [CCTVCamera] = []
    @State private var isScanningCCTV: Bool = false
    @State private var cctvScanProgress: Double = 0.0
    @State private var selectedCCTV: CCTVCamera? = nil
    @State private var cctvViewMode: Int = 0  // 0 = list, 1 = grid, 2 = map
    @State private var cctvConnectedCount: Int = 0
    @State private var cctvRecordingIds: Set<UUID> = []

    // Matrix rain
    @State private var matrixColumns: [MatrixColumn] = []
    @State private var matrixTimer: Timer? = nil

    // Activity Log
    @State private var activityLog: [ActivityEntry] = ActivityEntry.initial

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
        matrixTimer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: true) { _ in
            if matrixColumns.count > 40 { matrixColumns.removeFirst(5) }
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
        case 1: wifiTab
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
            addOutput("  help          \u{2014} Show this help", hackerDimGreen)
            addOutput("  status        \u{2014} System status", hackerDimGreen)
            addOutput("  scan wifi     \u{2014} Scan WiFi networks", hackerDimGreen)
            addOutput("  scan ports    \u{2014} Port scanner", hackerDimGreen)
            addOutput("  whoami        \u{2014} Current user info", hackerDimGreen)
            addOutput("  ifconfig      \u{2014} Network interfaces", hackerDimGreen)
            addOutput("  nmap          \u{2014} Network mapper", hackerDimGreen)
            addOutput("  ps aux        \u{2014} Running processes", hackerDimGreen)
            addOutput("  netstat       \u{2014} Network connections", hackerDimGreen)
            addOutput("  cat /etc/keys \u{2014} View encryption keys", hackerDimGreen)
            addOutput("  clear         \u{2014} Clear terminal", hackerDimGreen)
            addOutput("  hack          \u{2014} \u{26A0} Penetration test", hackerDimGreen)
            addOutput("  matrix        \u{2014} Matrix mode", hackerDimGreen)
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
        case "cat /etc/keys":
            addOutput("[ENCRYPTION KEYS]", hackerCyan)
            addOutput("  RSA-4096:  \(UUID().uuidString)", hackerGreen)
            addOutput("  AES-512:   \(UUID().uuidString)", hackerGreen)
            addOutput("  ECDSA:     \(UUID().uuidString.prefix(16))...", hackerGreen)
            addOutput("  HMAC:      \(UUID().uuidString.prefix(16))...", hackerDimGreen)
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
        case "clear":
            terminalLines.removeAll()
        default:
            if cmd.isEmpty {
                // do nothing
            } else {
                addOutput("bash: \(cmd): command not found", hackerRed)
                addOutput("Type 'help' for available commands", hackerDimGreen)
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
        logActivity("WIFI_SCAN_STARTED")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            isScanning = false
            wifiNetworks.shuffle()
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
            let delay = Double(i) * 0.6 + Double.random(in: 0.2...0.5)
            totalDelay = delay
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    crackProgress = phase.0
                    crackPhase = phase.1
                }
                // Brute force chars simulation
                let chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%&*"
                bruteForceChars = String((0..<40).map { _ in chars.randomElement()! })
            }
        }

        // Final: reveal password
        DispatchQueue.main.asyncAfter(deadline: .now() + totalDelay + 0.8) {
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

        // Animate progress
        let totalCams = CCTVCamera.mockCameras.count
        let steps = totalCams + 5 // extra steps for startup/finish animation
        let stepDelay = 0.2

        for i in 1...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * stepDelay) {
                withAnimation(.easeInOut(duration: 0.15)) {
                    cctvScanProgress = min(1.0, Double(i) / Double(steps))
                }

                // Add cameras progressively (one per step after initial 2 steps)
                let camIdx = i - 3 // start adding from step 3
                if camIdx >= 0 && camIdx < totalCams {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        cctvCameras.append(CCTVCamera.mockCameras[camIdx])
                        if CCTVCamera.mockCameras[camIdx].isOnline {
                            cctvConnectedCount += 1
                        }
                    }
                    logActivity("CCTV_FOUND: \(CCTVCamera.mockCameras[camIdx].name) [\(CCTVCamera.mockCameras[camIdx].ip)]")
                }
            }
        }

        // Finish
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(steps) * stepDelay + 0.3) {
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
            hackerSection("NETWORK TRAFFIC MONITOR", icon: "network")

            // Throughput
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(String(format: "%.1f", Double.random(in: 2.5...8.5))) GB/s")
                        .font(.system(size: 22, weight: .bold, design: .monospaced))
                        .foregroundColor(hackerGreen)
                    Text("THROUGHPUT")
                        .font(.system(size: 8, weight: .medium, design: .monospaced))
                        .foregroundColor(hackerDimGreen)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(Int.random(in: 45000...120000))")
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
                hackerTraffic("Europe", Double.random(in: 0.6...0.95))
                hackerTraffic("Americas", Double.random(in: 0.5...0.85))
                hackerTraffic("Asia-Pacific", Double.random(in: 0.7...0.98))
                hackerTraffic("Africa", Double.random(in: 0.2...0.5))
                hackerTraffic("Middle East", Double.random(in: 0.3...0.6))
            }

            // Firewall
            hackerSection("FIREWALL STATUS", icon: "lock.shield")
            VStack(spacing: Spacing.sm) {
                firewallRow("DDoS Protection", "ACTIVE", hackerGreen)
                firewallRow("Rate Limiter", "ACTIVE", hackerGreen)
                firewallRow("Geo-Blocking", "CONFIGURED", hackerAmber)
                firewallRow("SSL/TLS", "AES-512", hackerGreen)
                firewallRow("Intrusion Detection", "MONITORING", hackerCyan)
            }
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

    private var deviceManagerTab: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            hackerSection("CONNECTED DEVICES", icon: "desktopcomputer")

            VStack(spacing: Spacing.sm) {
                hackerDevice("Creator iPhone 15 Pro", "iphone", "192.168.1.10", "ONLINE", hackerGreen)
                hackerDevice("MacBook Pro M3", "laptopcomputer", "192.168.1.15", "ONLINE", hackerGreen)
                hackerDevice("iPad Pro 12.9", "ipad", "192.168.1.20", "ONLINE", hackerGreen)
                hackerDevice("Smart TV LG 4K", "tv", "192.168.1.22", "IDLE", hackerAmber)
                hackerDevice("Apple Watch Ultra", "applewatch", "BT-PAIRED", "SYNCED", hackerCyan)
                hackerDevice("HomePod Mini", "hifispeaker", "192.168.1.30", "STANDBY", hackerDimGreen)
                hackerDevice("Unknown Device", "questionmark.circle", "192.168.1.99", "BLOCKED", hackerRed)
            }
        }
    }

    private func hackerDevice(_ name: String, _ icon: String, _ ip: String, _ status: String, _ color: Color) -> some View {
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
        }
        .padding(Spacing.sm)
        .background(hackerGreen.opacity(0.02))
        .overlay(RoundedRectangle(cornerRadius: 4).stroke(hackerGreen.opacity(0.08), lineWidth: 0.5))
        .clipShape(RoundedRectangle(cornerRadius: 4))
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
        Button { logActivity("EXPLOIT_RUN: \(name)") } label: {
            HStack(spacing: Spacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(color)
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
                Text("RUN")
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .foregroundColor(color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(color.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 3))
            }
            .padding(Spacing.sm)
            .background(hackerGreen.opacity(0.02))
            .overlay(RoundedRectangle(cornerRadius: 4).stroke(hackerGreen.opacity(0.08), lineWidth: 0.5))
            .clipShape(RoundedRectangle(cornerRadius: 4))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Tab 6: File System

    private var fileSystemTab: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            hackerSection("FILE SYSTEM EXPLORER", icon: "folder.fill")

            Text("root@neural-ether:/$ ls -la")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(hackerGreen)

            VStack(alignment: .leading, spacing: 4) {
                fsRow("drwxr-xr-x", "root", "4096", "/etc", "folder.fill", hackerCyan)
                fsRow("drwxr-xr-x", "root", "12288", "/var/log", "folder.fill", hackerCyan)
                fsRow("-rw-r--r--", "root", "2048", "/etc/neural.conf", "doc.text", hackerGreen)
                fsRow("-rw-------", "root", "512", "/etc/keys/master.key", "key.fill", hackerAmber)
                fsRow("drwx------", "root", "8192", "/data/users", "folder.fill.badge.person.crop", hackerCyan)
                fsRow("-rw-r--r--", "root", "1.2GB", "/data/ai-model.bin", "brain", hackerGreen)
                fsRow("-rw-r--r--", "root", "256MB", "/data/search-index.db", "cylinder", hackerGreen)
                fsRow("drwxr-xr-x", "root", "4096", "/var/www", "globe", hackerCyan)
                fsRow("-rwx------", "root", "2048", "/usr/bin/neural-core", "terminal", hackerAmber)
                fsRow("lrwxrwxrwx", "root", "24", "/tmp -> /dev/null", "link", hackerDimGreen)
            }
            .padding(Spacing.md)
            .background(hackerBG)
            .overlay(RoundedRectangle(cornerRadius: 4).stroke(hackerGreen.opacity(0.2), lineWidth: 0.5))
            .clipShape(RoundedRectangle(cornerRadius: 4))
        }
    }

    private func fsRow(_ perms: String, _ owner: String, _ size: String, _ path: String, _ icon: String, _ color: Color) -> some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .foregroundColor(color)
                .frame(width: 16)
            Text(perms)
                .font(.system(size: 8, design: .monospaced))
                .foregroundColor(hackerDimGreen)
                .frame(width: 80, alignment: .leading)
            Text(size)
                .font(.system(size: 8, design: .monospaced))
                .foregroundColor(hackerDimGreen)
                .frame(width: 50, alignment: .trailing)
            Text(path)
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .foregroundColor(color)
            Spacer()
        }
    }

    // MARK: - Tab 7: +18 Content

    @State private var adultCategories: [String: Bool] = [
        "Movies & Shows": false,
        "Live Streaming": false,
        "Premium Content": false,
        "VR Experiences": false,
        "Explicit Images": false,
        "Dating & Chat": false,
    ]
    @State private var adultAgeVerified: Bool = false
    @State private var adultFilterLevel: Double = 3.0
    @State private var adultShowPreview: String? = nil

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
                    Text("You must verify you are 18+ to access this section.")
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(hackerDimGreen)
                        .multilineTextAlignment(.center)
                    Button {
                        withAnimation { adultAgeVerified = true }
                        logActivity("+18_AGE_VERIFIED")
                    } label: {
                        Text("I AM 18+ \u{2014} VERIFY & ENTER")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(hackerBG)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Spacing.md)
                            .background(hackerRed)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
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
                        Text("+18 CONTENT FILTER")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(hackerGreen)
                        Text(orchestrator.adultContentEnabled ? "UNLOCKED \u{2014} Age-restricted content visible" : "LOCKED \u{2014} All content filtered")
                            .font(.system(size: 8, design: .monospaced))
                            .foregroundColor(orchestrator.adultContentEnabled ? hackerRed : hackerDimGreen)
                    }
                    Spacer()
                    Toggle("", isOn: Binding(
                        get: { orchestrator.adultContentEnabled },
                        set: { newVal in
                            orchestrator.adultContentEnabled = newVal
                            logActivity(newVal ? "+18_UNLOCKED" : "+18_LOCKED")
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
                    // Filter level
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        HStack {
                            Text("FILTER LEVEL")
                                .font(.system(size: 9, weight: .bold, design: .monospaced))
                                .foregroundColor(hackerAmber)
                            Spacer()
                            Text(filterLevelText)
                                .font(.system(size: 9, weight: .bold, design: .monospaced))
                                .foregroundColor(filterLevelColor)
                        }
                        Slider(value: $adultFilterLevel, in: 1...5, step: 1)
                            .tint(hackerRed)
                        HStack {
                            Text("SOFT")
                                .font(.system(size: 7, design: .monospaced))
                                .foregroundColor(hackerDimGreen)
                            Spacer()
                            Text("EXTREME")
                                .font(.system(size: 7, design: .monospaced))
                                .foregroundColor(hackerRed)
                        }
                    }
                    .padding(Spacing.md)
                    .background(hackerRed.opacity(0.03))
                    .clipShape(RoundedRectangle(cornerRadius: 4))

                    // Categories with toggles
                    VStack(spacing: Spacing.sm) {
                        Text("CONTENT CATEGORIES")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(hackerGreen)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        adultCategoryRow("Movies & Shows", icon: "film.fill", count: 12847, color: hackerAmber)
                        adultCategoryRow("Live Streaming", icon: "video.fill", count: 342, color: hackerRed)
                        adultCategoryRow("Premium Content", icon: "star.fill", count: 8923, color: hackerCyan)
                        adultCategoryRow("VR Experiences", icon: "eye.circle.fill", count: 1456, color: hackerGreen)
                        adultCategoryRow("Explicit Images", icon: "photo.fill", count: 45230, color: hackerAmber)
                        adultCategoryRow("Dating & Chat", icon: "bubble.left.and.bubble.right.fill", count: 5678, color: hackerRed)
                    }

                    // Preview section
                    if let preview = adultShowPreview {
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            HStack {
                                Text("PREVIEW: \(preview)")
                                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                                    .foregroundColor(hackerAmber)
                                Spacer()
                                Button {
                                    adultShowPreview = nil
                                } label: {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 10))
                                        .foregroundColor(hackerRed)
                                }
                                .buttonStyle(.plain)
                            }

                            // Simulated content grid
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 6) {
                                ForEach(0..<6, id: \.self) { i in
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(hackerRed.opacity(Double.random(in: 0.05...0.15)))
                                            .aspectRatio(3/4, contentMode: .fit)
                                        VStack(spacing: 2) {
                                            Image(systemName: "play.circle.fill")
                                                .font(.system(size: 16))
                                                .foregroundColor(hackerRed.opacity(0.5))
                                            Text("ITEM_\(i + 1)")
                                                .font(.system(size: 6, weight: .bold, design: .monospaced))
                                                .foregroundColor(hackerRed.opacity(0.4))
                                        }
                                    }
                                    .overlay(RoundedRectangle(cornerRadius: 4).stroke(hackerRed.opacity(0.2), lineWidth: 0.5))
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                                }
                            }
                        }
                        .padding(Spacing.md)
                        .background(hackerRed.opacity(0.03))
                        .overlay(RoundedRectangle(cornerRadius: 4).stroke(hackerRed.opacity(0.2), lineWidth: 0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                    }

                    // Stats
                    VStack(spacing: Spacing.sm) {
                        Text("CONTENT STATISTICS")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(hackerGreen)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        adultStatRow("Total Items", "74,476")
                        adultStatRow("Active Streams", "342")
                        adultStatRow("Blocked Today", "12,847")
                        adultStatRow("Storage Used", "2.4 TB")
                        adultStatRow("Users Online", "8,923")
                        adultStatRow("Reports Pending", "47")
                    }
                    .padding(Spacing.md)
                    .background(hackerGreen.opacity(0.03))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                } else {
                    // Locked state
                    VStack(spacing: Spacing.md) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 24))
                            .foregroundColor(hackerDimGreen)
                        Text("CONTENT FILTER ACTIVE")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(hackerDimGreen)
                        Text("Toggle the switch above to manage adult content")
                            .font(.system(size: 8, design: .monospaced))
                            .foregroundColor(hackerDimGreen)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(Spacing.xl)
                }
            }
        }
    }

    private var filterLevelText: String {
        switch Int(adultFilterLevel) {
        case 1: return "SOFT"
        case 2: return "MILD"
        case 3: return "MODERATE"
        case 4: return "HARD"
        case 5: return "EXTREME"
        default: return "MODERATE"
        }
    }

    private var filterLevelColor: Color {
        switch Int(adultFilterLevel) {
        case 1: return hackerGreen
        case 2: return hackerAmber
        case 3: return hackerAmber
        case 4: return hackerRed
        case 5: return hackerRed
        default: return hackerAmber
        }
    }

    private func adultCategoryRow(_ name: String, icon: String, count: Int, color: Color) -> some View {
        HStack {
            Toggle(isOn: Binding(
                get: { adultCategories[name] ?? false },
                set: { newVal in
                    adultCategories[name] = newVal
                    logActivity("+18_CAT_\(newVal ? "ON" : "OFF"): \(name)")
                }
            )) {
                HStack(spacing: Spacing.sm) {
                    Image(systemName: icon)
                        .font(.system(size: 10))
                        .foregroundColor(adultCategories[name] == true ? color : hackerDimGreen)
                        .frame(width: 16)
                    Text(name)
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundColor(adultCategories[name] == true ? hackerGreen : hackerDimGreen)
                }
            }
            .toggleStyle(HackerToggleStyle())

            Text("\(count)")
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(color)
                .frame(width: 50, alignment: .trailing)

            Button {
                if adultShowPreview == name {
                    adultShowPreview = nil
                } else {
                    adultShowPreview = name
                    logActivity("+18_PREVIEW: \(name)")
                }
            } label: {
                Text(adultShowPreview == name ? "HIDE" : "VIEW")
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .foregroundColor(color)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(color.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 3))
            }
            .buttonStyle(.plain)
        }
        .padding(Spacing.sm)
        .background(adultCategories[name] == true ? color.opacity(0.04) : hackerGreen.opacity(0.02))
        .clipShape(RoundedRectangle(cornerRadius: 3))
    }

    private func adultStatRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 9, design: .monospaced))
                .foregroundColor(hackerDimGreen)
            Spacer()
            Text(value)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(hackerGreen)
        }
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
                overrideToggle("BYPASS RATE LIMITER", $orchestrator.wifiAccessEnabled, hackerAmber)
                overrideToggle("FORCE ADMIN MODE", .constant(true), hackerGreen)
                overrideToggle("DISABLE FIREWALL", .constant(false), hackerRed)
                overrideToggle("RAW API ACCESS", $orchestrator.webcamAccessEnabled, hackerCyan)
                overrideToggle("DEBUG MODE", .constant(true), hackerAmber)
                overrideToggle("STEALTH MODE", .constant(false), hackerDimGreen)
            }

            // Performance
            hackerSection("SYSTEM PERFORMANCE", icon: "gauge.with.dots.needle.67percent")
            VStack(spacing: Spacing.sm) {
                perfBar("CPU USAGE", 0.87, hackerGreen)
                perfBar("MEMORY", 0.72, hackerCyan)
                perfBar("DISK I/O", 0.45, hackerAmber)
                perfBar("GPU", 0.93, hackerGreen)
                perfBar("NETWORK", 0.68, hackerCyan)
            }
        }
    }

    private func overrideToggle(_ label: String, _ isOn: Binding<Bool>, _ color: Color) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundColor(hackerGreen)
            Spacer()
            Toggle("", isOn: isOn)
                .toggleStyle(HackerToggleStyle())
                .labelsHidden()
        }
        .padding(Spacing.sm)
        .background(color.opacity(0.03))
        .overlay(RoundedRectangle(cornerRadius: 4).stroke(color.opacity(0.08), lineWidth: 0.5))
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
    let signal: Int
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
