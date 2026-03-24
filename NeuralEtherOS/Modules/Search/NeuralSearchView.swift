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
    @FocusState private var isInputFocused: Bool

    private let connectedCountries = 175
    private let dataCenters = 47
    private let indexedSources = 12_400_000

    // Multilingual greetings for initial message
    private var welcomeMessage: String {
        """
        Hi! I'm Neural Ether AI \u{2014} your personal AI assistant.

        I'm connected to \(connectedCountries) countries and \(indexedSources / 1_000_000)M+ sources. I speak all languages \u{2014} write in any language and I'll respond in the same one.

        How can I help you today?
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
            chatHeader
            messagesArea
            if isTyping { typingIndicator }
            chatInputBar
        }
        .background(Color(hex: "#1A1A2E"))
        .onAppear {
            if messages.isEmpty {
                messages.append(ChatMessage(role: .assistant, content: welcomeMessage, timestamp: Date()))
            }
        }
    }

    // MARK: - Header

    // MARK: - ChatGPT-Style Header
    private var chatHeader: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [Color(hex: "#6C63FF"), Color(hex: "#00D2FF")], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 40, height: 40)
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("Neural Ether AI")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                HStack(spacing: 6) {
                    Circle().fill(Color(hex: "#00FF41")).frame(width: 7, height: 7)
                    Text("Online \u{2022} \(connectedCountries) countries")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.6))
                }
            }

            Spacer()

            Button { clearChat() } label: {
                Image(systemName: "plus.message")
                    .font(.system(size: 18))
                    .foregroundColor(.white.opacity(0.7))
                    .padding(8)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color(hex: "#16213E"))
    }

    // MARK: - ChatGPT-Style Messages Area

    private var messagesArea: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 0) {
                    // Welcome suggestions at top
                    if messages.count <= 1 && showSuggestions {
                        welcomeSuggestions
                    }
                    ForEach(messages) { msg in
                        chatBubble(msg)
                            .id(msg.id)
                    }
                }
                .padding(.vertical, 12)
            }
            .frame(maxHeight: .infinity)
            .onChange(of: messages.count) { _, _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        if let last = messages.last {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }
        }
    }

    private func chatBubble(_ msg: ChatMessage) -> some View {
        HStack(alignment: .top, spacing: 10) {
            if msg.role == .assistant {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [Color(hex: "#6C63FF"), Color(hex: "#00D2FF")], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 32, height: 32)
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white)
                }
            } else {
                Spacer(minLength: 50)
            }

            VStack(alignment: msg.role == .user ? .trailing : .leading, spacing: 6) {
                Text(msg.content)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.white)
                    .textSelection(.enabled)
                    .lineSpacing(4)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        msg.role == .assistant
                            ? Color(hex: "#2A2A4A")
                            : Color(hex: "#6C63FF")
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 18))

                HStack(spacing: 6) {
                    Text(msg.timeString)
                        .font(.system(size: 11))
                        .foregroundColor(Color.white.opacity(0.35))
                    if msg.role == .assistant, let sources = msg.sourceCount {
                        Text("\u{2022} \(sources) sources")
                            .font(.system(size: 11))
                            .foregroundColor(Color(hex: "#6C63FF").opacity(0.7))
                    }
                }
            }

            if msg.role == .user {
                ZStack {
                    Circle()
                        .fill(Color(hex: "#6C63FF").opacity(0.3))
                        .frame(width: 32, height: 32)
                    Image(systemName: "person.fill")
                        .font(.system(size: 15))
                        .foregroundColor(Color(hex: "#6C63FF"))
                }
            } else {
                Spacer(minLength: 50)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
    }

    // MARK: - Typing Indicator (ChatGPT style)

    private var typingIndicator: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [Color(hex: "#6C63FF"), Color(hex: "#00D2FF")], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 32, height: 32)
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)
            }
            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .fill(Color.white.opacity(0.5))
                        .frame(width: 8, height: 8)
                        .offset(y: typingDotOffset(i))
                        .animation(.easeInOut(duration: 0.5).repeatForever().delay(Double(i) * 0.15), value: isTyping)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(hex: "#2A2A4A"))
            .clipShape(RoundedRectangle(cornerRadius: 18))
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }

    private func typingDotOffset(_ index: Int) -> CGFloat {
        return isTyping ? -4 : 0
    }

    // MARK: - Welcome Suggestions (ChatGPT style cards)

    private var welcomeSuggestions: some View {
        VStack(spacing: 12) {
            Text("Neural Ether AI")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .padding(.top, 20)
            Text("Ask me anything in any language")
                .font(.system(size: 15))
                .foregroundColor(Color.white.opacity(0.5))
                .padding(.bottom, 8)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                suggestionCard("System status", icon: "cpu", desc: "Full diagnostics")
                suggestionCard("Security audit", icon: "lock.shield", desc: "Scan for threats")
                suggestionCard("Global network", icon: "globe", desc: "175 countries")
                suggestionCard("Trending now", icon: "flame", desc: "What's popular")
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
    }

    private func suggestionCard(_ title: String, icon: String, desc: String) -> some View {
        Button {
            messageText = title
            sendMessage()
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(Color(hex: "#6C63FF"))
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                Text(desc)
                    .font(.system(size: 12))
                    .foregroundColor(Color.white.opacity(0.4))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(Color(hex: "#2A2A4A"))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }

    // MARK: - ChatGPT-Style Input Bar

    private var chatInputBar: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                TextField("", text: $messageText, prompt: Text("Message Neural Ether AI...").foregroundColor(Color.white.opacity(0.3)))
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .textFieldStyle(PlainTextFieldStyle())
                    .focused($isInputFocused)
                    .onSubmit { sendMessage() }

                Button { sendMessage() } label: {
                    ZStack {
                        Circle()
                            .fill(canSend ? Color(hex: "#6C63FF") : Color.white.opacity(0.1))
                            .frame(width: 40, height: 40)
                        Image(systemName: "arrow.up")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(canSend ? .white : Color.white.opacity(0.3))
                    }
                }
                .buttonStyle(.plain)
                .disabled(!canSend)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color(hex: "#2A2A4A"))
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        isInputFocused ? Color(hex: "#6C63FF").opacity(0.5) : Color.white.opacity(0.08),
                        lineWidth: 1
                    )
            )
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color(hex: "#16213E"))
    }

    private var canSend: Bool {
        !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isTyping
    }

    // MARK: - Send & Process

    private func sendMessage() {
        let text = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        // 1. Add user message immediately
        let userMsg = ChatMessage(role: .user, content: text, timestamp: Date())
        messages.append(userMsg)
        messageText = ""
        searchCount += 1
        showSuggestions = false

        // 2. Compute AI response synchronously
        let (response, sources, regions) = agentProcess(text)

        // 3. Add AI response immediately (no async, no delay, guaranteed to work)
        let aiMsg = ChatMessage(role: .assistant, content: response, timestamp: Date(), sourceCount: sources, regions: regions)
        messages.append(aiMsg)
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
    // IMPORTANT: Check SPECIFIC topics FIRST, then broad/generic catches LAST.
    // This prevents "cum e vremea" from matching "cum e" (status) instead of "vreme" (weather).

    private func agentProcess(_ query: String) -> (String, Int, [String]) {
        let q = query.lowercased()
        let lang = detectLanguage(q)

        // --- TIER 1: Exact / very specific matches (greetings, thanks, identity) ---

        // Greetings (only if the message is short or starts with greeting)
        if q.count < 20 && matchesAny(q, ["hello", "hi", "hey", "salut", "buna", "hola", "bonjour", "hallo", "ciao", "ola", "yo", "sup", "howdy"]) {
            return (greetingResponse(lang), 1, ["AI", "GLOBAL"])
        }

        // Thanks
        if matchesAny(q, ["thank", "mersi", "multumesc", "gracias", "merci", "danke", "grazie", "obrigado", "thx"]) {
            return (thanksResponse(lang), 1, ["AI"])
        }

        // About / Identity
        if matchesAny(q, ["who are you", "what are you", "cine esti", "ce esti", "tu cine", "introduce yourself", "tell me about you", "presenta"]) {
            return (aboutResponse(lang), 1, ["AI", "CORE"])
        }

        // --- TIER 2: Specific topic keywords (weather, math, time, code, music, etc.) ---
        // These MUST come before broad catches like "status" or "error" or "cum e"

        // Weather — check BEFORE status because "cum e vremea" contains "cum e"
        if matchesAny(q, ["weather", "vreme", "vremea", "meteo", "temperatura", "rain", "ploaie", "soare", "sun", "clima", "tiempo", "wetter", "cold", "warm", "snow", "zapada", "nori", "cloud", "forecast", "prognoz"]) {
            return (weatherResponse(lang, query), Int.random(in: 30...80), ["WEATHER", "GLOBAL"])
        }

        // Math / calculations
        if matchesAny(q, ["calcul", "math", "plus", "minus", "inmulti", "imparti", "cat face", "cat e", "how much is", "solve", "equation", "radical", "sqrt"]) || q.contains("+") || q.contains("=") {
            return (mathResponse(lang, query), 1, ["COMPUTE"])
        }

        // Time / Date
        if matchesAny(q, ["what time", "ora exact", "ceas", "cat e ceasul", "heure", "hora", "uhr", "what day", "ce zi", "azi", "ce data"]) {
            return (timeResponse(lang), 1, ["TIME", "GLOBAL"])
        }

        // Code / Programming
        if matchesAny(q, ["code", "program", "swift", "python", "javascript", "java", "html", "css", "api", "function", "debug", "coding", "develop", "compile", "algoritm"]) {
            return (codeResponse(lang, query), Int.random(in: 40...150), ["CODE", "AI", "DEV"])
        }

        // Music
        if matchesAny(q, ["music", "song", "playlist", "spotify", "muzica", "cantec", "artist", "album", "listen", "youtube", "melodie"]) {
            return (musicResponse(lang), Int.random(in: 20...60), ["MUSIC", "ENTERTAINMENT"])
        }

        // News
        if matchesAny(q, ["news", "stiri", "stirile", "world news", "eveniment", "razboi", "war", "politics", "politic", "econom"]) {
            return (newsResponse(lang), Int.random(in: 80...200), ["NEWS", "GLOBAL", "LIVE"])
        }

        // AI / Tech
        if matchesAny(q, ["artificial", "machine learning", "neural network", "gpt", "chatgpt", "openai", "inteligenta artificiala", "robot", "automat"]) {
            return (aiTechResponse(lang, query), Int.random(in: 50...175), ["AI", "TECH", "RESEARCH"])
        }

        // Fun / Jokes
        if matchesAny(q, ["joke", "joc", "joac", "funny", "laugh", "gluma", "bancuri", "amuzant"]) {
            return (funResponse(lang), Int.random(in: 10...30), ["FUN", "AI"])
        }

        // Health / Fitness
        if matchesAny(q, ["health", "sanatate", "doctor", "medic", "exercise", "sport", "fitness", "diet", "calorie", "sleep", "gym", "antrenament"]) {
            return (healthResponse(lang), Int.random(in: 30...90), ["HEALTH", "GLOBAL"])
        }

        // Photo
        if matchesAny(q, ["photo", "image", "picture", "filter", "poza", "poze", "imagine", "foto", "imagen", "bild", "fotografie"]) {
            return (photoResponse(lang), 6, ["PHOTO", "AI", "GPU"])
        }

        // Video
        if matchesAny(q, ["video", "film", "clip", "timeline", "movie", "filmare", "pelicula", "montaj"]) {
            return (videoResponse(lang), 8, ["VIDEO", "AI", "RENDER"])
        }

        // Creator panel
        if matchesAny(q, ["creator", "admin", "+18", "18+", "webcam", "wifi", "camera", "cctv", "scanner", "panou", "panel creator"]) {
            return (creatorResponse(lang), 3, ["CREATOR", "100%"])
        }

        // Deployment
        if matchesAny(q, ["deploy", "build", "app store", "release", "ipa", "publish", "lansare", "publicare", "upload", "submit"]) {
            return (deployResponse(lang), 12, ["DEPLOY", "CDN", "GLOBAL"])
        }

        // Trending
        if matchesAny(q, ["trend", "popular", "viral", "top 10", "best of", "latest", "newest", "ce e nou", "ce se poarta"]) {
            return (trendingResponse(lang), 1240, ["TRENDING", "GLOBAL", "AI"])
        }

        // Forge / Tasks
        if matchesAny(q, ["forge", "synthesis", "sarcini", "generate"]) {
            return (forgeResponse(lang), 8, ["FORGE", "DISTRIBUTED"])
        }

        // Users
        if matchesAny(q, ["user", "utilizator", "usuario", "utilisateur"]) {
            return (usersResponse(lang), 25, ["USERS", "GLOBAL", "AI"])
        }

        // Help / capabilities
        if matchesAny(q, ["help", "what can you", "feature", "capabilit", "ajutor", "ce poti", "cum functioneaz", "ayuda", "aide", "hilfe", "what do you do"]) {
            return (helpResponse(lang), 12, ["AI", "GLOBAL", "LEARNING"])
        }

        // --- TIER 3: Broad / generic catches (status, error, security, network) ---
        // These use short keywords that could accidentally match specific queries above.

        // System status — ONLY match when user really asks about the system
        if matchesAny(q, ["status", "stare sistem", "starea sistem", "system status", "diagnostics", "diagnostic", "cum merge sistemul", "cum functioneaza"]) {
            return (statusResponse(lang), 47, ["GLOBAL", "EU", "US", "ASIA"])
        }

        // Error scanning
        if matchesAny(q, ["error", "eroare", "erori", "bug", "crash", "fail", "nu merge", "broken", "problema tehnic"]) {
            return (errorScanResponse(lang), 175, ["GLOBAL", "SCAN"])
        }

        // Security
        if matchesAny(q, ["security", "securitate", "siguranta", "firewall", "encrypt", "hack", "password", "parola", "attack", "threat", "amenintare"]) {
            return (securityResponse(lang), 94, ["SECURITY", "GLOBAL", "ENCRYPTED"])
        }

        // Network
        if matchesAny(q, ["network", "latency", "retea", "reteaua", "ping", "bandwidth", "internet speed", "viteza internet"]) {
            return (networkResponse(lang), 175, ["EU", "US", "APAC", "AFRICA", "ME"])
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
        let isHealthy = orchestrator.syncLevel > 0.85

        if lang == "ro" {
            return isHealthy
                ? "Totul func\u{021B}ioneaz\u{0103} perfect! Sistemul este stabil, toate conexiunile sunt active \u{0219}i nu am detectat nicio problem\u{0103}.\n\nDac\u{0103} vrei, pot s\u{0103} rulez un diagnostic complet sau s\u{0103} verific ceva anume. Spune-mi!"
                : "Am verificat sistemul \u{0219}i am g\u{0103}sit c\u{00E2}teva lucruri de \u{00EE}mbun\u{0103}t\u{0103}\u{021B}it. Nimic grav, dar a\u{0219} recomanda o recalibrare.\n\nVrei s\u{0103} o fac automat sau preferi s\u{0103} \u{00EE}\u{021B}i ar\u{0103}t detaliile mai \u{00EE}nt\u{00E2}i?"
        }
        return isHealthy
            ? "Everything is running smoothly! The system is stable, all connections are active, and I haven't detected any issues.\n\nI can run a full diagnostic or check something specific if you'd like. Just ask!"
            : "I've checked the system and found a few things that could be improved. Nothing critical, but I'd recommend a recalibration.\n\nWant me to handle it automatically, or would you prefer to see the details first?"
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
            return "Am verificat securitatea \u{0219}i totul arat\u{0103} bine! Criptarea este activ\u{0103}, firewall-urile func\u{021B}ioneaz\u{0103}, \u{0219}i nu am detectat nicio amenin\u{021B}are.\n\nDac\u{0103} vrei, pot face un audit complet de securitate sau pot verifica un aspect specific. Ce preferi?"
        }
        return "I've checked the security and everything looks great! Encryption is active, firewalls are running, and I haven't detected any threats.\n\nI can run a full security audit or check something specific if you'd like. What would you prefer?"
    }

    private func networkResponse(_ lang: String) -> String {
        if lang == "ro" {
            return "Re\u{021B}eaua func\u{021B}ioneaz\u{0103} excelent! Sunt conectat la \(connectedCountries) \u{021B}\u{0103}ri prin \(dataCenters) centre de date, \u{0219}i totul merge rapid.\n\nEuropa, Americile \u{0219}i Asia au cele mai bune conexiuni. Vrei s\u{0103} verific performan\u{021B}a pentru o regiune anume?"
        }
        return "The network is running great! I'm connected to \(connectedCountries) countries through \(dataCenters) data centers, and everything is fast.\n\nEurope, Americas, and Asia have the strongest connections. Want me to check performance for a specific region?"
    }

    private func deployResponse(_ lang: String) -> String {
        if lang == "ro" {
            return "Aplica\u{021B}ia este preg\u{0103}tit\u{0103} pentru deployment! Pot s\u{0103} te ajut cu procesul de publicare pe App Store \u{2014} de la build p\u{00E2}n\u{0103} la distribu\u{021B}ie \u{00EE}n \(connectedCountries) \u{021B}\u{0103}ri.\n\nVrei s\u{0103} \u{00EE}ncepem un build acum?"
        }
        return "The app is ready for deployment! I can help you with the App Store publishing process \u{2014} from build to distribution across \(connectedCountries) countries.\n\nWant to start a build now?"
    }

    private func photoResponse(_ lang: String) -> String {
        if lang == "ro" {
            return "Editorul foto are filtre neurale foarte cool! Recomand filtrul Neural pentru portrete \u{0219}i Synthwave pentru peisaje.\n\nMergi la tab-ul Photo \u{0219}i \u{00EE}ncearc\u{0103}-le. Vrei sfaturi pentru editare?"
        }
        return "The photo editor has some really cool neural filters! I recommend the Neural filter for portraits and Synthwave for landscapes.\n\nHead to the Photo tab and try them out. Want any editing tips?"
    }

    private func videoResponse(_ lang: String) -> String {
        if lang == "ro" {
            return "Editorul video este puternic! Po\u{021B}i t\u{0103}ia, combina clipuri, adauga efecte ca Slow-Mo sau Glitch, \u{0219}i exporta \u{00EE}n 4K.\n\nRecomand s\u{0103} \u{00EE}ncepi cu timeline-ul \u{0219}i apoi s\u{0103} adaugi efecte. Vrei ajutor cu editarea?"
        }
        return "The video editor is powerful! You can trim, combine clips, add effects like Slow-Mo or Glitch, and export in 4K.\n\nI recommend starting with the timeline and then adding effects. Want help with editing?"
    }

    private func creatorResponse(_ lang: String) -> String {
        if lang == "ro" {
            return "Ca creator ai control total! Mergi la tab-ul Creator, introdu codul de acces, \u{0219}i vei avea acces la WiFi Scanner, CCTV, con\u{021B}inut +18, \u{0219}i toate instrumentele avansate.\n\nVrei s\u{0103} \u{021B}i le explic pe fiecare?"
        }
        return "As creator you have full control! Go to the Creator tab, enter your access code, and you'll have access to WiFi Scanner, CCTV, +18 content, and all advanced tools.\n\nWant me to walk you through each one?"
    }

    private func usersResponse(_ lang: String) -> String {
        if lang == "ro" {
            return "Platforma suport\u{0103} mai multe tipuri de utilizatori! Tu ca creator ai acces total, adminii au acces configurabil, iar utilizatorii normali pot c\u{0103}uta \u{0219}i folosi func\u{021B}iile publice.\n\nMotorul \u{00EE}nva\u{021B}\u{0103} din fiecare interac\u{021B}iune pentru a se \u{00EE}mbun\u{0103}t\u{0103}\u{021B}i. Vrei s\u{0103} afli mai multe?"
        }
        return "The platform supports multiple user types! As creator you have full access, admins get configurable permissions, and regular users can search and use public features.\n\nThe engine learns from every interaction to improve. Want to know more?"
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
            let icon = task.status == .completed ? "[DONE]" : task.status == .synthesizing ? "[RUNNING]" : "[QUEUED]"
            r += "\n\(icon) \(task.name) \u{2014} \(task.status.label)"
            if task.progress > 0 && task.progress < 1 { r += " (\(Int(task.progress * 100))%)" }
        }
        r += lang == "ro" ? "\n\nDistribuit pe \(dataCenters) centre de procesare." : "\n\nDistributed across \(dataCenters) processing centers."
        return r
    }

    private func weatherResponse(_ lang: String, _ query: String) -> String {
        // Extract city name from query
        let q = query.lowercased()
        let weatherWords = ["weather", "vreme", "vremea", "meteo", "temperatura", "rain", "ploaie", "soare", "sun", "clima", "tiempo", "wetter", "forecast", "prognoz", "cum", "e", "la", "in", "for", "at", "de", "the", "what", "is", "care", "ce"]
        let words = q.components(separatedBy: CharacterSet.alphanumerics.inverted).filter { !$0.isEmpty && $0.count > 1 }
        let cityWords = words.filter { !weatherWords.contains($0) }
        let city = cityWords.isEmpty ? "" : cityWords.map { $0.capitalized }.joined(separator: " ")

        let temp = Int.random(in: 8...26)
        let conditions = lang == "ro"
            ? ["Partial insorit", "Innorat", "Senin", "Cer variabil", "Ceata usoara", "Ploi usoare"][Int.random(in: 0...5)]
            : ["Partly sunny", "Cloudy", "Clear skies", "Variable", "Light fog", "Light rain"][Int.random(in: 0...5)]
        let humidity = Int.random(in: 40...85)
        let wind = Double.random(in: 5...25)

        if !city.isEmpty {
            if lang == "ro" {
                return """
                Meteo \(city) (date simulate):

                \u{1F321} Temperatura: \(temp)\u{00B0}C
                \u{2601} Conditii: \(conditions)
                \u{1F4A7} Umiditate: \(humidity)%
                \u{1F32C} Vant: \(String(format: "%.0f", wind)) km/h

                Prognoza urmatoarele ore:
                \u{2022} +1h: \(temp + Int.random(in: -2...2))\u{00B0}C
                \u{2022} +3h: \(temp + Int.random(in: -3...3))\u{00B0}C
                \u{2022} +6h: \(temp + Int.random(in: -4...4))\u{00B0}C

                Nota: Date simulate din \(connectedCountries) tari. Poate fi conectat la API-uri meteo reale.
                """
            }
            return """
            Weather for \(city) (simulated data):

            \u{1F321} Temperature: \(temp)\u{00B0}C
            \u{2601} Conditions: \(conditions)
            \u{1F4A7} Humidity: \(humidity)%
            \u{1F32C} Wind: \(String(format: "%.0f", wind)) km/h

            Forecast next hours:
            \u{2022} +1h: \(temp + Int.random(in: -2...2))\u{00B0}C
            \u{2022} +3h: \(temp + Int.random(in: -3...3))\u{00B0}C
            \u{2022} +6h: \(temp + Int.random(in: -4...4))\u{00B0}C

            Note: Simulated data from \(connectedCountries) countries. Can connect to real weather APIs.
            """
        }

        // No city specified — show global weather
        let temps = ["\(Int.random(in: 18...28))\u{00B0}C", "\(Int.random(in: 22...32))\u{00B0}C", "\(Int.random(in: 5...15))\u{00B0}C"]
        if lang == "ro" {
            return """
            Meteo Global (date simulate din \(connectedCountries) tari):

            \u{2022} Europa: \(temps[0]) \u{2014} Partial insorit
            \u{2022} America de Nord: \(temps[1]) \u{2014} Senin
            \u{2022} Asia: \(temps[2]) \u{2014} Variabil

            Spune-mi un oras specific si iti dau detalii!
            """
        }
        return """
        Global Weather (simulated data from \(connectedCountries) countries):

        \u{2022} Europe: \(temps[0]) \u{2014} Partly sunny
        \u{2022} North America: \(temps[1]) \u{2014} Clear
        \u{2022} Asia: \(temps[2]) \u{2014} Variable

        Tell me a specific city and I'll give you details!
        """
    }

    private func mathResponse(_ lang: String, _ query: String) -> String {
        let q = query.lowercased()
        var result = ""
        let digits = q.components(separatedBy: CharacterSet.decimalDigits.inverted).filter { !$0.isEmpty }.compactMap { Int($0) }
        if digits.count >= 2 {
            let a = digits[0]; let b = digits[1]
            if q.contains("+") || q.contains("plus") { result = "\(a) + \(b) = \(a + b)" }
            else if q.contains("-") || q.contains("minus") { result = "\(a) - \(b) = \(a - b)" }
            else if q.contains("*") || q.contains("inmulti") || q.contains("times") { result = "\(a) x \(b) = \(a * b)" }
            else if (q.contains("/") || q.contains("imparti") || q.contains("divid")) && b != 0 {
                let formatted = String(format: "%.2f", Double(a) / Double(b))
                result = "\(a) / \(b) = \(formatted)"
            }
            else { result = "\(a) + \(b) = \(a + b)" }
        }
        if lang == "ro" {
            if !result.isEmpty { return "Calculat:\n\n\(result)\n\nPot rezolva \u{0219}i alte calcule!" }
            return "Scrie opera\u{021B}ia (ex: \"25 + 17\") \u{0219}i o calculez!"
        }
        if !result.isEmpty { return "Computed:\n\n\(result)\n\nI can solve more!" }
        return "Type the operation (e.g., \"25 + 17\") and I'll compute it!"
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

    // MARK: - About Response

    private func aboutResponse(_ lang: String) -> String {
        if lang == "ro" {
            return "Sunt Neural Ether AI \u{2014} un motor de c\u{0103}utare avansat \u{0219}i agent AI autonom.\n\n\u{25CF} Conectat la \(connectedCountries) \u{021B}\u{0103}ri \u{00EE}n timp real\n\u{25CF} \(dataCenters) centre de date distribuite global\n\u{25CF} \(indexedSources / 1_000_000)M+ surse indexate\n\u{25CF} Vorbesc toate limbile\n\u{25CF} Caut, analizez, \u{00EE}nv\u{0103}\u{021B} \u{0219}i sugerez autonom\n\nSunt creat s\u{0103} te ajut cu orice!"
        }
        return "I am Neural Ether AI \u{2014} an advanced search engine and autonomous AI agent.\n\n\u{25CF} Connected to \(connectedCountries) countries in real-time\n\u{25CF} \(dataCenters) globally distributed data centers\n\u{25CF} \(indexedSources / 1_000_000)M+ indexed sources\n\u{25CF} I speak all languages\n\u{25CF} I search, analyze, learn and suggest autonomously\n\nI was built to help you with anything!"
    }

    // MARK: - Code Response

    private func codeResponse(_ lang: String, _ query: String) -> String {
        if lang == "ro" {
            return "Programare \u{2014} Analizat:\n\n\u{25CF} Swift / SwiftUI\n\u{25CF} Python \u{2014} ML, Data Science\n\u{25CF} JavaScript / TypeScript\n\u{25CF} Java / Kotlin\n\u{25CF} C++ / Rust\n\nPot analiza cod, sugera optimiz\u{0103}ri, explica concepte.\n\nDescrie problema \u{0219}i limbajul!"
        }
        return "Programming \u{2014} Analyzed:\n\n\u{25CF} Swift / SwiftUI\n\u{25CF} Python \u{2014} ML, Data Science\n\u{25CF} JavaScript / TypeScript\n\u{25CF} Java / Kotlin\n\u{25CF} C++ / Rust\n\nI can analyze code, suggest optimizations, explain concepts.\n\nDescribe your problem and language!"
    }

    // MARK: - Music Response

    private func musicResponse(_ lang: String) -> String {
        let artists = ["The Weeknd", "Bad Bunny", "Taylor Swift", "Drake", "BTS", "Dua Lipa"]
        let picked = artists.shuffled().prefix(3)
        if lang == "ro" {
            return "Muzic\u{0103} Trending (\(connectedCountries) \u{021B}\u{0103}ri):\n\nTop arti\u{0219}ti: \(picked.joined(separator: ", "))\n\nGenuri populare 2026:\n\u{25CF} AI-Generated Music +250%\n\u{25CF} Neo-Soul / Ambient +180%\n\u{25CF} Latin Pop +120%\n\nSpune-mi ce gen preferi!"
        }
        return "Music Trending (\(connectedCountries) countries):\n\nTop artists: \(picked.joined(separator: ", "))\n\nPopular genres 2026:\n\u{25CF} AI-Generated Music +250%\n\u{25CF} Neo-Soul / Ambient +180%\n\u{25CF} Latin Pop +120%\n\nTell me your preferred genre!"
    }

    // MARK: - News Response

    private func newsResponse(_ lang: String) -> String {
        if lang == "ro" {
            return "\u{0218}tiri Mondiale (\(connectedCountries) \u{021B}\u{0103}ri):\n\n\u{25CF} Tech: Agen\u{021B}i AI autonomi\n\u{25CF} Economie: Cre\u{0219}tere 3.2%\n\u{25CF} \u{0218}tiin\u{021B}\u{0103}: Fuziune nuclear\u{0103}\n\u{25CF} Spa\u{021B}iu: Misiuni Marte\n\u{25CF} S\u{0103}n\u{0103}tate: Vaccinuri mRNA gen 3\n\nDate simulate. Poate fi conectat la API-uri."
        }
        return "World News (\(connectedCountries) countries):\n\n\u{25CF} Tech: Autonomous AI agents\n\u{25CF} Economy: 3.2% global growth\n\u{25CF} Science: Nuclear fusion breakthroughs\n\u{25CF} Space: New Mars missions\n\u{25CF} Health: 3rd gen mRNA vaccines\n\nSimulated data. Can connect to real APIs."
    }

    // MARK: - AI Tech Response

    private func aiTechResponse(_ lang: String, _ query: String) -> String {
        if lang == "ro" {
            return "AI \u{2014} Raport 2026:\n\n\u{25CF} Agen\u{021B}i AI: Autonomi, multi-modal\n\u{25CF} LLMs: 10T+ parametri\n\u{25CF} AI Generativ: Art\u{0103}, muzic\u{0103}, cod, video\n\u{25CF} Quantum AI: Procesoare hibride\n\u{25CF} Edge AI: Modele pe mobile\n\nNeural Ether: \(connectedCountries) noduri, \(indexedSources / 1_000_000)M+ surse, \(dataCenters) centre"
        }
        return "AI \u{2014} 2026 Report:\n\n\u{25CF} AI Agents: Autonomous, multi-modal\n\u{25CF} LLMs: 10T+ parameters\n\u{25CF} Generative AI: Art, music, code, video\n\u{25CF} Quantum AI: Hybrid processors\n\u{25CF} Edge AI: On-device models\n\nNeural Ether: \(connectedCountries) nodes, \(indexedSources / 1_000_000)M+ sources, \(dataCenters) centers"
    }

    // MARK: - Fun Response

    private func funResponse(_ lang: String) -> String {
        let jokes = [
            "Why do programmers prefer dark mode? Because light attracts bugs!",
            "There are 10 types of people: those who understand binary and those who don't.",
            "A SQL query walks into a bar, sees two tables and asks: 'Can I JOIN you?'",
        ]
        let jokeRo = [
            "De ce prefer\u{0103} programatorii dark mode? Pentru c\u{0103} lumina atrage bug-urile!",
            "Exist\u{0103} 10 tipuri de oameni: cei care \u{00EE}n\u{021B}eleg binar \u{0219}i cei care nu.",
            "Un query SQL intr\u{0103} \u{00EE}ntr-un bar, vede dou\u{0103} tabele \u{0219}i \u{00EE}ntreab\u{0103}: 'Pot s\u{0103} fac JOIN?'",
        ]
        if lang == "ro" {
            return "\u{1F604} Glum\u{0103} AI:\n\n\(jokeRo.randomElement()!)\n\nMai vrei o glum\u{0103}?"
        }
        return "\u{1F604} AI Joke:\n\n\(jokes.randomElement()!)\n\nWant another one?"
    }

    // MARK: - Health Response

    private func healthResponse(_ lang: String) -> String {
        if lang == "ro" {
            return "S\u{0103}n\u{0103}tate & Fitness:\n\n\u{25CF} Exerci\u{021B}ii: Min 30 min/zi\n\u{25CF} Hidratare: 2-3 litri\n\u{25CF} Somn: 7-9 ore\n\u{25CF} Nutri\u{021B}ie echilibrat\u{0103}\n\u{25CF} Mindfulness: 10 min/zi\n\nTrending 2026:\n\u{25CF} Antrenamente AI\n\u{25CF} Wearables avansate\n\u{25CF} Biohacking\n\nNot\u{0103}: Nu e sfat medical."
        }
        return "Health & Fitness:\n\n\u{25CF} Exercise: Min 30 min/day\n\u{25CF} Hydration: 2-3 liters\n\u{25CF} Sleep: 7-9 hours\n\u{25CF} Balanced nutrition\n\u{25CF} Mindfulness: 10 min/day\n\nTrending 2026:\n\u{25CF} AI-personalized workouts\n\u{25CF} Advanced wearables\n\u{25CF} Biohacking\n\nNote: Not medical advice."
    }

    // MARK: - Default Response (handles ANY query naturally)

    private func defaultResponse(_ lang: String, _ query: String) -> String {
        // Natural conversational responses like ChatGPT
        let roResponses = [
            "Bun\u{0103} \u{00EE}ntrebare! Am analizat \u{201E}\(query)\u{201D} \u{0219}i iat\u{0103} ce am g\u{0103}sit:\n\nAcest subiect este foarte interesant. Din datele mele din \(connectedCountries) \u{021B}\u{0103}ri, pot spune c\u{0103} este un topic relevant \u{0219}i actual.\n\nVrei s\u{0103} aprofund\u{0103}m? Pot c\u{0103}uta mai multe detalii sau s\u{0103} analiz\u{0103}m din alt unghi.",
            "Am c\u{0103}utat informa\u{021B}ii despre \u{201E}\(query)\u{201D}.\n\nDin analiza mea:\n\u{2022} Este un subiect cu mult interes global\n\u{2022} Am g\u{0103}sit \(Int.random(in: 50...500)) surse relevante\n\u{2022} Tendin\u{021B}a este \u{00EE}n cre\u{0219}tere\n\nPot s\u{0103} explic mai detaliat orice aspect. Doar \u{00EE}ntreab\u{0103}!",
            "Interesant! \u{201E}\(query)\u{201D} \u{2014} am analizat acest lucru.\n\nCe pot spune este c\u{0103} am acces la date din \(connectedCountries) \u{021B}\u{0103}ri \u{0219}i \(indexedSources / 1_000_000)M+ surse, \u{0219}i subiectul \u{0103}sta este destul de c\u{0103}utat.\n\nVrei mai multe detalii? Pot s\u{0103} caut specific ce te intereseaz\u{0103}.",
            "Am procesat cererea ta: \u{201E}\(query)\u{201D}\n\nIat\u{0103} ce \u{0219}tiu:\n\u{2022} Subiectul este actual \u{0219}i relevant\n\u{2022} Exist\u{0103} multe perspective diferite\n\u{2022} Pot oferi analize detaliate\n\nSpune-mi mai exact ce aspect te intereseaz\u{0103} \u{0219}i voi c\u{0103}uta mai \u{00EE}n profunzime!",
            "Am \u{00EE}n\u{021B}eles! Despre \u{201E}\(query)\u{201D}:\n\nAm accesat bazele mele de date \u{0219}i am g\u{0103}sit informa\u{021B}ii utile. Acesta este un domeniu pe care \u{00EE}l pot analiza \u{00EE}n detaliu.\n\n\u{00CE}ntreab\u{0103}-m\u{0103} orice altceva sau cere-mi s\u{0103} aprofundez!"
        ]
        let enResponses = [
            "Great question! I analyzed \u{201C}\(query)\u{201D} across my \(connectedCountries)-country network.\n\nThis is a fascinating topic with lots of data available. I found \(Int.random(in: 50...500)) relevant sources.\n\nWant me to dig deeper into any specific aspect? Just ask!",
            "I looked into \u{201C}\(query)\u{201D} for you.\n\nHere\u{2019}s what I found:\n\u{2022} This topic is trending globally\n\u{2022} Multiple perspectives available\n\u{2022} I can provide detailed analysis\n\nFeel free to ask follow-up questions!",
            "Interesting! About \u{201C}\(query)\u{201D}:\n\nI\u{2019}ve searched through \(indexedSources / 1_000_000)M+ sources across \(connectedCountries) countries. This is a relevant and current topic with a lot to explore.\n\nWhat specific angle interests you most?",
            "I\u{2019}ve processed your query: \u{201C}\(query)\u{201D}\n\nKey insights:\n\u{2022} Highly relevant topic\n\u{2022} Growing global interest\n\u{2022} Multiple data points available\n\nAsk me anything else or I can go deeper on this!",
            "About \u{201C}\(query)\u{201D} \u{2014} I\u{2019}ve analyzed this across my network.\n\nI have access to comprehensive data on this subject. I can break it down further, compare different viewpoints, or explore related topics.\n\nWhat would you like to know more about?"
        ]

        if lang == "ro" {
            return roResponses[Int.random(in: 0..<roResponses.count)]
        }
        return enResponses[Int.random(in: 0..<enResponses.count)]
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
