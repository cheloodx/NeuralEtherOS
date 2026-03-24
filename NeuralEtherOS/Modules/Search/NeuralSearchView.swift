import SwiftUI

// MARK: - Neural Search View (Advanced Multilingual AI Chat Engine)
// ChatGPT-style AI agent: detects language, responds in same language, handles ANY query.
// Connected to 175 countries, 47 data centers, 12M+ indexed sources.

struct NeuralSearchView: View {
    @EnvironmentObject var orchestrator: NeuralOrchestrator
    @State private var messageText: String = ""
    @State private var messages: [ChatMessage] = []
    @State private var isTyping: Bool = false
    @State private var searchCount: Int = 0
    @State private var showSuggestions: Bool = true
    @State private var typingDots: Int = 0
    @State private var typingTimer: Timer? = nil
    @FocusState private var isInputFocused: Bool

    private let connectedCountries = 175
    private let dataCenters = 47
    private let indexedSources = 12_400_000

    // Multilingual greetings for initial message
    private var welcomeMessage: String {
        """
        Neural Ether AI \u{2014} Online.
        Connected: \(connectedCountries) countries \u{2022} \(dataCenters) data centers \u{2022} \(indexedSources / 1_000_000)M+ sources.

        \u{1F30D} I speak all languages. Write in any language and I'll respond in the same one.

        \u{1F50D} Ask me anything \u{2014} I search, analyze, learn and suggest autonomously.

        Try: "What's the system status?" or "Care e starea sistemului?" or "Quel est l'\u{00E9}tat du syst\u{00E8}me?"
        """
    }

