# Neural Ether OS

**A Cyber-Dystopian iOS Application built with SwiftUI**

Bundle ID: `com.creator.neuralether.os`
Platform: iOS 17.0+ (SwiftUI, Dark Mode Only)

---

## Overview

Neural Ether OS is a futuristic, dark-mode-only iOS application that visualizes an AI agent's neural growth, creative synthesis capabilities, quantum security, and deployment pipeline. The design follows the **"Living Lab"** aesthetic — a high-fidelity, transparent environment where data breathes.

---

## Project Structure

```
NeuralEtherOS/
├── App/
│   └── NeuralEtherApp.swift              # @main entry point
├── Core/
│   ├── NeuralOrchestrator.swift           # Central state management (ObservableObject)
│   └── MainContainerView.swift            # Root TabView navigation
├── DesignSystem/
│   ├── DesignTokens.swift                 # Colors, gradients, spacing, corner radius, shadows
│   ├── Typography.swift                   # Font system (Space Grotesk, Inter, JetBrains Mono)
│   ├── GlassmorphismModifier.swift        # Glass effects, ghost borders, surface cards
│   ├── NeuralButtonStyle.swift            # Primary, Secondary, Ghost, Danger button styles
│   └── NeuralTrace.swift                  # Custom progress visualization with gradient glow
├── Components/
│   ├── CircularProgressView.swift         # Animated ring with gradient fill
│   ├── StatBox.swift                      # Compact metric display
│   ├── InsightCard.swift                  # Glass card with no dividers (DESIGN.md spec)
│   ├── GhostTextField.swift               # Bottom-border input with focus glow
│   ├── ProcessChip.swift                  # Pill-shaped status chips
│   └── LogListView.swift                  # Alternating-row log display (monospaced)
├── Modules/
│   ├── Dashboard/
│   │   └── DashboardView.swift            # Sovereign Hub — sync ring, stats, confidence, logs
│   ├── CreativeForge/
│   │   └── CreativeForgeView.swift        # AI synthesis — code, video, assets, audio, 3D
│   ├── SecurityVault/
│   │   └── SecurityVaultView.swift        # Quantum security & panic protocol
│   └── DeploymentHub/
│       └── DeploymentHubView.swift        # IPA build pipeline & App Store submission
├── Extensions/
│   └── Color+Hex.swift                    # Color(hex:) initializer
└── Resources/
    └── (Add custom fonts here)
```

---

## Setup Instructions

### 1. Create Xcode Project
1. Open Xcode 15+ and create a new **iOS App** project
2. Set Product Name: `NeuralEtherOS`
3. Set Bundle Identifier: `com.creator.neuralether.os`
4. Set Interface: **SwiftUI**, Language: **Swift**
5. Set Minimum Deployment: **iOS 17.0**

### 2. Add Source Files
1. Delete the auto-generated `ContentView.swift`
2. Copy all `.swift` files from this project into the Xcode project, preserving the folder structure as Groups

### 3. Add Custom Fonts (Optional but Recommended)
To match the design specification fully, add these fonts:
- **Space Grotesk** (Bold, SemiBold, Medium) — [Google Fonts](https://fonts.google.com/specimen/Space+Grotesk)
- **Inter** (Regular, Medium) — [Google Fonts](https://fonts.google.com/specimen/Inter)
- **JetBrains Mono** (Regular) — [JetBrains](https://www.jetbrains.com/lp/mono/)

Steps:
1. Download the `.ttf` or `.otf` files
2. Add them to the `Resources/` folder in Xcode
3. Add font file names to `Info.plist` under `Fonts provided by application` (UIAppFonts)

> **Note:** The app will gracefully fall back to system fonts if custom fonts are not installed.

### 4. Build & Run
- Select an iPhone 15 Pro simulator (or any iOS 17+ device)
- Build and run (⌘R)

---

## Design System

The UI follows the **"The Cognitive Layer"** design specification (see `DESIGN.md`):

- **Surface Hierarchy:** Layers of "Polarized Glass" — `#0A0E17` → `#0F131D` → `#202633`
- **No-Line Rule:** No 1px borders for sectioning; boundaries defined by color shifts
- **Glassmorphism:** Floating panels use 60% opacity + backdrop blur
- **Primary Gradient:** `#00CFFC` → `#69DAFF` at 135° for primary actions
- **Typography:** Editorial headlines (Space Grotesk) + functional body (Inter) + monospaced logs (JetBrains Mono)
- **Neural Trace:** Custom 2px gradient line that glows brighter with confidence

---

## Modules

### 1. Sovereign Hub (Dashboard)
- Live circular sync ring with animated gradient
- Real-time stats (nodes, velocity, latency)
- Confidence vector traces for all modules
- Live system log feed

### 2. Creative Forge
- AI synthesis tasks (Code, Video, Assets, Audio, 3D)
- Animated progress per task
- Search/filter capabilities
- Forge metrics insight card

### 3. Security Vault
- Visual security status indicator
- Encryption metrics (AES-256-GCM)
- Panic Protocol with confirmation dialog
- Recovery mechanism
- Filtered security log view

### 4. Deployment Hub
- IPA build pipeline visualization
- Animated progress (build → upload → submitted)
- Build configuration display
- Deployment-specific log view

---

## Architecture

- **State Management:** `NeuralOrchestrator` (ObservableObject singleton) injected via `.environmentObject()`
- **Navigation:** Custom `TabView` with 4 tabs in `MainContainerView`
- **Design System:** Centralized tokens in `DesignSystem/` — colors, typography, modifiers, button styles
- **Live Simulation:** Timer-based data animation for demo purposes (fluctuating metrics, random logs)

---

## License

Proprietary — All rights reserved.
