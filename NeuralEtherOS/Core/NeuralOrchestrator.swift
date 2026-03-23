import SwiftUI
import Combine

// MARK: - Neural Orchestrator (Central State Management)
// The single source of truth for the Neural Ether OS application.

@MainActor
class NeuralOrchestrator: ObservableObject {

    // MARK: - Singleton
    static let shared = NeuralOrchestrator()

    // MARK: - Published State

    /// Overall neural sync level (0.0 – 1.0)
    @Published var syncLevel: Double = 0.924

    /// Whether panic/lockdown mode is active
    @Published var isPanicActive: Bool = false

    /// Number of active neural nodes (countries/regions)
    @Published var activeNodes: Int = 175

    /// Hyper-growth multiplier
    @Published var growthRate: Int = 10_000

    /// Network latency in milliseconds
    @Published var latency: Double = 0.02

    /// Creative Forge task states
    @Published var forgeTasks: [ForgeTask] = ForgeTask.defaults

    /// System log entries
    @Published var systemLogs: [LogEntry] = LogEntry.sampleLogs

    /// Deployment progress (0.0 – 1.0)
    @Published var deploymentProgress: Double = 0.0

    /// Deployment status
    @Published var deploymentStatus: DeploymentStatus = .idle

    /// Learning confidence scores per module
    @Published var confidenceScores: [String: Double] = [
        "NEURAL_SYNC": 0.924,
        "PATTERN_RECOGNITION": 0.78,
        "CREATIVE_SYNTHESIS": 0.65,
        "SECURITY_INTEGRITY": 0.99,
        "DEPLOYMENT_READINESS": 0.42
    ]

    // MARK: - Timers
    private var simulationTimer: AnyCancellable?

    // MARK: - Init

    private init() {
        startSimulation()
    }

    // MARK: - Simulation (Demo Data Animation)

    func startSimulation() {
        simulationTimer = Timer.publish(every: 2.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    private func tick() {
        guard !isPanicActive else { return }

        // Fluctuate sync level slightly
        let delta = Double.random(in: -0.005...0.008)
        syncLevel = min(1.0, max(0.0, syncLevel + delta))
        confidenceScores["NEURAL_SYNC"] = syncLevel

        // Fluctuate active nodes
        activeNodes += Int.random(in: -2...3)
        activeNodes = max(100, activeNodes)

        // Fluctuate latency
        latency = max(0.01, latency + Double.random(in: -0.005...0.005))

        // Random confidence updates
        for key in confidenceScores.keys {
            if let current = confidenceScores[key] {
                let change = Double.random(in: -0.01...0.015)
                confidenceScores[key] = min(1.0, max(0.0, current + change))
            }
        }

        // Add occasional log entry
        if Int.random(in: 0...4) == 0 {
            let newLog = LogEntry.randomLog()
            systemLogs.insert(newLog, at: 0)
            if systemLogs.count > 100 {
                systemLogs.removeLast()
            }
        }
    }

    // MARK: - Actions

    /// Activate panic protocol — lock system and wipe sensitive data
    func activatePanicProtocol() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isPanicActive = true
        }
        simulationTimer?.cancel()

        // Reset all sensitive data
        forgeTasks = forgeTasks.map { task in
            var t = task
            t.status = .locked
            return t
        }
        deploymentStatus = .locked
        deploymentProgress = 0.0

        // Add panic log
        systemLogs.insert(
            LogEntry(
                timestamp: Date(),
                level: .critical,
                module: "SECURITY",
                message: "PANIC_PROTOCOL_ACTIVATED — All systems locked. Data purge initiated."
            ),
            at: 0
        )
    }

    /// Deactivate panic protocol and resume normal operations
    func deactivatePanicProtocol() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isPanicActive = false
        }
        forgeTasks = ForgeTask.defaults
        deploymentStatus = .idle
        startSimulation()

        systemLogs.insert(
            LogEntry(
                timestamp: Date(),
                level: .warning,
                module: "SECURITY",
                message: "PANIC_PROTOCOL_DEACTIVATED — Systems resuming normal operation."
            ),
            at: 0
        )
    }

    /// Start a creative forge synthesis task
    func startForgeTask(id: String) {
        guard let index = forgeTasks.firstIndex(where: { $0.id == id }) else { return }
        forgeTasks[index].status = .synthesizing
        forgeTasks[index].progress = 0.0

        // Simulate progress
        Task {
            for step in 1...20 {
                try? await Task.sleep(nanoseconds: 200_000_000) // 0.2s
                forgeTasks[index].progress = Double(step) / 20.0
            }
            forgeTasks[index].status = .completed
            forgeTasks[index].progress = 1.0

            systemLogs.insert(
                LogEntry(
                    timestamp: Date(),
                    level: .info,
                    module: "FORGE",
                    message: "SYNTHESIS_COMPLETE: \(forgeTasks[index].name)"
                ),
                at: 0
            )
        }
    }

    /// Start IPA build and deployment simulation
    func startDeployment() {
        deploymentStatus = .building
        deploymentProgress = 0.0

        systemLogs.insert(
            LogEntry(
                timestamp: Date(),
                level: .info,
                module: "DEPLOY",
                message: "IPA_BUILD_STARTED — Compiling stable release..."
            ),
            at: 0
        )

        Task {
            // Build phase (0% – 60%)
            for step in 1...12 {
                try? await Task.sleep(nanoseconds: 300_000_000)
                deploymentProgress = Double(step) / 20.0
            }

            deploymentStatus = .uploading
            systemLogs.insert(
                LogEntry(
                    timestamp: Date(),
                    level: .info,
                    module: "DEPLOY",
                    message: "IPA_BUILD_COMPLETE — Uploading to App Store Connect..."
                ),
                at: 0
            )

            // Upload phase (60% – 100%)
            for step in 13...20 {
                try? await Task.sleep(nanoseconds: 250_000_000)
                deploymentProgress = Double(step) / 20.0
            }

            deploymentStatus = .submitted
            deploymentProgress = 1.0

            systemLogs.insert(
                LogEntry(
                    timestamp: Date(),
                    level: .info,
                    module: "DEPLOY",
                    message: "APP_STORE_SUBMISSION_COMPLETE — Awaiting review."
                ),
                at: 0
            )
        }
    }
}

