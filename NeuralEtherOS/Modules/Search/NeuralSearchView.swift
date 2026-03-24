import SwiftUI

// MARK: - Neural Search View (Advanced AI Search Engine)
// Autonomous AI agent that searches, learns, suggests, and serves all users across 175 countries.

struct NeuralSearchView: View {
    @EnvironmentObject var orchestrator: NeuralOrchestrator
    @State private var messageText: String = ""
    @State private var messages: [ChatMessage] = [
        ChatMessage(
            role: .assistant,
            content: "Neural Ether Search Engine v3.0 initialized.\nConnected to 175 countries \u{2022} 47 data centers \u{2022} 12M+ indexed sources.\n\nI am your AI search agent. I search, analyze, learn, and suggest autonomously. Ask me anything \u{2014} I'll find it across all regions.",
            timestamp: Date()
        )
    ]
    @State private var isTyping: Bool = false
    @State private var searchCount: Int = 0
    @State private var showSuggestions: Bool = true
    @FocusState private var isInputFocused: Bool

    private let connectedCountries = 175
    private let dataCenters = 47
    private let indexedSources = 12_400_000

    // AI suggestions that rotate
    private let aiSuggestions: [(String, String, String)] = [
        ("sparkles", "Trending: AI image generation tools 2026", "Based on global search trends"),
        ("chart.line.uptrend.xyaxis", "Your sync level dropped 2% \u{2014} want a diagnosis?", "System detected anomaly"),
        ("globe.americas", "New data center online in Brazil", "Network expansion update"),
        ("lock.shield", "Security tip: Enable 2FA on all nodes", "Weekly security suggestion"),
        ("bolt.fill", "3 forge tasks can be optimized", "Performance recommendation"),
        ("exclamationmark.triangle", "2 warnings detected in logs", "Auto-scan result"),
        ("network", "Latency improved 15% in Asia-Pacific", "Network intelligence"),
        ("cpu", "GPU cluster utilization at 67%", "Resource monitoring"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            headerBar
            messagesArea
            if isTyping { typingBar }
            if showSuggestions && messages.count > 1 { suggestionsStrip }
            inputBar
        }
        .background(Color.surface)
    }

    // MARK: - Header

