import SwiftUI

// MARK: - Photo Editor View
// Neural Ether photo editing module with filters, adjustments, and crop tools.

struct PhotoEditorView: View {
    @EnvironmentObject var orchestrator: NeuralOrchestrator
    @State private var selectedTool: PhotoTool = .filters
    @State private var selectedFilter: PhotoFilter = .none
    @State private var brightness: Double = 0.0
    @State private var contrast: Double = 0.0
    @State private var saturation: Double = 0.0
    @State private var sharpness: Double = 0.0
    @State private var showExportSheet: Bool = false
    @State private var isProcessing: Bool = false
    @State private var cropAspect: CropAspect = .free

    enum PhotoTool: String, CaseIterable {
        case filters = "FILTERS"
        case adjust = "ADJUST"
        case crop = "CROP"
        case effects = "FX"

        var icon: String {
            switch self {
            case .filters: return "camera.filters"
            case .adjust: return "slider.horizontal.3"
            case .crop: return "crop"
            case .effects: return "sparkles"
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            headerSection
            canvasSection
            toolSelector
            toolPanel
        }
        .background(Color.surface)
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("PHOTO_EDITOR")
                    .font(NeuralFont.headlineMedium())
                    .foregroundColor(.onSurface)

                Text("Neural image processing engine")
                    .font(NeuralFont.monoSmall())
                    .foregroundColor(.onSurfaceVariant)
            }

            Spacer()

            Button {
                exportPhoto()
            } label: {
                HStack(spacing: Spacing.sm) {
                    Image(systemName: "square.and.arrow.up")
                    Text("EXPORT")
                }
            }
            .buttonStyle(NeuralButtonStyle(variant: .primary))
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
    }

    // MARK: - Canvas

    private var canvasSection: some View {
        ZStack {
            // Simulated image canvas with applied filter
            RoundedRectangle(cornerRadius: CornerRadius.lg)
                .fill(
                    LinearGradient(
                        colors: selectedFilter.gradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    VStack(spacing: Spacing.lg) {
                        Image(systemName: "photo.artframe")
                            .font(.system(size: 48))
                            .foregroundColor(.onSurface.opacity(0.3))

                        Text("TAP_TO_IMPORT_IMAGE")
                            .font(NeuralFont.monoMedium())
                            .foregroundColor(.onSurfaceVariant)

                        Text("Filter: \(selectedFilter.rawValue)")
                            .font(NeuralFont.monoSmall())
                            .foregroundColor(.neuralPrimary)
                            .padding(.horizontal, Spacing.md)
                            .padding(.vertical, Spacing.xs)
                            .background(Color.neuralPrimary.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.full))
                    }
                )
                .overlay(
                    // Crop overlay
                    selectedTool == .crop ? cropOverlay : nil
                )
                .brightness(brightness)
                .contrast(1.0 + contrast)
                .saturation(1.0 + saturation)

            if isProcessing {
                processingOverlay
            }
        }
        .aspectRatio(4/3, contentMode: .fit)
        .padding(.horizontal, Spacing.lg)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
    }

    private var cropOverlay: some View {
        RoundedRectangle(cornerRadius: 2)
            .stroke(Color.neuralPrimary, lineWidth: 2)
            .padding(Spacing.xxl)
            .overlay(
                VStack {
                    HStack {
                        cropHandle
                        Spacer()
                        cropHandle
                    }
                    Spacer()
                    HStack {
                        cropHandle
                        Spacer()
                        cropHandle
                    }
                }
                .padding(Spacing.xl)
            )
    }

    private var cropHandle: some View {
        Circle()
            .fill(Color.neuralPrimary)
            .frame(width: 12, height: 12)
            .shadow(color: Color.neuralPrimary.opacity(0.5), radius: 4)
    }

