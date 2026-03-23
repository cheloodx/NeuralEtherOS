import SwiftUI

// MARK: - App Entry Point
// Neural Ether OS — Cyber-Dystopian / Neural Ether (Dark Mode Only)
// Bundle ID: com.creator.neuralether.os
// Platform: iOS 17.0+

@main
struct NeuralEtherApp: App {
    @StateObject private var orchestrator = NeuralOrchestrator.shared

    var body: some Scene {
        WindowGroup {
            MainContainerView()
                .environmentObject(orchestrator)
                .preferredColorScheme(.dark)
        }
    }
}