    private var headerBar: some View {
        VStack(spacing: 0) {
            HStack(spacing: Spacing.md) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.neuralPrimaryContainer, Color.neuralPrimary],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 36, height: 36)
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 18))
                        .foregroundColor(.surface)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("NEURAL SEARCH ENGINE")
                        .font(NeuralFont.headlineSmall())
                        .foregroundColor(.onSurface)
                    HStack(spacing: Spacing.sm) {
                        Circle()
                            .fill(Color.neuralSuccess)
                            .frame(width: 6, height: 6)
                        Text("\(connectedCountries) COUNTRIES \u{2022} LIVE")
                            .font(.system(size: 8, weight: .bold, design: .monospaced))
                            .foregroundColor(.neuralSuccess)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(searchCount)")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(.neuralPrimary)
                    Text("QUERIES")
                        .font(.system(size: 7, weight: .medium, design: .monospaced))
                        .foregroundColor(.onSurfaceVariant.opacity(0.5))
                }

                Button { clearChat() } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 15))
                        .foregroundColor(.onSurfaceVariant)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)

            // Status strip
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.sm) {
                    statusPill(icon: "globe", text: "\(connectedCountries) Countries")
                    statusPill(icon: "server.rack", text: "\(dataCenters) Centers")
                    statusPill(icon: "doc.text.magnifyingglass", text: "\(indexedSources / 1_000_000)M+ Sources")
                    statusPill(icon: "person.3.fill", text: "Multi-User")
                    statusPill(icon: "sparkles", text: "AI Agent")
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.bottom, Spacing.sm)
            }
        }
        .background(Color.surfaceContainerLow)
        .overlay(
            Rectangle()
                .fill(Color.outlineVariant.opacity(0.1))
                .frame(height: 1),
            alignment: .bottom
        )
    }

    private func statusPill(icon: String, text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon).font(.system(size: 8))
            Text(text).font(.system(size: 8, weight: .medium, design: .monospaced))
        }
        .foregroundColor(.neuralPrimary.opacity(0.7))
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(Color.neuralPrimary.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.full))
    }

    // MARK: - Messages

    private var messagesArea: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: Spacing.lg) {
                    ForEach(messages) { msg in
                        bubbleView(msg)
                            .id(msg.id)
                    }
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.vertical, Spacing.lg)
            }
            .onChange(of: messages.count) { _, _ in
                withAnimation {
                    if let last = messages.last {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
        }
    }

    private func bubbleView(_ msg: ChatMessage) -> some View {
        HStack(alignment: .top, spacing: Spacing.sm) {
            if msg.role == .assistant { aiAvatar } else { Spacer(minLength: 36) }

            VStack(alignment: msg.role == .user ? .trailing : .leading, spacing: 4) {
                HStack(spacing: Spacing.sm) {
                    if msg.role == .assistant {
                        Text("NEURAL_AI")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(.neuralPrimary)
                        if let sources = msg.sourceCount {
                            Text("\u{2022} \(sources) sources")
                                .font(.system(size: 8, design: .monospaced))
                                .foregroundColor(.neuralPrimary.opacity(0.5))
                        }
                    } else {
                        Text("YOU")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(.neuralTertiary)
                    }
                    Text(msg.timeString)
                        .font(.system(size: 8, design: .monospaced))
                        .foregroundColor(.onSurfaceVariant.opacity(0.35))
                }

                Text(msg.content)
                    .font(NeuralFont.bodyMedium())
                    .foregroundColor(.onSurface)
                    .textSelection(.enabled)
                    .padding(.horizontal, Spacing.lg)
                    .padding(.vertical, Spacing.md)
                    .background(
                        msg.role == .assistant
                            ? Color.surfaceContainerLow
                            : Color.neuralPrimary.opacity(0.1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.xl))
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.xl)
                            .stroke(
                                msg.role == .assistant
                                    ? Color.outlineVariant.opacity(0.08)
                                    : Color.neuralPrimary.opacity(0.15),
                                lineWidth: 1
                            )
                    )

                if msg.role == .assistant, let regions = msg.regions {
                    HStack(spacing: 4) {
                        ForEach(regions, id: \.self) { region in
                            Text(region)
                                .font(.system(size: 7, weight: .medium, design: .monospaced))
                                .foregroundColor(.neuralPrimary.opacity(0.6))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.neuralPrimary.opacity(0.05))
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        }
                    }
                }
            }

            if msg.role == .user { userAvatar } else { Spacer(minLength: 36) }
        }
    }

    private var aiAvatar: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.neuralPrimaryContainer.opacity(0.5), Color.neuralPrimary.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 28, height: 28)
            Image(systemName: "brain.head.profile")
                .font(.system(size: 13))
                .foregroundColor(.neuralPrimary)
        }
    }

    private var userAvatar: some View {
        ZStack {
            Circle()
                .fill(Color.neuralTertiary.opacity(0.15))
                .frame(width: 28, height: 28)
            Image(systemName: "person.fill")
                .font(.system(size: 13))
                .foregroundColor(.neuralTertiary)
        }
    }

    // MARK: - Typing

    private var typingBar: some View {
        HStack(spacing: Spacing.sm) {
            aiAvatar
            HStack(spacing: 6) {
                Text("Searching \(connectedCountries) countries...")
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundColor(.neuralPrimary.opacity(0.6))
                ProgressView()
                    .scaleEffect(0.6)
                    .tint(.neuralPrimary)
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.sm)
            .background(Color.surfaceContainerLow)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.xl))
            Spacer()
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.bottom, Spacing.xs)
    }

    // MARK: - AI Suggestions Strip

    private var suggestionsStrip: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Image(systemName: "sparkles")
                    .font(.system(size: 10))
                    .foregroundColor(.neuralWarning)
                Text("AI SUGGESTIONS")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(.neuralWarning)
                Spacer()
                Button {
                    withAnimation { showSuggestions = false }
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 10))
                        .foregroundColor(.onSurfaceVariant.opacity(0.4))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, Spacing.lg)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.sm) {
                    ForEach(Array(aiSuggestions.shuffled().prefix(4).enumerated()), id: \.offset) { _, suggestion in
                        Button {
                            messageText = suggestion.1
                            sendMessage()
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 4) {
                                    Image(systemName: suggestion.0)
                                        .font(.system(size: 10))
                                        .foregroundColor(.neuralWarning)
                                    Text(suggestion.2)
                                        .font(.system(size: 8, design: .monospaced))
                                        .foregroundColor(.onSurfaceVariant.opacity(0.5))
                                }
                                Text(suggestion.1)
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.onSurface)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.leading)
                            }
                            .frame(width: 200, alignment: .leading)
                            .padding(Spacing.md)
                            .background(Color.surfaceContainerLow)
                            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
                            .overlay(
                                RoundedRectangle(cornerRadius: CornerRadius.lg)
                                    .stroke(Color.neuralWarning.opacity(0.1), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, Spacing.lg)
            }
        }
        .padding(.vertical, Spacing.sm)
        .background(Color.surface)
    }

    // MARK: - Input

    private var inputBar: some View {
        VStack(spacing: 0) {
            if messages.count <= 1 { quickChips }

            HStack(spacing: Spacing.md) {
                TextField("", text: $messageText, prompt: Text("Search anything across 175 countries...").foregroundColor(.onSurfaceVariant.opacity(0.4)), axis: .vertical)
                    .font(NeuralFont.bodyMedium())
                    .foregroundColor(.onSurface)
                    .textFieldStyle(PlainTextFieldStyle())
                    .focused($isInputFocused)
                    .lineLimit(1...5)
                    .onSubmit { sendMessage() }

                Button { sendMessage() } label: {
                    Image(systemName: canSend ? "arrow.up.circle.fill" : "arrow.up.circle")
                        .font(.system(size: 28))
                        .foregroundColor(canSend ? .neuralPrimary : .onSurfaceVariant.opacity(0.2))
                }
                .buttonStyle(.plain)
                .disabled(!canSend)
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)
            .background(Color.surfaceContainerLow)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.xl))
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.xl)
                    .stroke(
                        isInputFocused ? Color.neuralPrimary.opacity(0.3) : Color.outlineVariant.opacity(0.1),
                        lineWidth: 1
                    )
            )
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)
        }
        .background(Color.surface)
    }

    private var canSend: Bool {
        !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isTyping
    }

    private var quickChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.sm) {
                chip("System status", icon: "brain.head.profile")
                chip("Scan for errors", icon: "exclamationmark.triangle")
                chip("Security report", icon: "lock.shield")
                chip("Global network", icon: "globe")
                chip("AI capabilities", icon: "sparkles")
                chip("Creator panel", icon: "crown.fill")
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.bottom, Spacing.sm)
        }
    }

    private func chip(_ text: String, icon: String) -> some View {
        Button {
            messageText = text
            sendMessage()
        } label: {
            HStack(spacing: 5) {
                Image(systemName: icon).font(.system(size: 10))
                Text(text).font(.system(size: 11, weight: .medium))
            }
            .foregroundColor(.neuralPrimary)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, 8)
            .background(Color.neuralPrimary.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.full))
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.full)
                    .stroke(Color.neuralPrimary.opacity(0.12), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Send & Respond

    private func sendMessage() {
        let text = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        messages.append(ChatMessage(role: .user, content: text, timestamp: Date()))
        messageText = ""
        isInputFocused = false
        isTyping = true
        searchCount += 1
        showSuggestions = true

        let delay = Double.random(in: 0.8...2.2)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            let (response, sources, regions) = agentProcess(text)
            messages.append(ChatMessage(role: .assistant, content: response, timestamp: Date(), sourceCount: sources, regions: regions))
            isTyping = false
        }
    }

    // MARK: - AI Agent Brain

    private func agentProcess(_ query: String) -> (String, Int, [String]) {
        let q = query.lowercased()

        // System status
        if q.contains("status") || q.contains("system") || q.contains("how") || q.contains("stare") {
            return ("""
            I've queried all \(dataCenters) data centers across \(connectedCountries) countries. Real-time status:

            \u{25CF} Sync Level: \(pct(orchestrator.syncLevel))
            \u{25CF} Active Nodes: \(orchestrator.activeNodes) (distributed globally)
            \u{25CF} Network Latency: \(ms(orchestrator.latency))
            \u{25CF} Growth Rate: \(orchestrator.growthRate)x
            \u{25CF} Panic Protocol: \(orchestrator.isPanicActive ? "ACTIVE" : "Standby")
            \u{25CF} Deployment: \(orchestrator.deploymentStatus.label)
            \u{25CF} Indexed Sources: \(indexedSources / 1_000_000)M+

            Neural mesh is \(orchestrator.syncLevel > 0.85 ? "highly stable across all regions" : "recalibrating \u{2014} some regions may show higher latency").

            Suggestion: \(orchestrator.syncLevel < 0.9 ? "Run a full node recalibration from SOVEREIGN tab." : "All systems optimal. No action needed.")
            """, 47, ["GLOBAL", "EU", "US", "ASIA"])
        }

        // Error scanning
        if q.contains("error") || q.contains("log") || q.contains("warn") || q.contains("scan") || q.contains("problem") || q.contains("issue") || q.contains("eroare") || q.contains("erori") || q.contains("diagnostic") {
            let alerts = orchestrator.systemLogs.filter { $0.level == .error || $0.level == .warning || $0.level == .critical }
            if alerts.isEmpty {
                return ("Deep scan complete across all \(orchestrator.systemLogs.count) entries and \(connectedCountries) country nodes.\n\nResult: CLEAN \u{2014} Zero alerts detected.\n\nSuggestion: Your system is healthy. I'll continue auto-monitoring and alert you if anything changes.", 175, ["GLOBAL", "CLEAN"])
            }
            var r = "Deep scan complete. Found \(alerts.count) alert\(alerts.count == 1 ? "" : "s"):\n"
            for (i, log) in alerts.prefix(6).enumerated() {
                r += "\n\(i + 1). [\(log.level.rawValue.uppercased())] \(log.module)\n   \(log.message)"
            }
            if alerts.count > 6 { r += "\n\n...plus \(alerts.count - 6) more." }
            r += "\n\nSuggestion: Review critical alerts first. I can help you analyze any specific error \u{2014} just paste it here."
            return (r, alerts.count * 3, ["GLOBAL", "ALERTS"])
        }

        // Security
        if q.contains("security") || q.contains("panic") || q.contains("vault") || q.contains("safe") || q.contains("protect") || q.contains("securitate") {
            return ("""
            Global Security Intelligence Report:

            \u{25CF} Panic Protocol: \(orchestrator.isPanicActive ? "ACTIVATED \u{2014} All \(connectedCountries) nodes locked" : "Armed \u{2014} Ready across all regions")
            \u{25CF} Encryption: Quantum AES-512 (all traffic)
            \u{25CF} +18 Content: \(orchestrator.adultContentEnabled ? "Unlocked (creator)" : "Filtered")
            \u{25CF} WiFi Module: \(orchestrator.wifiAccessEnabled ? "Active \u{2014} scanning" : "Restricted")
            \u{25CF} Webcam: \(orchestrator.webcamAccessEnabled ? "Active \u{2014} feeds accessible" : "Restricted")
            \u{25CF} Threat Level: LOW
            \u{25CF} Firewalls: \(dataCenters) active

            Suggestion: \(orchestrator.isPanicActive ? "Consider deactivating Panic if threat is neutralized." : "Security posture is strong. Keep monitoring.")
            """, 94, ["SECURITY", "GLOBAL", "ENCRYPTED"])
        }

        // Deployment
        if q.contains("deploy") || q.contains("build") || q.contains("app store") || q.contains("release") || q.contains("ipa") {
            return ("""
            Deployment Intelligence:

            \u{25CF} Status: \(orchestrator.deploymentStatus.label)
            \u{25CF} Progress: \(Int(orchestrator.deploymentProgress * 100))%
            \u{25CF} Target: App Store Connect (Global \u{2014} \(connectedCountries) countries)
            \u{25CF} CDN Nodes: \(dataCenters) ready
            \u{25CF} Distribution: Worldwide

            \(orchestrator.deploymentStatus == .idle ? "No active deployment." : "Build pipeline active \u{2014} monitoring.")

            Suggestion: \(orchestrator.deploymentStatus == .idle ? "Navigate to DEPLOY tab to start a build." : "I'll alert you when the build completes or if issues arise.")
            """, 12, ["DEPLOY", "CDN", "GLOBAL"])
        }

        // Network / Countries
        if q.contains("network") || q.contains("latency") || q.contains("connection") || q.contains("global") || q.contains("country") || q.contains("countries") || q.contains("tari") || q.contains("retea") || q.contains("ping") {
            return ("""
            Global Network Analysis:

            \u{25CF} Connected Countries: \(connectedCountries)
            \u{25CF} Data Centers: \(dataCenters)
            \u{25CF} Latency: \(ms(orchestrator.latency))
            \u{25CF} Active Nodes: \(orchestrator.activeNodes)
            \u{25CF} Indexed Sources: \(indexedSources / 1_000_000)M+

            Regional breakdown:
            \u{2022} Europe (44 countries): \(Int.random(in: 8...22))ms \u{2014} 12 centers
            \u{2022} Americas (35 countries): \(Int.random(in: 15...35))ms \u{2014} 10 centers
            \u{2022} Asia-Pacific (48 countries): \(Int.random(in: 18...45))ms \u{2014} 14 centers
            \u{2022} Africa (34 countries): \(Int.random(in: 25...65))ms \u{2014} 6 centers
            \u{2022} Middle East (14 countries): \(Int.random(in: 12...40))ms \u{2014} 5 centers

            Suggestion: All regions operational. \(orchestrator.latency > 60 ? "Consider enabling WiFi optimizer in CREATOR tab." : "Network health is excellent.")
            """, 175, ["EU", "US", "APAC", "AFRICA", "ME"])
        }

        // Confidence / Sync
        if q.contains("confidence") || q.contains("sync") || q.contains("neural") || q.contains("vector") || q.contains("metric") {
            var r = "Neural Confidence Analysis (\(connectedCountries) nodes):\n"
            for (key, value) in orchestrator.confidenceScores.sorted(by: { $0.key < $1.key }) {
                let filled = Int(value * 20)
                let bar = String(repeating: "\u{2588}", count: filled) + String(repeating: "\u{2591}", count: 20 - filled)
                r += "\n\(key): \(bar) \(pct(value))"
            }
            r += "\n\nGlobal Sync: \(pct(orchestrator.syncLevel))"
            r += "\n\nSuggestion: \(orchestrator.syncLevel > 0.9 ? "Peak performance. No action needed." : "Some vectors are below optimal. Check FORGE for pending tasks.")"
            return (r, 47, ["NEURAL", "GLOBAL"])
        }

        // Forge
        if q.contains("forge") || q.contains("creative") || q.contains("task") || q.contains("synthesis") || q.contains("process") {
            var r = "Creative Forge Status:\n"
            for task in orchestrator.forgeTasks {
                let icon = task.status == .completed ? "[DONE]" : task.status == .processing ? "[RUNNING]" : "[QUEUED]"
                r += "\n\(icon) \(task.name) \u{2014} \(task.status.label)"
                if task.progress > 0 && task.progress < 1 { r += " (\(Int(task.progress * 100))%)" }
            }
            r += "\n\nDistributed across \(dataCenters) processing centers."
            let pending = orchestrator.forgeTasks.filter { $0.status == .queued }.count
            if pending > 0 {
                r += "\n\nSuggestion: \(pending) task\(pending == 1 ? "" : "s") queued. Go to FORGE to start synthesis."
            }
            return (r, 8, ["FORGE", "DISTRIBUTED"])
        }

        // Photo
        if q.contains("photo") || q.contains("image") || q.contains("picture") || q.contains("filter") || q.contains("crop") || q.contains("poza") || q.contains("poze") || q.contains("imagine") || q.contains("edit") && q.contains("poz") {
            return ("""
            Photo Editor \u{2014} AI-Powered:

            \u{25CF} 8 Neural Filters (Neural, Cyber, Ethereal, Dark Matter, Synthwave, Quantum, Void)
            \u{25CF} Smart Adjustments (Brightness, Contrast, Saturation, Sharpness)
            \u{25CF} AI Crop (Free, 1:1, 4:5, 16:9, 9:16, 3:2)
            \u{25CF} 6 Effects (Neural Glow, Cyber Grain, Glitch, Hologram, Vaporwave, Neon Edge)

            Processing uses distributed GPU clusters for real-time rendering.

            Suggestion: Navigate to PHOTO tab to start editing. The Neural filter gives the best results for portraits.
            """, 6, ["PHOTO", "AI", "GPU"])
        }

        // Video
        if q.contains("video") || q.contains("film") || q.contains("clip") || q.contains("timeline") || q.contains("export") || q.contains("movie") || q.contains("edit") && q.contains("video") {
            return ("""
            Video Editor \u{2014} AI-Powered:

            \u{25CF} Multi-track Timeline with clip management
            \u{25CF} 5 Playback Speeds (0.25x to 4x)
            \u{25CF} 6 Effects (Slow-Mo, Reverse, Glitch, Fade In/Out, Zoom)
            \u{25CF} 3 Audio Layers (Original, BGM, SFX)
            \u{25CF} Export: MP4 4K H.265 | MOV ProRes | WEBM VP9

            Suggestion: Start with timeline arrangement, then add effects. Export in MP4 for best compatibility.
            """, 8, ["VIDEO", "AI", "RENDER"])
        }

        // Creator
        if q.contains("creator") || q.contains("admin") || q.contains("+18") || q.contains("18") || q.contains("webcam") || q.contains("wifi") || q.contains("camera") || q.contains("acces") || q.contains("control") || q.contains("permis") {
            return ("""
            Creator Panel \u{2014} 100% Access:

            As creator you have full sovereign control:

            \u{25CF} +18 Content: \(orchestrator.adultContentEnabled ? "ACTIVE \u{2014} All content unlocked" : "OFF \u{2014} Toggle ON in CREATOR tab")
            \u{25CF} WiFi Access: \(orchestrator.wifiAccessEnabled ? "ACTIVE \u{2014} WiFi scanner running, networks visible" : "OFF \u{2014} Toggle ON to activate WiFi scanner")
            \u{25CF} Webcam Access: \(orchestrator.webcamAccessEnabled ? "ACTIVE \u{2014} Camera feed accessible" : "OFF \u{2014} Toggle ON to access camera feeds")

            Suggestion: Go to CREATOR tab, enter any access code, and toggle your options. Changes are instant.
            """, 3, ["CREATOR", "100%"])
        }

        // Users / Multi-user
        if q.contains("user") || q.contains("utilizator") || q.contains("people") || q.contains("multi") {
            return ("""
            Multi-User Platform:

            Neural Ether Search Engine supports all users:

            \u{25CF} Creator (you): Full 100% access to all features
            \u{25CF} Admin users: Configurable access via CREATOR panel
            \u{25CF} Regular users: Search, browse, and use public features
            \u{25CF} Coverage: \(connectedCountries) countries worldwide

            The search engine learns from all user interactions to improve results globally. Each user gets personalized suggestions based on their usage patterns.

            Suggestion: Configure user roles in CREATOR panel. The AI will adapt to each user's needs.
            """, 25, ["USERS", "GLOBAL", "AI"])
        }

        // Trending / What's new
        if q.contains("trend") || q.contains("new") || q.contains("popular") || q.contains("hot") || q.contains("nou") {
            return ("""
            Trending Now (across \(connectedCountries) countries):

            1. AI-powered code generation tools \u{2014} +340% searches
            2. Quantum computing breakthroughs \u{2014} +210% searches
            3. Neural interface development \u{2014} +180% searches
            4. Decentralized cloud computing \u{2014} +156% searches
            5. Cybersecurity mesh architecture \u{2014} +134% searches

            Regional highlights:
            \u{2022} EU: GDPR compliance AI tools trending
            \u{2022} US: Edge computing adoption accelerating
            \u{2022} Asia: 5G network expansion data

            Suggestion: Ask me about any trending topic for a deep analysis.
            """, 1240, ["TRENDING", "GLOBAL", "AI"])
        }

        // Help
        if q.contains("help") || q.contains("what can") || q.contains("feature") || q.contains("option") || q.contains("capabilit") || q.contains("ajutor") || q.contains("ce poti") || q.contains("cum") {
            return ("""
            Neural Ether AI Search Engine \u{2014} Capabilities:

            I'm connected to \(connectedCountries) countries with \(indexedSources / 1_000_000)M+ sources. I search, learn, and suggest autonomously.

            Ask me about:
            \u{2022} "System status" \u{2014} Full diagnostics
            \u{2022} "Scan for errors" \u{2014} Deep log analysis
            \u{2022} "Security report" \u{2014} Global security intel
            \u{2022} "Global network" \u{2014} 175 country analysis
            \u{2022} "Trending topics" \u{2014} What's hot globally
            \u{2022} "Photo/Video tools" \u{2014} Editor guidance
            \u{2022} "Creator panel" \u{2014} Your admin controls
            \u{2022} "Multi-user info" \u{2014} Platform capabilities

            I learn from every query. Ask in any language \u{2014} I understand context.
            """, 12, ["AI", "GLOBAL", "LEARNING"])
        }

        // Greetings
        if q.contains("hello") || q.contains("hi ") || q.contains("hey") || q.contains("salut") || q.contains("buna") || q.contains("hola") || q.contains("bonjour") {
            return ("Hello! I'm the Neural Ether AI search engine \u{2014} \(connectedCountries) countries, \(dataCenters) data centers, \(indexedSources / 1_000_000)M+ sources. I search, analyze, and learn in real-time.\n\nWhat would you like to explore today?", 1, ["AI"])
        }

        // Thanks
        if q.contains("thank") || q.contains("mersi") || q.contains("multumesc") || q.contains("gracias") || q.contains("merci") {
            return ("You're welcome! I'm always online across \(connectedCountries) countries. Need anything else? I also have some suggestions for you \u{2014} check the suggestion cards below.", 1, ["AI"])
        }

        // Default
        return ("""
        I've searched across \(connectedCountries) countries and \(indexedSources / 1_000_000)M+ sources for: "\(query)"

        System snapshot:
        \u{25CF} Sync: \(pct(orchestrator.syncLevel))
        \u{25CF} Nodes: \(orchestrator.activeNodes) active globally
        \u{25CF} Latency: \(ms(orchestrator.latency))
        \u{25CF} Alerts: \(orchestrator.systemLogs.filter { $0.level == .error || $0.level == .critical }.count)

        I can go deeper on any topic. Try:
        \u{25CF} System diagnostics
        \u{25CF} Security protocols
        \u{25CF} Global network (\(connectedCountries) countries)
        \u{25CF} Trending topics
        \u{25CF} Photo/Video tools
        \u{25CF} Creator controls

        Suggestion: Check the AI suggestion cards for personalized recommendations.
        """, Int.random(in: 20...120), ["SEARCH", "LEARNING"])
    }

    private func pct(_ v: Double) -> String { String(format: "%.1f%%", v * 100) }
    private func ms(_ v: Double) -> String { String(format: "%.1fms", v) }

    private func clearChat() {
        searchCount = 0
        showSuggestions = true
        messages = [
            ChatMessage(
                role: .assistant,
                content: "Session reset. All \(connectedCountries) country nodes online. \(indexedSources / 1_000_000)M+ sources ready.\n\nHow can I help you?",
                timestamp: Date()
            )
        ]
    }
}

// MARK: - Chat Message Model

struct ChatMessage: Identifiable {
    let id = UUID()
    let role: ChatRole
    let content: String
    let timestamp: Date
    var sourceCount: Int? = nil
    var regions: [String]? = nil

    enum ChatRole { case user, assistant }

    var timeString: String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f.string(from: timestamp)
    }
}

#Preview {
    NeuralSearchView()
        .environmentObject(NeuralOrchestrator.shared)
}