    private var processingOverlay: some View {
        ZStack {
            Color.surface.opacity(0.8)
            VStack(spacing: Spacing.md) {
                ProgressView()
                    .tint(.neuralPrimary)
                Text("PROCESSING...")
                    .font(NeuralFont.monoSmall())
                    .foregroundColor(.neuralPrimary)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
    }

    // MARK: - Tool Selector

    private var toolSelector: some View {
        HStack(spacing: 0) {
            ForEach(PhotoTool.allCases, id: \.rawValue) { tool in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTool = tool
                    }
                } label: {
                    VStack(spacing: Spacing.xs) {
                        Image(systemName: tool.icon)
                            .font(.system(size: 18))
                        Text(tool.rawValue)
                            .font(.system(size: 9, weight: .medium, design: .monospaced))
                    }
                    .foregroundColor(selectedTool == tool ? .neuralPrimary : .onSurfaceVariant)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.md)
                    .background(
                        selectedTool == tool ? Color.neuralPrimary.opacity(0.08) : Color.clear
                    )
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.top, Spacing.md)
    }

    // MARK: - Tool Panels

    @ViewBuilder
    private var toolPanel: some View {
        ScrollView {
            switch selectedTool {
            case .filters:
                filtersPanel
            case .adjust:
                adjustPanel
            case .crop:
                cropPanel
            case .effects:
                effectsPanel
            }
        }
        .frame(maxHeight: 200)
        .padding(.top, Spacing.md)
    }

    // MARK: Filters

    private var filtersPanel: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.md) {
                ForEach(PhotoFilter.allCases, id: \.rawValue) { filter in
                    Button {
                        withAnimation { selectedFilter = filter }
                    } label: {
                        VStack(spacing: Spacing.sm) {
                            RoundedRectangle(cornerRadius: CornerRadius.md)
                                .fill(
                                    LinearGradient(
                                        colors: filter.gradientColors,
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 60, height: 60)
                                .overlay(
                                    RoundedRectangle(cornerRadius: CornerRadius.md)
                                        .stroke(
                                            selectedFilter == filter ? Color.neuralPrimary : Color.clear,
                                            lineWidth: 2
                                        )
                                )

                            Text(filter.rawValue)
                                .font(.system(size: 8, weight: .medium, design: .monospaced))
                                .foregroundColor(selectedFilter == filter ? .neuralPrimary : .onSurfaceVariant)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)
        }
    }

    // MARK: Adjust

    private var adjustPanel: some View {
        VStack(spacing: Spacing.lg) {
            adjustSlider(label: "BRIGHTNESS", value: $brightness, range: -0.5...0.5, color: .neuralWarning)
            adjustSlider(label: "CONTRAST", value: $contrast, range: -0.5...0.5, color: .neuralPrimary)
            adjustSlider(label: "SATURATION", value: $saturation, range: -1.0...1.0, color: .neuralTertiary)
            adjustSlider(label: "SHARPNESS", value: $sharpness, range: 0.0...1.0, color: .neuralSuccess)
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
    }

    private func adjustSlider(label: String, value: Binding<Double>, range: ClosedRange<Double>, color: Color) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Text(label)
                    .font(NeuralFont.monoSmall())
                    .foregroundColor(.onSurfaceVariant)
                    .tracking(1.0)

                Spacer()

                Text(String(format: "%.0f%%", value.wrappedValue * 100))
                    .font(NeuralFont.monoSmall())
                    .foregroundColor(color)
            }

            Slider(value: value, in: range)
                .tint(color)
        }
    }

    // MARK: Crop