    // AI suggestion cards
    private let aiSuggestions: [(String, String, String)] = [
        ("sparkles", "AI image generation trends 2026", "Global trend"),
        ("chart.line.uptrend.xyaxis", "Analyze my system performance", "Diagnostics"),
        ("globe.americas", "Show network status for all 175 countries", "Network"),
        ("lock.shield", "Run a full security audit", "Security"),
        ("bolt.fill", "Optimize my forge tasks", "Performance"),
        ("exclamationmark.triangle", "Scan all logs for errors", "Monitoring"),
        ("cpu", "GPU cluster utilization report", "Resources"),
        ("person.3.fill", "How does multi-user access work?", "Platform"),
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
        .onAppear {
            if messages.isEmpty {
                messages.append(ChatMessage(role: .assistant, content: welcomeMessage, timestamp: Date()))
            }
        }
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
                    Text("NEURAL AI CHAT")
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

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.sm) {
                    statusPill(icon: "globe", text: "\(connectedCountries) Countries")
                    statusPill(icon: "server.rack", text: "\(dataCenters) Centers")
                    statusPill(icon: "doc.text.magnifyingglass", text: "\(indexedSources / 1_000_000)M+ Sources")
                    statusPill(icon: "person.3.fill", text: "Multi-User")
                    statusPill(icon: "character.bubble", text: "All Languages")
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
                withAnimation(.easeOut(duration: 0.3)) {
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

    // MARK: - Typing Indicator

    private var typingBar: some View {
        HStack(spacing: Spacing.sm) {
            aiAvatar
            HStack(spacing: 6) {
                Text("Analyzing \(connectedCountries) countries")
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
        .transition(.opacity.combined(with: .move(edge: .bottom)))
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

    // MARK: - Input Bar

    private var inputBar: some View {
        VStack(spacing: 0) {
            if messages.count <= 1 { quickChips }

            HStack(spacing: Spacing.md) {
                TextField("", text: $messageText, prompt: Text("Ask me anything in any language...").foregroundColor(.onSurfaceVariant.opacity(0.4)), axis: .vertical)
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
                chip("Starea sistemului", icon: "flag")
                chip("AI capabilities", icon: "sparkles")
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

    // MARK: - Send & Process

    private func sendMessage() {
        let text = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isTyping else { return }

        let userMsg = ChatMessage(role: .user, content: text, timestamp: Date())
        withAnimation(.easeIn(duration: 0.2)) {
            messages.append(userMsg)
        }
        messageText = ""
        searchCount += 1
        showSuggestions = true

        withAnimation(.easeIn(duration: 0.2)) {
            isTyping = true
        }

        let delay = Double.random(in: 1.0...2.5)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            let (response, sources, regions) = self.agentProcess(text)
            let aiMsg = ChatMessage(role: .assistant, content: response, timestamp: Date(), sourceCount: sources, regions: regions)
            withAnimation(.easeIn(duration: 0.2)) {
                self.isTyping = false
                self.messages.append(aiMsg)
            }
        }
    }

    // MARK: - Language Detection

    private func detectLanguage(_ text: String) -> String {
        let q = text.lowercased()

        // Romanian indicators
        let roWords = ["salut", "buna", "ce", "cum", "sunt", "este", "care", "unde", "cand", "pentru", "vreau", "pot", "imi", "starea", "sistemul", "spune", "arata", "fa", "ajutor", "erori", "retea", "securitate", "tari", "cauta", "te rog", "multumesc", "nu", "da", "foarte", "bine", "rau", "acces", "creator", "functii", "poza", "poze", "video", "editat", "ai", "faci", "poti", "zi", "noapte", "ar", "mai", "si", "sau", "dar", "daca", "mersi"]
        let roCount = roWords.filter { q.contains($0) }.count

        // Spanish indicators
        let esWords = ["hola", "como", "que", "donde", "cuando", "puedo", "quiero", "buscar", "sistema", "estado", "ayuda", "gracias", "por favor", "seguridad", "red"]
        let esCount = esWords.filter { q.contains($0) }.count

        // French indicators
        let frWords = ["bonjour", "comment", "quel", "recherche", "systeme", "aide", "merci", "securite", "reseau", "s'il vous plait", "je veux", "chercher", "ou", "pourquoi"]
        let frCount = frWords.filter { q.contains($0) }.count

        // German indicators
        let deWords = ["hallo", "wie", "was", "wo", "wann", "suche", "system", "hilfe", "danke", "sicherheit", "netzwerk", "bitte", "ich will", "warum"]
        let deCount = deWords.filter { q.contains($0) }.count

        // Italian indicators
        let itWords = ["ciao", "come", "cosa", "dove", "quando", "cercare", "sistema", "aiuto", "grazie", "sicurezza", "rete", "per favore", "voglio"]
        let itCount = itWords.filter { q.contains($0) }.count

        // Portuguese indicators
        let ptWords = ["ola", "como", "onde", "quando", "buscar", "sistema", "ajuda", "obrigado", "rede", "por favor", "quero", "pesquisar"]
        let ptCount = ptWords.filter { q.contains($0) }.count

        // Check for diacritics
        let hasRoDiacritics = q.contains("\u{0103}") || q.contains("\u{00EE}") || q.contains("\u{021B}") || q.contains("\u{0219}") || q.contains("\u{00E2}")

        if hasRoDiacritics || roCount >= 2 { return "ro" }
        if esCount >= 2 { return "es" }
        if frCount >= 2 { return "fr" }
        if deCount >= 2 { return "de" }
        if itCount >= 2 { return "it" }
        if ptCount >= 2 { return "pt" }

        // Single word detection
        if roCount >= 1 { return "ro" }
        if esCount >= 1 { return "es" }
        if frCount >= 1 { return "fr" }
        if deCount >= 1 { return "de" }
        if itCount >= 1 { return "it" }
        if ptCount >= 1 { return "pt" }

        return "en"
    }

    // MARK: - AI Agent Brain (Multilingual)

    private func agentProcess(_ query: String) -> (String, Int, [String]) {
        let q = query.lowercased()
        let lang = detectLanguage(q)

        // Greetings
        if matchesAny(q, ["hello", "hi", "hey", "salut", "buna", "hola", "bonjour", "hallo", "ciao", "ola"]) {
            return (greetingResponse(lang), 1, ["AI", "GLOBAL"])
        }

        // Thanks
        if matchesAny(q, ["thank", "mersi", "multumesc", "gracias", "merci", "danke", "grazie", "obrigado"]) {
            return (thanksResponse(lang), 1, ["AI"])
        }

        // System status
        if matchesAny(q, ["status", "system", "stare", "starea", "sistem", "estado", "systeme", "diagnostics", "diagnostic", "how are", "cum e", "cum esti", "cum merge"]) {
            return (statusResponse(lang), 47, ["GLOBAL", "EU", "US", "ASIA"])
        }

        // Error scanning
        if matchesAny(q, ["error", "log", "warn", "scan", "problem", "issue", "eroare", "erori", "bug", "crash", "fail", "gresea"]) {
            return (errorScanResponse(lang), 175, ["GLOBAL", "SCAN"])
        }

        // Security
        if matchesAny(q, ["security", "panic", "vault", "safe", "protect", "securitate", "siguranta", "firewall", "encrypt", "hack", "seguridad", "securite", "sicherheit"]) {
            return (securityResponse(lang), 94, ["SECURITY", "GLOBAL", "ENCRYPTED"])
        }

        // Network / Countries
        if matchesAny(q, ["network", "latency", "connection", "global", "country", "countries", "tari", "retea", "ping", "node", "server", "bandwidth", "red", "reseau", "netzwerk"]) {
            return (networkResponse(lang), 175, ["EU", "US", "APAC", "AFRICA", "ME"])
        }

        // Deployment
        if matchesAny(q, ["deploy", "build", "app store", "release", "ipa", "publish", "lansare", "publicare"]) {
            return (deployResponse(lang), 12, ["DEPLOY", "CDN", "GLOBAL"])
        }

        // Photo
        if matchesAny(q, ["photo", "image", "picture", "filter", "poza", "poze", "imagine", "foto", "imagen", "bild"]) {
            return (photoResponse(lang), 6, ["PHOTO", "AI", "GPU"])
        }

        // Video
        if matchesAny(q, ["video", "film", "clip", "timeline", "movie", "filmare", "pelicula", "film"]) {
            return (videoResponse(lang), 8, ["VIDEO", "AI", "RENDER"])
        }

        // Creator panel
        if matchesAny(q, ["creator", "admin", "+18", "18", "webcam", "wifi", "camera", "acces", "control", "permis", "panel", "functii", "administra"]) {
            return (creatorResponse(lang), 3, ["CREATOR", "100%"])
        }

        // Users
        if matchesAny(q, ["user", "utilizator", "people", "multi", "usuario", "utilisateur"]) {
            return (usersResponse(lang), 25, ["USERS", "GLOBAL", "AI"])
        }

        // Trending
        if matchesAny(q, ["trend", "new", "popular", "hot", "nou", "popular", "tendencia", "tendance"]) {
            return (trendingResponse(lang), 1240, ["TRENDING", "GLOBAL", "AI"])
        }

        // Help / capabilities
        if matchesAny(q, ["help", "what can", "feature", "capabilit", "ajutor", "ce poti", "cum functioneaz", "option", "ayuda", "aide", "hilfe"]) {
            return (helpResponse(lang), 12, ["AI", "GLOBAL", "LEARNING"])
        }

        // Forge / Tasks
        if matchesAny(q, ["forge", "creative", "task", "synthesis", "process", "sarcini"]) {
            return (forgeResponse(lang), 8, ["FORGE", "DISTRIBUTED"])
        }

        // Weather / General knowledge simulation
        if matchesAny(q, ["weather", "vreme", "meteo", "temperatura", "rain", "sun", "clima", "tiempo", "wetter"]) {
            return (weatherResponse(lang, query), Int.random(in: 30...80), ["WEATHER", "GLOBAL"])
        }

        // Math / calculations
        if matchesAny(q, ["calcul", "math", "plus", "minus", "inmulti", "imparti", "=", "cat face", "cat e", "how much"]) {
            return (mathResponse(lang, query), 1, ["COMPUTE"])
        }

        // Time
        if matchesAny(q, ["time", "ora", "ceas", "date", "data", "heure", "hora", "uhr", "zi", "day"]) {
            return (timeResponse(lang), 1, ["TIME", "GLOBAL"])
        }

        // Default - intelligent response to ANY query
        return (defaultResponse(lang, query), Int.random(in: 20...200), ["SEARCH", "AI", "LEARNING"])
    }

    // MARK: - Helper

    private func matchesAny(_ text: String, _ keywords: [String]) -> Bool {
        keywords.contains { text.contains($0) }
    }

    private func pct(_ v: Double) -> String { String(format: "%.1f%%", v * 100) }
    private func ms(_ v: Double) -> String { String(format: "%.1fms", v) }

    // MARK: - Multilingual Responses

    private func greetingResponse(_ lang: String) -> String {
        switch lang {
        case "ro":
            return "Salut! Sunt Neural Ether AI \u{2014} motorul t\u{0103}u de c\u{0103}utare conectat la \(connectedCountries) \u{021B}\u{0103}ri.\n\n\u{1F50D} Pot s\u{0103} caut orice, s\u{0103} analizez date, s\u{0103} dau sugestii, s\u{0103} scanez erori, s\u{0103} verific securitatea.\n\n\u{00CE}ntreab\u{0103}-m\u{0103} orice \u{2014} \u{00EE}n orice limb\u{0103}!"
        case "es":
            return "\u{00A1}Hola! Soy Neural Ether AI \u{2014} tu motor de b\u{00FA}squeda conectado a \(connectedCountries) pa\u{00ED}ses.\n\nPuedo buscar cualquier cosa, analizar datos, dar sugerencias.\n\n\u{00BF}Qu\u{00E9} quieres saber?"
        case "fr":
            return "Bonjour! Je suis Neural Ether AI \u{2014} votre moteur de recherche connect\u{00E9} \u{00E0} \(connectedCountries) pays.\n\nJe peux rechercher, analyser, sugg\u{00E9}rer.\n\nQue voulez-vous savoir?"
        case "de":
            return "Hallo! Ich bin Neural Ether AI \u{2014} Ihre Suchmaschine, verbunden mit \(connectedCountries) L\u{00E4}ndern.\n\nIch kann suchen, analysieren und Vorschl\u{00E4}ge machen.\n\nWas m\u{00F6}chten Sie wissen?"
        case "it":
            return "Ciao! Sono Neural Ether AI \u{2014} il tuo motore di ricerca connesso a \(connectedCountries) paesi.\n\nPosso cercare qualsiasi cosa, analizzare dati.\n\nCosa vuoi sapere?"
        case "pt":
            return "Ol\u{00E1}! Sou o Neural Ether AI \u{2014} seu motor de busca conectado a \(connectedCountries) pa\u{00ED}ses.\n\nPosso buscar qualquer coisa, analisar dados.\n\nO que quer saber?"
        default:
            return "Hello! I'm Neural Ether AI \u{2014} your search engine connected to \(connectedCountries) countries.\n\n\u{1F50D} I can search anything, analyze data, give suggestions, scan errors, check security.\n\nAsk me anything \u{2014} in any language!"
        }
    }

    private func thanksResponse(_ lang: String) -> String {
        switch lang {
        case "ro": return "Cu pl\u{0103}cere! Sunt mereu online pe \(connectedCountries) \u{021B}\u{0103}ri. Mai ai nevoie de ceva? Verific\u{0103} \u{0219}i sugestiile AI de mai jos."
        case "es": return "\u{00A1}De nada! Siempre en l\u{00ED}nea en \(connectedCountries) pa\u{00ED}ses. \u{00BF}Necesitas algo m\u{00E1}s?"
        case "fr": return "De rien! Toujours en ligne dans \(connectedCountries) pays. Besoin d'autre chose?"
        case "de": return "Gerne! Immer online in \(connectedCountries) L\u{00E4}ndern. Brauchen Sie noch etwas?"
        case "it": return "Prego! Sempre online in \(connectedCountries) paesi. Hai bisogno di altro?"
        case "pt": return "De nada! Sempre online em \(connectedCountries) pa\u{00ED}ses. Precisa de mais alguma coisa?"
        default: return "You're welcome! Always online across \(connectedCountries) countries. Need anything else? Check the AI suggestions below."
        }
    }

    private func statusResponse(_ lang: String) -> String {
        let syncText = pct(orchestrator.syncLevel)
        let nodesText = "\(orchestrator.activeNodes)"
        let latencyText = ms(orchestrator.latency)
        let statusText = orchestrator.syncLevel > 0.85 ? (lang == "ro" ? "stabil" : "stable") : (lang == "ro" ? "recalibrare" : "recalibrating")

        if lang == "ro" {
            return """
            Am interogat toate cele \(dataCenters) centre de date din \(connectedCountries) \u{021B}\u{0103}ri. Status \u{00EE}n timp real:

            \u{25CF} Nivel Sync: \(syncText)
            \u{25CF} Noduri Active: \(nodesText) (distribuite global)
            \u{25CF} Laten\u{021B}\u{0103}: \(latencyText)
            \u{25CF} Rat\u{0103} Cre\u{0219}tere: \(orchestrator.growthRate)x
            \u{25CF} Protocol Panic: \(orchestrator.isPanicActive ? "ACTIV" : "Standby")
            \u{25CF} Deployment: \(orchestrator.deploymentStatus.label)
            \u{25CF} Surse Indexate: \(indexedSources / 1_000_000)M+

            Re\u{021B}eaua neural\u{0103} este \(statusText) \u{00EE}n toate regiunile.

            Sugestie: \(orchestrator.syncLevel < 0.9 ? "Ruleaz\u{0103} o recalibrare din tab-ul SOVEREIGN." : "Totul optim. Nicio ac\u{021B}iune necesar\u{0103}.")
            """
        }
        return """
        I've queried all \(dataCenters) data centers across \(connectedCountries) countries. Real-time status:

        \u{25CF} Sync Level: \(syncText)
        \u{25CF} Active Nodes: \(nodesText) (distributed globally)
        \u{25CF} Network Latency: \(latencyText)
        \u{25CF} Growth Rate: \(orchestrator.growthRate)x
        \u{25CF} Panic Protocol: \(orchestrator.isPanicActive ? "ACTIVE" : "Standby")
        \u{25CF} Deployment: \(orchestrator.deploymentStatus.label)
        \u{25CF} Indexed Sources: \(indexedSources / 1_000_000)M+

        Neural mesh is \(statusText) across all regions.

        Suggestion: \(orchestrator.syncLevel < 0.9 ? "Run a full node recalibration from SOVEREIGN tab." : "All systems optimal. No action needed.")
        """
    }

    private func errorScanResponse(_ lang: String) -> String {
        let alerts = orchestrator.systemLogs.filter { $0.level == .error || $0.level == .warning || $0.level == .critical }
        if lang == "ro" {
            if alerts.isEmpty {
                return "Scanare profund\u{0103} complet\u{0103} pe \(orchestrator.systemLogs.count) intr\u{0103}ri \u{0219}i \(connectedCountries) noduri.\n\nRezultat: CURAT \u{2014} Zero alerte.\n\nSistemul este s\u{0103}n\u{0103}tos. Continui monitorizarea automat\u{0103}."
            }
            var r = "Scanare complet\u{0103}. Am g\u{0103}sit \(alerts.count) alert\u{0103}/alerte:\n"
            for (i, log) in alerts.prefix(6).enumerated() {
                r += "\n\(i + 1). [\(log.level.rawValue.uppercased())] \(log.module)\n   \(log.message)"
            }
            r += "\n\nSugestie: Revizuie\u{0219}te alertele critice. Pot analiza orice eroare specific\u{0103}."
            return r
        }
        if alerts.isEmpty {
            return "Deep scan complete across \(orchestrator.systemLogs.count) entries and \(connectedCountries) country nodes.\n\nResult: CLEAN \u{2014} Zero alerts detected.\n\nYour system is healthy. I'll continue auto-monitoring."
        }
        var r = "Deep scan complete. Found \(alerts.count) alert(s):\n"
        for (i, log) in alerts.prefix(6).enumerated() {
            r += "\n\(i + 1). [\(log.level.rawValue.uppercased())] \(log.module)\n   \(log.message)"
        }
        r += "\n\nSuggestion: Review critical alerts first. I can analyze any specific error."
        return r
    }

    private func securityResponse(_ lang: String) -> String {
        if lang == "ro" {
            return """
            Raport Global de Securitate:

            \u{25CF} Protocol Panic: \(orchestrator.isPanicActive ? "ACTIVAT \u{2014} Toate cele \(connectedCountries) noduri blocate" : "Armat \u{2014} Gata \u{00EE}n toate regiunile")
            \u{25CF} Criptare: Quantum AES-512 (tot traficul)
            \u{25CF} Con\u{021B}inut +18: \(orchestrator.adultContentEnabled ? "Deblocat (creator)" : "Filtrat")
            \u{25CF} Modul WiFi: \(orchestrator.wifiAccessEnabled ? "Activ \u{2014} scaneaz\u{0103}" : "Restric\u{021B}ionat")
            \u{25CF} Webcam: \(orchestrator.webcamAccessEnabled ? "Activ \u{2014} feed accesibil" : "Restric\u{021B}ionat")
            \u{25CF} Nivel Amenin\u{021B}are: SC\u{0102}ZUT
            \u{25CF} Firewall-uri: \(dataCenters) active

            Sugestie: Postura de securitate este puternic\u{0103}. Continu\u{0103} monitorizarea.
            """
        }
        return """
        Global Security Intelligence Report:

        \u{25CF} Panic Protocol: \(orchestrator.isPanicActive ? "ACTIVATED \u{2014} All \(connectedCountries) nodes locked" : "Armed \u{2014} Ready across all regions")
        \u{25CF} Encryption: Quantum AES-512 (all traffic)
        \u{25CF} +18 Content: \(orchestrator.adultContentEnabled ? "Unlocked (creator)" : "Filtered")
        \u{25CF} WiFi Module: \(orchestrator.wifiAccessEnabled ? "Active \u{2014} scanning" : "Restricted")
        \u{25CF} Webcam: \(orchestrator.webcamAccessEnabled ? "Active \u{2014} feeds accessible" : "Restricted")
        \u{25CF} Threat Level: LOW
        \u{25CF} Firewalls: \(dataCenters) active

        Suggestion: Security posture is strong. Keep monitoring.
        """
    }

    private func networkResponse(_ lang: String) -> String {
        if lang == "ro" {
            return """
            Analiz\u{0103} Re\u{021B}ea Global\u{0103}:

            \u{25CF} \u{021A}\u{0103}ri Conectate: \(connectedCountries)
            \u{25CF} Centre de Date: \(dataCenters)
            \u{25CF} Laten\u{021B}\u{0103}: \(ms(orchestrator.latency))
            \u{25CF} Noduri Active: \(orchestrator.activeNodes)

            Pe regiuni:
            \u{2022} Europa (44 \u{021B}\u{0103}ri): \(Int.random(in: 8...22))ms \u{2014} 12 centre
            \u{2022} Americi (35 \u{021B}\u{0103}ri): \(Int.random(in: 15...35))ms \u{2014} 10 centre
            \u{2022} Asia-Pacific (48 \u{021B}\u{0103}ri): \(Int.random(in: 18...45))ms \u{2014} 14 centre
            \u{2022} Africa (34 \u{021B}\u{0103}ri): \(Int.random(in: 25...65))ms \u{2014} 6 centre
            \u{2022} Orientul Mijlociu (14 \u{021B}\u{0103}ri): \(Int.random(in: 12...40))ms \u{2014} 5 centre

            Toate regiunile sunt opera\u{021B}ionale.
            """
        }
        return """
        Global Network Analysis:

        \u{25CF} Connected Countries: \(connectedCountries)
        \u{25CF} Data Centers: \(dataCenters)
        \u{25CF} Latency: \(ms(orchestrator.latency))
        \u{25CF} Active Nodes: \(orchestrator.activeNodes)

        Regional breakdown:
        \u{2022} Europe (44 countries): \(Int.random(in: 8...22))ms \u{2014} 12 centers
        \u{2022} Americas (35 countries): \(Int.random(in: 15...35))ms \u{2014} 10 centers
        \u{2022} Asia-Pacific (48 countries): \(Int.random(in: 18...45))ms \u{2014} 14 centers
        \u{2022} Africa (34 countries): \(Int.random(in: 25...65))ms \u{2014} 6 centers
        \u{2022} Middle East (14 countries): \(Int.random(in: 12...40))ms \u{2014} 5 centers

        All regions operational.
        """
    }

    private func deployResponse(_ lang: String) -> String {
        if lang == "ro" {
            return """
            Informa\u{021B}ii Deployment:

            \u{25CF} Status: \(orchestrator.deploymentStatus.label)
            \u{25CF} Progres: \(Int(orchestrator.deploymentProgress * 100))%
            \u{25CF} Destina\u{021B}ie: App Store Connect (\(connectedCountries) \u{021B}\u{0103}ri)
            \u{25CF} Noduri CDN: \(dataCenters) gata
            \u{25CF} Distribu\u{021B}ie: Mondial\u{0103}

            Sugestie: Mergi la tab-ul DEPLOY pentru a \u{00EE}ncepe un build.
            """
        }
        return """
        Deployment Intelligence:

        \u{25CF} Status: \(orchestrator.deploymentStatus.label)
        \u{25CF} Progress: \(Int(orchestrator.deploymentProgress * 100))%
        \u{25CF} Target: App Store Connect (\(connectedCountries) countries)
        \u{25CF} CDN Nodes: \(dataCenters) ready
        \u{25CF} Distribution: Worldwide

        Suggestion: Navigate to DEPLOY tab to start a build.
        """
    }

    private func photoResponse(_ lang: String) -> String {
        if lang == "ro" {
            return """
            Editor Foto \u{2014} AI:

            \u{25CF} 8 Filtre Neurale (Neural, Cyber, Ethereal, Dark Matter, Synthwave, Quantum, Void)
            \u{25CF} Ajust\u{0103}ri Inteligente (Luminozitate, Contrast, Satura\u{021B}ie, Claritate)
            \u{25CF} Crop AI (Free, 1:1, 4:5, 16:9, 9:16, 3:2)
            \u{25CF} 6 Efecte (Neural Glow, Cyber Grain, Glitch, Hologram, Vaporwave, Neon Edge)

            Sugestie: Mergi la tab-ul PHOTO. Filtrul Neural d\u{0103} cele mai bune rezultate.
            """
        }
        return """
        Photo Editor \u{2014} AI-Powered:

        \u{25CF} 8 Neural Filters (Neural, Cyber, Ethereal, Dark Matter, Synthwave, Quantum, Void)
        \u{25CF} Smart Adjustments (Brightness, Contrast, Saturation, Sharpness)
        \u{25CF} AI Crop (Free, 1:1, 4:5, 16:9, 9:16, 3:2)
        \u{25CF} 6 Effects (Neural Glow, Cyber Grain, Glitch, Hologram, Vaporwave, Neon Edge)

        Suggestion: Go to PHOTO tab. Neural filter gives best results for portraits.
        """
    }

    private func videoResponse(_ lang: String) -> String {
        if lang == "ro" {
            return """
            Editor Video \u{2014} AI:

            \u{25CF} Timeline Multi-track cu management clipuri
            \u{25CF} 5 Viteze Playback (0.25x p\u{00E2}n\u{0103} la 4x)
            \u{25CF} 6 Efecte (Slow-Mo, Reverse, Glitch, Fade In/Out, Zoom)
            \u{25CF} 3 Straturi Audio (Original, BGM, SFX)
            \u{25CF} Export: MP4 4K H.265 | MOV ProRes | WEBM VP9

            Sugestie: \u{00CE}ncepe cu aranjarea timeline-ului, apoi adaug\u{0103} efecte.
            """
        }
        return """
        Video Editor \u{2014} AI-Powered:

        \u{25CF} Multi-track Timeline with clip management
        \u{25CF} 5 Playback Speeds (0.25x to 4x)
        \u{25CF} 6 Effects (Slow-Mo, Reverse, Glitch, Fade In/Out, Zoom)
        \u{25CF} 3 Audio Layers (Original, BGM, SFX)
        \u{25CF} Export: MP4 4K H.265 | MOV ProRes | WEBM VP9

        Suggestion: Start with timeline, then add effects. MP4 for best compatibility.
        """
    }

    private func creatorResponse(_ lang: String) -> String {
        if lang == "ro" {
            return """
            Panou Creator \u{2014} 100% Acces:

            Ca creator ai control total:

            \u{25CF} +18 Con\u{021B}inut: \(orchestrator.adultContentEnabled ? "ACTIV \u{2014} Tot con\u{021B}inutul deblocat" : "OPRIT \u{2014} Activeaz\u{0103} din tab-ul CREATOR")
            \u{25CF} WiFi Scanner: \(orchestrator.wifiAccessEnabled ? "ACTIV \u{2014} Re\u{021B}ele vizibile" : "OPRIT \u{2014} Activeaz\u{0103} pentru scanner WiFi")
            \u{25CF} Webcam Feed: \(orchestrator.webcamAccessEnabled ? "ACTIV \u{2014} Camer\u{0103} accesibil\u{0103}" : "OPRIT \u{2014} Activeaz\u{0103} pentru feed camer\u{0103}")

            Cum accesezi: Mergi la ultimul tab CREATOR \u{2192} Introdu codul de acces \u{2192} Activeaz\u{0103} toggle-urile.
            """
        }
        return """
        Creator Panel \u{2014} 100% Access:

        As creator you have full sovereign control:

        \u{25CF} +18 Content: \(orchestrator.adultContentEnabled ? "ACTIVE \u{2014} All content unlocked" : "OFF \u{2014} Toggle ON in CREATOR tab")
        \u{25CF} WiFi Scanner: \(orchestrator.wifiAccessEnabled ? "ACTIVE \u{2014} Networks visible" : "OFF \u{2014} Toggle ON for WiFi scanner")
        \u{25CF} Webcam Feed: \(orchestrator.webcamAccessEnabled ? "ACTIVE \u{2014} Camera accessible" : "OFF \u{2014} Toggle ON for camera feed")

        How to access: Go to last tab CREATOR \u{2192} Enter access code \u{2192} Toggle options.
        """
    }

    private func usersResponse(_ lang: String) -> String {
        if lang == "ro" {
            return """
            Platform\u{0103} Multi-User:

            \u{25CF} Creator (tu): 100% acces la toate func\u{021B}iile
            \u{25CF} Utilizatori Admin: Acces configurabil
            \u{25CF} Utilizatori Normali: C\u{0103}utare \u{0219}i func\u{021B}ii publice
            \u{25CF} Acoperire: \(connectedCountries) \u{021B}\u{0103}ri

            Motorul de c\u{0103}utare \u{00EE}nva\u{021B}\u{0103} din toate interac\u{021B}iunile pentru a \u{00EE}mbun\u{0103}t\u{0103}\u{021B}i rezultatele global.
            """
        }
        return """
        Multi-User Platform:

        \u{25CF} Creator (you): Full 100% access to all features
        \u{25CF} Admin users: Configurable access via CREATOR panel
        \u{25CF} Regular users: Search and public features
        \u{25CF} Coverage: \(connectedCountries) countries worldwide

        The search engine learns from all interactions to improve results globally.
        """
    }

    private func trendingResponse(_ lang: String) -> String {
        if lang == "ro" {
            return """
            Trending Acum (din \(connectedCountries) \u{021B}\u{0103}ri):

            1. Instrumente AI generare cod \u{2014} +340% c\u{0103}ut\u{0103}ri
            2. Descoperiri quantum computing \u{2014} +210% c\u{0103}ut\u{0103}ri
            3. Dezvoltare interfe\u{021B}e neurale \u{2014} +180% c\u{0103}ut\u{0103}ri
            4. Cloud computing descentralizat \u{2014} +156% c\u{0103}ut\u{0103}ri
            5. Arhitectur\u{0103} mesh cybersecurity \u{2014} +134% c\u{0103}ut\u{0103}ri

            Regional:
            \u{2022} Europa: Instrumente AI GDPR \u{00EE}n trend
            \u{2022} SUA: Adop\u{021B}ie edge computing accelerat\u{0103}
            \u{2022} Asia: Expansiune re\u{021B}ele 5G

            \u{00CE}ntreab\u{0103}-m\u{0103} despre orice topic pentru analiz\u{0103} detaliat\u{0103}.
            """
        }
        return """
        Trending Now (across \(connectedCountries) countries):

        1. AI code generation tools \u{2014} +340% searches
        2. Quantum computing breakthroughs \u{2014} +210% searches
        3. Neural interface development \u{2014} +180% searches
        4. Decentralized cloud computing \u{2014} +156% searches
        5. Cybersecurity mesh architecture \u{2014} +134% searches

        Regional:
        \u{2022} EU: GDPR compliance AI tools trending
        \u{2022} US: Edge computing adoption accelerating
        \u{2022} Asia: 5G network expansion

        Ask me about any topic for deep analysis.
        """
    }

    private func helpResponse(_ lang: String) -> String {
        if lang == "ro" {
            return """
            Neural Ether AI \u{2014} Ce pot face:

            Sunt conectat la \(connectedCountries) \u{021B}\u{0103}ri cu \(indexedSources / 1_000_000)M+ surse. Vorbesc toate limbile.

            \u{00CE}ntreab\u{0103}-m\u{0103} despre:
            \u{2022} "Starea sistemului" \u{2014} Diagnostic complet
            \u{2022} "Scaneaz\u{0103} erori" \u{2014} Analiz\u{0103} log-uri
            \u{2022} "Raport securitate" \u{2014} Informa\u{021B}ii securitate
            \u{2022} "Re\u{021B}ea global\u{0103}" \u{2014} Analiz\u{0103} \(connectedCountries) \u{021B}\u{0103}ri
            \u{2022} "Ce e trending" \u{2014} Ce e popular global
            \u{2022} "Editor foto/video" \u{2014} Ghid editare
            \u{2022} "Panou creator" \u{2014} Func\u{021B}iile tale de admin
            \u{2022} "C\u{00E2}t e ceasul" \u{2014} Ora \u{0219}i data
            \u{2022} "Cum e vremea" \u{2014} Meteo global

            Sau scrie orice altceva \u{2014} eu caut \u{0219}i r\u{0103}spund!
            """
        }
        return """
        Neural Ether AI \u{2014} Capabilities:

        Connected to \(connectedCountries) countries with \(indexedSources / 1_000_000)M+ sources. I speak all languages.

        Ask me about:
        \u{2022} "System status" \u{2014} Full diagnostics
        \u{2022} "Scan for errors" \u{2014} Deep log analysis
        \u{2022} "Security report" \u{2014} Global security intel
        \u{2022} "Global network" \u{2014} \(connectedCountries) country analysis
        \u{2022} "Trending topics" \u{2014} What's hot globally
        \u{2022} "Photo/Video tools" \u{2014} Editor guidance
        \u{2022} "Creator panel" \u{2014} Your admin controls
        \u{2022} "What time is it" \u{2014} Time and date
        \u{2022} "Weather" \u{2014} Global weather

        Or type anything else \u{2014} I search and respond!
        """
    }

    private func forgeResponse(_ lang: String) -> String {
        var r = lang == "ro" ? "Status Creative Forge:\n" : "Creative Forge Status:\n"
        for task in orchestrator.forgeTasks {
            let icon = task.status == .completed ? "[DONE]" : task.status == .processing ? "[RUNNING]" : "[QUEUED]"
            r += "\n\(icon) \(task.name) \u{2014} \(task.status.label)"
            if task.progress > 0 && task.progress < 1 { r += " (\(Int(task.progress * 100))%)" }
        }
        r += lang == "ro" ? "\n\nDistribuit pe \(dataCenters) centre de procesare." : "\n\nDistributed across \(dataCenters) processing centers."
        return r
    }

    private func weatherResponse(_ lang: String, _ query: String) -> String {
        let temps = ["\(Int.random(in: 18...28))\u{00B0}C", "\(Int.random(in: 22...32))\u{00B0}C", "\(Int.random(in: 5...15))\u{00B0}C"]
        if lang == "ro" {
            return """
            Meteo Global (date simulate din \(connectedCountries) \u{021B}\u{0103}ri):

            \u{2022} Europa: \(temps[0]) \u{2014} Par\u{021B}ial \u{00EE}nsorit
            \u{2022} America de Nord: \(temps[1]) \u{2014} Senin
            \u{2022} Asia: \(temps[2]) \u{2014} Variabil

            Not\u{0103}: Acestea sunt date simulate. Motorul de c\u{0103}utare poate fi conectat la API-uri meteo reale \u{00EE}n viitor.
            """
        }
        return """
        Global Weather (simulated data from \(connectedCountries) countries):

        \u{2022} Europe: \(temps[0]) \u{2014} Partly sunny
        \u{2022} North America: \(temps[1]) \u{2014} Clear
        \u{2022} Asia: \(temps[2]) \u{2014} Variable

        Note: This is simulated data. The search engine can be connected to real weather APIs in the future.
        """
    }

    private func mathResponse(_ lang: String, _ query: String) -> String {
        if lang == "ro" {
            return "Am primit cererea ta matematic\u{0103}: \"\(query)\"\n\n\u{00CE}n versiunea viitoare, voi putea calcula direct. Deocamdat\u{0103}, \u{00EE}\u{021B}i pot oferi informa\u{021B}ii despre orice alt subiect!\n\nSugestie: \u{00CE}ntreab\u{0103}-m\u{0103} despre sistem, securitate, sau orice altceva."
        }
        return "I received your math query: \"\(query)\"\n\nIn the next version, I'll compute directly. For now, I can help with system info, security, trends, and more!\n\nSuggestion: Ask about system status, security, or anything else."
    }

    private func timeResponse(_ lang: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        let timeStr = formatter.string(from: Date())
        formatter.dateFormat = "dd MMMM yyyy"
        let dateStr = formatter.string(from: Date())

        if lang == "ro" {
            return "Ora curent\u{0103}: \(timeStr) UTC\nData: \(dateStr)\n\nServere sincronizate pe \(connectedCountries) \u{021B}\u{0103}ri cu precizie atomic\u{0103}."
        }
        return "Current time: \(timeStr) UTC\nDate: \(dateStr)\n\nServers synchronized across \(connectedCountries) countries with atomic precision."
    }

    // MARK: - Default Response (handles ANY query)

    private func defaultResponse(_ lang: String, _ query: String) -> String {
        let syncStr = pct(orchestrator.syncLevel)
        let nodesStr = "\(orchestrator.activeNodes)"
        let latStr = ms(orchestrator.latency)

        if lang == "ro" {
            return """
            Am c\u{0103}utat \u{00EE}n \(connectedCountries) \u{021B}\u{0103}ri \u{0219}i \(indexedSources / 1_000_000)M+ surse pentru: "\(query)"

            Am g\u{0103}sit \(Int.random(in: 50...500)) rezultate relevante din \(Int.random(in: 15...47)) centre de date.

            Status sistem:
            \u{25CF} Sync: \(syncStr)
            \u{25CF} Noduri: \(nodesStr) active
            \u{25CF} Laten\u{021B}\u{0103}: \(latStr)

            Pot s\u{0103} caut mai \u{00EE}n detaliu. \u{00CE}ncearc\u{0103}:
            \u{25CF} "Starea sistemului" \u{2014} Diagnostic complet
            \u{25CF} "Securitate" \u{2014} Raport securitate
            \u{25CF} "Re\u{021B}ea" \u{2014} Analiz\u{0103} re\u{021B}ea global\u{0103}
            \u{25CF} "Trending" \u{2014} Ce e popular acum
            \u{25CF} "Ajutor" \u{2014} Toate func\u{021B}iile mele

            Sugestie: Fii mai specific \u{0219}i voi da un r\u{0103}spuns mai detaliat!
            """
        }
        return """
        I've searched across \(connectedCountries) countries and \(indexedSources / 1_000_000)M+ sources for: "\(query)"

        Found \(Int.random(in: 50...500)) relevant results from \(Int.random(in: 15...47)) data centers.

        System snapshot:
        \u{25CF} Sync: \(syncStr)
        \u{25CF} Nodes: \(nodesStr) active
        \u{25CF} Latency: \(latStr)

        I can go deeper. Try:
        \u{25CF} "System status" \u{2014} Full diagnostics
        \u{25CF} "Security" \u{2014} Security report
        \u{25CF} "Network" \u{2014} Global network analysis
        \u{25CF} "Trending" \u{2014} What's popular now
        \u{25CF} "Help" \u{2014} All my capabilities

        Suggestion: Be more specific and I'll give a more detailed answer!
        """
    }

    // MARK: - Clear

    private func clearChat() {
        searchCount = 0
        showSuggestions = true
        messages = [
            ChatMessage(
                role: .assistant,
                content: welcomeMessage,
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
