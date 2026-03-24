import SwiftUI

// MARK: - Neural Search View
// ChatGPT-style search interface for querying system logs, modules, and processes.

struct NeuralSearchView: View {
    @EnvironmentObject var orchestrator: NeuralOrchestrator
    @State private var searchQuery: String = ""
    @State private var searchResults: [SearchResult] = []
    @State private var isSearching: Bool = false
    @State private var searchHistory: [String] = [
        "NODE_STATUS",
        "LATENCY_REPORT",
        "SYNC_LEVEL",
        "PANIC_PROTOCOL"
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xxl) {
                headerSection
                searchBarSection
                if !searchQuery.isEmpty {
                    resultsSection
                } else {
                    suggestionsSection
                    recentSection
                }
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.top, Spacing.xxl)
            .padding(.bottom, Spacing.massive)
        }
        .background(Color.surface)
        .onChange(of: searchQuery) { _, newValue in
            performSearch(query: newValue)
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("NEURAL_SEARCH")
                .font(NeuralFont.displaySmall())
                .foregroundColor(.onSurface)

            Text("Query the Neural Ether — logs, modules, processes, and system state.")
                .font(NeuralFont.bodyMedium())
                .foregroundColor(.onSurfaceVariant)
        }
    }

    // MARK: - Search Bar

    private var searchBarSection: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 18))
                .foregroundColor(searchQuery.isEmpty ? .onSurfaceVariant : .neuralPrimary)

            TextField("", text: $searchQuery, prompt: searchPrompt)
                .font(NeuralFont.bodyMedium())
                .foregroundColor(.onSurface)
                .textFieldStyle(PlainTextFieldStyle())
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)

            if !searchQuery.isEmpty {
                Button {
                    searchQuery = ""
                    searchResults = []
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.onSurfaceVariant)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.lg)
        .background(Color.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.xl))
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.xl)
                .stroke(
                    searchQuery.isEmpty
                        ? Color.outlineVariant.opacity(0.15)
                        : Color.neuralPrimary.opacity(0.5),
                    lineWidth: 1
                )
        )
        .neuralAmbientShadow()
    }

    private var searchPrompt: Text {
        Text("ASK_NEURAL_ETHER...")
            .foregroundColor(.onSurfaceVariant.opacity(0.5))
    }

    // MARK: - Results

    private var resultsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            HStack {
                Text("RESULTS")
                    .font(NeuralFont.monoSmall())
                    .foregroundColor(.onSurfaceVariant)
                    .tracking(1.5)

                Spacer()

                Text("\(searchResults.count) FOUND")
                    .font(NeuralFont.monoSmall())
                    .foregroundColor(.neuralPrimary)
                    .tracking(1.0)
            }

            if searchResults.isEmpty {
                noResultsView
            } else {
                ForEach(searchResults) { result in
                    searchResultCard(result)
                }
            }
        }
    }

    private var noResultsView: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
                .foregroundColor(.onSurfaceVariant.opacity(0.3))

            Text("NO_MATCHES_FOUND")
                .font(NeuralFont.monoMedium())
                .foregroundColor(.onSurfaceVariant)

            Text("Try a different query or browse suggestions below.")
                .font(NeuralFont.bodySmall())
                .foregroundColor(.onSurfaceVariant.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.huge)
    }

    private func searchResultCard(_ result: SearchResult) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Image(systemName: result.icon)
                    .font(.system(size: 14))
                    .foregroundColor(result.categoryColor)

                Text(result.category)
                    .font(NeuralFont.monoSmall())
                    .foregroundColor(result.categoryColor)
                    .tracking(1.0)

                Spacer()

                if let timestamp = result.timestamp {
                    Text(timestamp)
                        .font(NeuralFont.monoSmall())
                        .foregroundColor(.onSurfaceVariant.opacity(0.5))
                }
            }

            Text(result.title)
                .font(NeuralFont.headlineSmall())
                .foregroundColor(.onSurface)

            Text(result.detail)
                .font(NeuralFont.monoMedium())
                .foregroundColor(.onSurfaceVariant)
                .lineLimit(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.lg)
        .glassmorphism(cornerRadius: CornerRadius.lg)
    }

    // MARK: - Suggestions

    private var suggestionsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Text("SUGGESTIONS")
                .font(NeuralFont.monoSmall())
                .foregroundColor(.onSurfaceVariant)
                .tracking(1.5)

            let suggestions = [
                ("brain.head.profile", "System Status", "NEURAL_STATUS"),
                ("bolt.fill", "Active Processes", "FORGE_TASKS"),
                ("lock.shield", "Security Overview", "SECURITY_STATE"),
                ("chart.bar", "Confidence Vectors", "CONFIDENCE"),
                ("network", "Network Latency", "LATENCY"),
                ("exclamationmark.triangle", "Error Logs", "ERROR_LOGS")
            ]

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: Spacing.md),
                GridItem(.flexible(), spacing: Spacing.md)
            ], spacing: Spacing.md) {
                ForEach(Array(suggestions.enumerated()), id: \.offset) { _, suggestion in
                    Button {
                        searchQuery = suggestion.2
                    } label: {
                        HStack(spacing: Spacing.sm) {
                            Image(systemName: suggestion.0)
                                .font(.system(size: 14))
                                .foregroundColor(.neuralPrimary)

                            Text(suggestion.1)
                                .font(NeuralFont.bodySmall())
                                .foregroundColor(.onSurface)
                                .lineLimit(1)

                            Spacer()
                        }
                        .padding(.horizontal, Spacing.md)
                        .padding(.vertical, Spacing.md)
                        .background(Color.surfaceContainerLow)
                        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Recent

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Text("RECENT_QUERIES")
                .font(NeuralFont.monoSmall())
                .foregroundColor(.onSurfaceVariant)
                .tracking(1.5)

            ForEach(searchHistory, id: \.self) { query in
                Button {
                    searchQuery = query
                } label: {
                    HStack(spacing: Spacing.md) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 14))
                            .foregroundColor(.onSurfaceVariant.opacity(0.5))

                        Text(query)
                            .font(NeuralFont.monoMedium())
                            .foregroundColor(.onSurfaceVariant)

                        Spacer()

                        Image(systemName: "arrow.up.left")
                            .font(.system(size: 12))
                            .foregroundColor(.onSurfaceVariant.opacity(0.3))
                    }
                    .padding(.vertical, Spacing.sm)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Search Logic

    private func performSearch(query: String) {
        guard !query.isEmpty else {
            searchResults = []
            return
        }

        let q = query.lowercased()
        var results: [SearchResult] = []

        // Search logs
        for log in orchestrator.systemLogs {
            if log.message.lowercased().contains(q) || log.module.lowercased().contains(q) {
                results.append(SearchResult(
                    category: "LOG",
                    icon: "doc.text",
                    categoryColor: log.level.color,
                    title: "[\(log.level.rawValue)] \(log.module)",
                    detail: log.message,
                    timestamp: log.formattedTimestamp
                ))
            }
        }

        // Search forge tasks
        for task in orchestrator.forgeTasks {
            if task.name.lowercased().contains(q) || task.id.lowercased().contains(q) {
                results.append(SearchResult(
                    category: "FORGE",
                    icon: "bolt.fill",
                    categoryColor: .neuralTertiary,
                    title: task.name,
                    detail: "Status: \(task.status.label) | Progress: \(Int(task.progress * 100))%",
                    timestamp: nil
                ))
            }
        }

        // Search confidence scores
        for (key, value) in orchestrator.confidenceScores {
            if key.lowercased().contains(q) || q.contains("confidence") {
                results.append(SearchResult(
                    category: "METRIC",
                    icon: "chart.bar",
                    categoryColor: .neuralPrimary,
                    title: key,
                    detail: "Confidence: \(String(format: "%.1f", value * 100))%",
                    timestamp: nil
                ))
            }
        }

        // Search system state keywords
        if q.contains("status") || q.contains("neural") || q.contains("system") {
            results.append(SearchResult(
                category: "SYSTEM",
                icon: "brain.head.profile",
                categoryColor: .neuralSuccess,
                title: "NEURAL_ETHER_STATUS",
                detail: "Sync: \(String(format: "%.1f", orchestrator.syncLevel * 100))% | Nodes: \(orchestrator.activeNodes) | Latency: \(String(format: "%.2f", orchestrator.latency))ms",
                timestamp: nil
            ))
        }

        if q.contains("latency") || q.contains("network") || q.contains("net") {
            results.append(SearchResult(
                category: "NETWORK",
                icon: "network",
                categoryColor: .neuralWarning,
                title: "NETWORK_LATENCY",
                detail: "Current: \(String(format: "%.2f", orchestrator.latency))ms | Nodes: \(orchestrator.activeNodes) active",
                timestamp: nil
            ))
        }

        if q.contains("security") || q.contains("panic") || q.contains("vault") {
            results.append(SearchResult(
                category: "SECURITY",
                icon: "lock.shield",
                categoryColor: orchestrator.isPanicActive ? .neuralError : .neuralSuccess,
                title: "SECURITY_STATE",
                detail: orchestrator.isPanicActive ? "PANIC_PROTOCOL_ACTIVE — All systems locked." : "All systems nominal. Quantum encryption active.",
                timestamp: nil
            ))
        }

        if q.contains("deploy") || q.contains("build") || q.contains("ipa") {
            results.append(SearchResult(
                category: "DEPLOY",
                icon: "shippingbox",
                categoryColor: orchestrator.deploymentStatus.color,
                title: "DEPLOYMENT_STATUS",
                detail: "Status: \(orchestrator.deploymentStatus.label) | Progress: \(Int(orchestrator.deploymentProgress * 100))%",
                timestamp: nil
            ))
        }

        if q.contains("error") || q.contains("warn") {
            let errorLogs = orchestrator.systemLogs.filter { $0.level == .error || $0.level == .warning || $0.level == .critical }
            for log in errorLogs.prefix(5) {
                results.append(SearchResult(
                    category: "ALERT",
                    icon: "exclamationmark.triangle",
                    categoryColor: log.level.color,
                    title: "[\(log.level.rawValue)] \(log.module)",
                    detail: log.message,
                    timestamp: log.formattedTimestamp
                ))
            }
        }

        searchResults = results

        // Add to history if not already there
        if !query.isEmpty && !searchHistory.contains(query.uppercased()) {
            searchHistory.insert(query.uppercased(), at: 0)
            if searchHistory.count > 8 {
                searchHistory.removeLast()
            }
        }
    }
}

// MARK: - Search Result Model

struct SearchResult: Identifiable {
    let id = UUID()
    let category: String
    let icon: String
    let categoryColor: Color
    let title: String
    let detail: String
    let timestamp: String?
}

#Preview {
    NeuralSearchView()
        .environmentObject(NeuralOrchestrator.shared)
}