    private var cropPanel: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("ASPECT_RATIO")
                .font(NeuralFont.monoSmall())
                .foregroundColor(.onSurfaceVariant)
                .tracking(1.5)
                .padding(.horizontal, Spacing.lg)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.md) {
                    ForEach(CropAspect.allCases, id: \.rawValue) { aspect in
                        Button {
                            withAnimation { cropAspect = aspect }
                        } label: {
                            Text(aspect.rawValue)
                                .font(NeuralFont.monoSmall())
                                .foregroundColor(cropAspect == aspect ? .neuralPrimary : .onSurfaceVariant)
                                .padding(.horizontal, Spacing.md)
                                .padding(.vertical, Spacing.sm)
                                .background(
                                    cropAspect == aspect
                                        ? Color.neuralPrimary.opacity(0.12)
                                        : Color.surfaceContainerLow
                                )
                                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.full))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, Spacing.lg)
            }
        }
        .padding(.vertical, Spacing.md)
    }

    // MARK: Effects

    private var effectsPanel: some View {
        let effects = [
            ("NEURAL_GLOW", "sparkles", Color.neuralPrimary),
            ("CYBER_GRAIN", "circle.grid.3x3", Color.neuralTertiary),
            ("GLITCH_FX", "waveform.path.ecg", Color.neuralError),
            ("HOLOGRAM", "light.beacon.max", Color.neuralSuccess),
            ("VAPORWAVE", "sunset", Color.neuralWarning),
            ("NEON_EDGE", "pencil.and.outline", Color.electricBlue),
        ]

        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: Spacing.md),
            GridItem(.flexible(), spacing: Spacing.md),
            GridItem(.flexible(), spacing: Spacing.md)
        ], spacing: Spacing.md) {
            ForEach(Array(effects.enumerated()), id: \.offset) { _, effect in
                Button {
                    applyEffect(effect.0)
                } label: {
                    VStack(spacing: Spacing.sm) {
                        Image(systemName: effect.1)
                            .font(.system(size: 22))
                            .foregroundColor(effect.2)

                        Text(effect.0)
                            .font(.system(size: 8, weight: .medium, design: .monospaced))
                            .foregroundColor(.onSurfaceVariant)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.md)
                    .background(Color.surfaceContainerLow)
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
    }

    // MARK: - Actions

    private func exportPhoto() {
        isProcessing = true
        orchestrator.systemLogs.insert(
            LogEntry(
                timestamp: Date(),
                level: .info,
                module: "PHOTO",
                message: "EXPORT_STARTED — Filter: \(selectedFilter.rawValue), Processing neural enhancement..."
            ),
            at: 0
        )

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isProcessing = false
            showExportSheet = true
            orchestrator.systemLogs.insert(
                LogEntry(
                    timestamp: Date(),
                    level: .info,
                    module: "PHOTO",
                    message: "EXPORT_COMPLETE — Image saved to Neural Vault."
                ),
                at: 0
            )
        }
    }

    private func applyEffect(_ name: String) {
        isProcessing = true
        orchestrator.systemLogs.insert(
            LogEntry(
                timestamp: Date(),
                level: .info,
                module: "PHOTO",
                message: "APPLYING_EFFECT: \(name) — Neural rendering pipeline active."
            ),
            at: 0
        )

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            isProcessing = false
        }
    }
}

// MARK: - Photo Filter

enum PhotoFilter: String, CaseIterable {
    case none = "ORIGINAL"
    case neuralGlow = "NEURAL"
    case cyberNight = "CYBER"
    case ethereal = "ETHEREAL"
    case darkMatter = "DARK_MATTER"
    case synthwave = "SYNTHWAVE"
    case quantum = "QUANTUM"
    case voidSpace = "VOID"

    var gradientColors: [Color] {
        switch self {
        case .none: return [Color.surfaceContainerLow, Color.surfaceContainerHighest]
        case .neuralGlow: return [Color(hex: "#0A0E17"), Color(hex: "#69DAFF").opacity(0.3)]
        case .cyberNight: return [Color(hex: "#0F131D"), Color(hex: "#A78BFA").opacity(0.3)]
        case .ethereal: return [Color(hex: "#1A1F2E"), Color(hex: "#34D399").opacity(0.3)]
        case .darkMatter: return [Color(hex: "#000000"), Color(hex: "#202633")]
        case .synthwave: return [Color(hex: "#0A0E17"), Color(hex: "#FBBF24").opacity(0.3)]
        case .quantum: return [Color(hex: "#0F131D"), Color(hex: "#00D1FF").opacity(0.4)]
        case .voidSpace: return [Color(hex: "#000000"), Color(hex: "#0A0E17")]
        }
    }
}

// MARK: - Crop Aspect

enum CropAspect: String, CaseIterable {
    case free = "FREE"
    case square = "1:1"
    case portrait = "4:5"
    case landscape = "16:9"
    case story = "9:16"
    case classic = "3:2"
}

#Preview {
    PhotoEditorView()
        .environmentObject(NeuralOrchestrator.shared)
}