// MARK: - Data Models

struct ForgeTask: Identifiable {
    let id: String
    let name: String
    let icon: String
    var status: ForgeTaskStatus
    var progress: Double

    enum ForgeTaskStatus: Equatable {
        case idle, synthesizing, completed, locked

        var label: String {
            switch self {
            case .idle: return "READY"
            case .synthesizing: return "SYNTHESIZING"
            case .completed: return "COMPLETE"
            case .locked: return "LOCKED"
            }
        }
    }

    static let defaults: [ForgeTask] = [
        ForgeTask(id: "code", name: "APP_CODE_GEN", icon: "chevron.left.forwardslash.chevron.right", status: .idle, progress: 0),
        ForgeTask(id: "video", name: "CINEMATIC_VIDEO", icon: "film", status: .idle, progress: 0),
        ForgeTask(id: "assets", name: "NEURAL_ASSETS", icon: "paintbrush", status: .idle, progress: 0),
        ForgeTask(id: "audio", name: "SONIC_SYNTHESIS", icon: "waveform", status: .idle, progress: 0),
        ForgeTask(id: "model", name: "3D_MODEL_GEN", icon: "cube", status: .idle, progress: 0)
    ]
}

enum DeploymentStatus: Equatable {
    case idle, building, uploading, submitted, locked

    var label: String {
        switch self {
        case .idle: return "STANDING_BY"
        case .building: return "BUILDING_IPA"
        case .uploading: return "UPLOADING"
        case .submitted: return "SUBMITTED"
        case .locked: return "LOCKED"
        }
    }

    var color: Color {
        switch self {
        case .idle: return .onSurfaceVariant
        case .building: return .neuralPrimary
        case .uploading: return .neuralWarning
        case .submitted: return .neuralSuccess
        case .locked: return .neuralError
        }
    }
}

struct LogEntry: Identifiable {
    let id = UUID()
    let timestamp: Date
    let level: LogLevel
    let module: String
    let message: String

    enum LogLevel: String {
        case info = "INFO"
        case warning = "WARN"
        case error = "ERROR"
        case critical = "CRIT"

        var color: Color {
            switch self {
            case .info: return .neuralPrimary
            case .warning: return .neuralWarning
            case .error: return .neuralError
            case .critical: return .neuralError
            }
        }
    }

    var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter.string(from: timestamp)
    }

    static let sampleLogs: [LogEntry] = [
        LogEntry(timestamp: Date(), level: .info, module: "CORE", message: "NEURAL_ETHER_OS initialized. All systems nominal."),
        LogEntry(timestamp: Date().addingTimeInterval(-2), level: .info, module: "SYNC", message: "Sync level stabilized at 92.4%"),
        LogEntry(timestamp: Date().addingTimeInterval(-5), level: .warning, module: "NET", message: "Latency spike detected: 0.04ms → recalibrating..."),
        LogEntry(timestamp: Date().addingTimeInterval(-8), level: .info, module: "FORGE", message: "Creative engine ready. 5 synthesis modules online."),
        LogEntry(timestamp: Date().addingTimeInterval(-12), level: .info, module: "DEPLOY", message: "Deployment hub connected to App Store Connect API."),
        LogEntry(timestamp: Date().addingTimeInterval(-15), level: .info, module: "SECURITY", message: "Quantum encryption layer active. Panic protocol armed."),
    ]

    static func randomLog() -> LogEntry {
        let messages: [(LogLevel, String, String)] = [
            (.info, "SYNC", "Node heartbeat received. \(Int.random(in: 170...180)) nodes active."),
            (.info, "NET", "Packet routing optimized. Latency: \(String(format: "%.2f", Double.random(in: 0.01...0.05)))ms"),
            (.warning, "CORE", "Memory allocation peak detected — auto-balancing..."),
            (.info, "FORGE", "Pattern cache updated. \(Int.random(in: 1000...9999)) templates indexed."),
            (.info, "SYNC", "Confidence vector recalculated across all modules."),
            (.warning, "NET", "Route \(Int.random(in: 1...255)).\(Int.random(in: 0...255)) experiencing jitter. Rerouting..."),
            (.info, "CORE", "Hyper-growth velocity: \(Int.random(in: 9500...10500))x"),
        ]
        let entry = messages.randomElement()!
        return LogEntry(
            timestamp: Date(),
            level: entry.0,
            module: entry.1,
            message: entry.2
        )
    }
}
