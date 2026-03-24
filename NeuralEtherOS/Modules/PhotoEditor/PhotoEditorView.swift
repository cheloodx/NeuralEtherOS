import SwiftUI

// MARK: - Photo Editor View
// Advanced Neural Ether photo editing module with layers, AI tools, filters, adjustments, crop, effects, and export.

struct PhotoEditorView: View {
    @EnvironmentObject var orchestrator: NeuralOrchestrator
    @State private var selectedTool: PhotoTool = .filters
    @State private var selectedFilter: PhotoFilter = .none
    @State private var brightness: Double = 0.0
    @State private var contrast: Double = 0.0
    @State private var saturation: Double = 0.0
    @State private var sharpness: Double = 0.0
    @State private var temperature: Double = 0.0
    @State private var vignette: Double = 0.0
    @State private var grain: Double = 0.0
    @State private var fade: Double = 0.0
    @State private var showExportSheet: Bool = false
    @State private var isProcessing: Bool = false
    @State private var processingLabel: String = "PROCESSING..."
    @State private var cropAspect: CropAspect = .free
    @State private var selectedLayer: Int = 0
    @State private var layers: [PhotoLayer] = PhotoLayer.defaults
    @State private var undoStack: [String] = []
    @State private var redoStack: [String] = []
    @State private var zoomLevel: Double = 1.0
    @State private var rotation: Double = 0.0
    @State private var flipH: Bool = false
    @State private var flipV: Bool = false
    @State private var showHistogram: Bool = false
    @State private var selectedBlendMode: Int = 0
    @State private var aiEnhanceActive: Bool = false

    enum PhotoTool: String, CaseIterable {
        case filters = "FILTERS"
        case adjust = "ADJUST"
        case crop = "CROP"
        case effects = "FX"
        case layers = "LAYERS"
        case aiTools = "AI"
        case transform = "TRANSFORM"
        case export = "EXPORT"

        var icon: String {
            switch self {
            case .filters: return "camera.filters"
            case .adjust: return "slider.horizontal.3"
            case .crop: return "crop"
            case .effects: return "sparkles"
            case .layers: return "square.3.layers.3d"
            case .aiTools: return "brain.head.profile"
            case .transform: return "arrow.up.left.and.arrow.down.right"
            case .export: return "square.and.arrow.up"
            }
        }
    }

    private let blendModes = ["NORMAL", "MULTIPLY", "SCREEN", "OVERLAY", "SOFT_LIGHT", "HARD_LIGHT", "DIFFERENCE", "EXCLUSION"]

    var body: some View {
        VStack(spacing: 0) {
            headerSection
            canvasSection
            quickActions
            toolSelector
            toolPanel
        }
        .background(Color.surface)
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("PHOTO EDITOR")
                    .font(NeuralFont.headlineMedium())
                    .foregroundColor(.onSurface)
                HStack(spacing: Spacing.sm) {
                    Text("Neural Image Processing Engine")
                        .font(NeuralFont.monoSmall())
                        .foregroundColor(.onSurfaceVariant)
                    if aiEnhanceActive {
                        HStack(spacing: 3) {
                            Circle().fill(Color.neuralSuccess).frame(width: 6, height: 6)
                            Text("AI ACTIVE")
                                .font(.system(size: 8, weight: .bold, design: .monospaced))
                                .foregroundColor(.neuralSuccess)
                        }
                    }
                }
            }
            Spacer()

            // Undo / Redo
            HStack(spacing: Spacing.sm) {
                Button {
                    performUndo()
                } label: {
                    Image(systemName: "arrow.uturn.backward")
                        .font(.system(size: 16))
                        .foregroundColor(undoStack.isEmpty ? .onSurfaceVariant.opacity(0.3) : .neuralPrimary)
                }
                .buttonStyle(.plain)
                .disabled(undoStack.isEmpty)

                Button {
                    performRedo()
                } label: {
                    Image(systemName: "arrow.uturn.forward")
                        .font(.system(size: 16))
                        .foregroundColor(redoStack.isEmpty ? .onSurfaceVariant.opacity(0.3) : .neuralPrimary)
                }
                .buttonStyle(.plain)
                .disabled(redoStack.isEmpty)

                Button { showHistogram.toggle() } label: {
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 16))
                        .foregroundColor(showHistogram ? .neuralPrimary : .onSurfaceVariant)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
    }

    // MARK: - Canvas

    private var canvasSection: some View {
        ZStack {
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
                        Text("TAP TO IMPORT IMAGE")
                            .font(NeuralFont.monoMedium())
                            .foregroundColor(.onSurfaceVariant)
                        HStack(spacing: Spacing.md) {
                            filterBadge("Filter: \(selectedFilter.rawValue)", color: .neuralPrimary)
                            filterBadge("Zoom: \(String(format: "%.0f", zoomLevel * 100))%", color: .neuralTertiary)
                            if rotation != 0 {
                                filterBadge("Rot: \(Int(rotation))\u{00B0}", color: .neuralWarning)
                            }
                        }
                    }
                )
                .overlay(selectedTool == .crop ? cropOverlay : nil)
                .brightness(brightness)
                .contrast(1.0 + contrast)
                .saturation(1.0 + saturation)
                .scaleEffect(x: flipH ? -1 : 1, y: flipV ? -1 : 1)
                .rotationEffect(.degrees(rotation))
                .scaleEffect(zoomLevel)

            if showHistogram { histogramOverlay }
            if isProcessing { processingOverlay }
        }
        .aspectRatio(4/3, contentMode: .fit)
        .padding(.horizontal, Spacing.lg)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
    }

    private func filterBadge(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.system(size: 9, weight: .medium, design: .monospaced))
            .foregroundColor(color)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.xs)
            .background(color.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.full))
    }

    private var histogramOverlay: some View {
        VStack {
            HStack {
                Spacer()
                VStack(spacing: 2) {
                    HStack(alignment: .bottom, spacing: 1) {
                        ForEach(0..<30, id: \.self) { i in
                            let h = CGFloat.random(in: 5...30)
                            RoundedRectangle(cornerRadius: 1)
                                .fill(
                                    i < 10 ? Color.neuralError.opacity(0.6) :
                                    i < 20 ? Color.neuralSuccess.opacity(0.6) :
                                    Color.neuralPrimary.opacity(0.6)
                                )
                                .frame(width: 3, height: h)
                        }
                    }
                    Text("HISTOGRAM")
                        .font(.system(size: 7, weight: .medium, design: .monospaced))
                        .foregroundColor(.onSurfaceVariant.opacity(0.6))
                }
                .padding(Spacing.sm)
                .background(Color.surface.opacity(0.85))
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
                .padding(Spacing.md)
            }
            Spacer()
        }
    }

    private var cropOverlay: some View {
        RoundedRectangle(cornerRadius: 2)
            .stroke(Color.neuralPrimary, lineWidth: 2)
            .padding(Spacing.xxl)
            .overlay(
                VStack {
                    HStack { cropHandle; Spacer(); cropHandle }
                    Spacer()
                    HStack { cropHandle; Spacer(); cropHandle }
                }
                .padding(Spacing.xl)
            )
            .overlay(
                // Rule of thirds grid
                VStack(spacing: 0) {
                    ForEach(0..<3, id: \.self) { _ in
                        HStack(spacing: 0) {
                            ForEach(0..<3, id: \.self) { _ in
                                Rectangle()
                                    .stroke(Color.neuralPrimary.opacity(0.2), lineWidth: 0.5)
                            }
                        }
                    }
                }
                .padding(Spacing.xxl)
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
            Color.surface.opacity(0.85)
            VStack(spacing: Spacing.md) {
                ProgressView().tint(.neuralPrimary).scaleEffect(1.3)
                Text(processingLabel)
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(.neuralPrimary)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
    }

    // MARK: - Quick Actions Bar

    private var quickActions: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.sm) {
                quickActionBtn(icon: "wand.and.stars", label: "AUTO FIX") {
                    runProcess("AI AUTO-ENHANCING...") {
                        brightness = 0.05
                        contrast = 0.1
                        saturation = 0.15
                        sharpness = 0.3
                        aiEnhanceActive = true
                    }
                }
                quickActionBtn(icon: "arrow.counterclockwise", label: "RESET") {
                    resetAll()
                }
                quickActionBtn(icon: "doc.on.doc", label: "DUPLICATE") {
                    pushUndo("Duplicate layer")
                }
                quickActionBtn(icon: "eyedropper", label: "COLOR PICK") {
                    pushUndo("Color pick")
                }
                quickActionBtn(icon: "paintbrush.pointed", label: "DRAW") {
                    pushUndo("Draw mode")
                }
                quickActionBtn(icon: "eraser", label: "ERASE") {
                    pushUndo("Erase mode")
                }
                quickActionBtn(icon: "text.cursor", label: "TEXT") {
                    pushUndo("Add text")
                }
                quickActionBtn(icon: "lasso", label: "SELECT") {
                    pushUndo("Selection")
                }
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.sm)
        }
    }

    private func quickActionBtn(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(.neuralPrimary)
                Text(label)
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.onSurfaceVariant.opacity(0.6))
            }
            .frame(width: 56, height: 44)
            .background(Color.surfaceContainerLow)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Tool Selector

    private var toolSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.sm) {
                ForEach(PhotoTool.allCases, id: \.rawValue) { tool in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) { selectedTool = tool }
                    } label: {
                        VStack(spacing: Spacing.xs) {
                            Image(systemName: tool.icon).font(.system(size: 16))
                            Text(tool.rawValue).font(.system(size: 8, weight: .medium, design: .monospaced))
                        }
                        .foregroundColor(selectedTool == tool ? .neuralPrimary : .onSurfaceVariant)
                        .frame(width: 54)
                        .padding(.vertical, Spacing.sm)
                        .background(selectedTool == tool ? Color.neuralPrimary.opacity(0.08) : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, Spacing.lg)
        }
        .padding(.top, Spacing.sm)
    }

    // MARK: - Tool Panels

    @ViewBuilder
    private var toolPanel: some View {
        ScrollView {
            switch selectedTool {
            case .filters: filtersPanel
            case .adjust: adjustPanel
            case .crop: cropPanel
            case .effects: effectsPanel
            case .layers: layersPanel
            case .aiTools: aiToolsPanel
            case .transform: transformPanel
            case .export: exportPanel
            }
        }
        .frame(maxHeight: 220)
        .padding(.top, Spacing.sm)
    }

    // MARK: - Filters Panel

    private var filtersPanel: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("NEURAL FILTERS")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(.onSurfaceVariant.opacity(0.5))
                .padding(.horizontal, Spacing.lg)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.md) {
                    ForEach(PhotoFilter.allCases, id: \.rawValue) { filter in
                        Button {
                            withAnimation { selectedFilter = filter }
                            pushUndo("Filter: \(filter.rawValue)")
                        } label: {
                            VStack(spacing: Spacing.sm) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: CornerRadius.md)
                                        .fill(
                                            LinearGradient(
                                                colors: filter.gradientColors,
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 64, height: 64)

                                    if selectedFilter == filter {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(.white)
                                    }
                                }
                                .overlay(
                                    RoundedRectangle(cornerRadius: CornerRadius.md)
                                        .stroke(selectedFilter == filter ? Color.neuralPrimary : Color.clear, lineWidth: 2)
                                )

                                Text(filter.rawValue)
                                    .font(.system(size: 8, weight: .medium, design: .monospaced))
                                    .foregroundColor(selectedFilter == filter ? .neuralPrimary : .onSurfaceVariant)
                                Text(filter.description)
                                    .font(.system(size: 6, design: .monospaced))
                                    .foregroundColor(.onSurfaceVariant.opacity(0.4))
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.vertical, Spacing.sm)
            }
        }
    }

    // MARK: - Adjust Panel

    private var adjustPanel: some View {
        VStack(spacing: Spacing.md) {
            adjustSlider(label: "BRIGHTNESS", value: $brightness, range: -0.5...0.5, color: .neuralWarning, icon: "sun.max")
            adjustSlider(label: "CONTRAST", value: $contrast, range: -0.5...0.5, color: .neuralPrimary, icon: "circle.lefthalf.filled")
            adjustSlider(label: "SATURATION", value: $saturation, range: -1.0...1.0, color: .neuralTertiary, icon: "paintpalette")
            adjustSlider(label: "SHARPNESS", value: $sharpness, range: 0.0...1.0, color: .neuralSuccess, icon: "triangle")
            adjustSlider(label: "TEMPERATURE", value: $temperature, range: -1.0...1.0, color: .neuralWarning, icon: "thermometer.medium")
            adjustSlider(label: "VIGNETTE", value: $vignette, range: 0.0...1.0, color: .neuralError, icon: "circle.dashed")
            adjustSlider(label: "GRAIN", value: $grain, range: 0.0...1.0, color: .onSurfaceVariant, icon: "circle.grid.3x3")
            adjustSlider(label: "FADE", value: $fade, range: 0.0...1.0, color: .neuralTertiary, icon: "aqi.medium")
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.sm)
    }

    private func adjustSlider(label: String, value: Binding<Double>, range: ClosedRange<Double>, color: Color, icon: String) -> some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(color.opacity(0.6))
                .frame(width: 18)

            Text(label)
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .foregroundColor(.onSurfaceVariant)
                .frame(width: 80, alignment: .leading)

            Slider(value: value, in: range)
                .tint(color)

            Text(String(format: "%+.0f", value.wrappedValue * 100))
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(color)
                .frame(width: 36, alignment: .trailing)
        }
    }

    // MARK: - Crop Panel

    private var cropPanel: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("ASPECT RATIO")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(.onSurfaceVariant.opacity(0.5))
                .padding(.horizontal, Spacing.lg)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.md) {
                    ForEach(CropAspect.allCases, id: \.rawValue) { aspect in
                        Button {
                            withAnimation { cropAspect = aspect }
                            pushUndo("Crop: \(aspect.rawValue)")
                        } label: {
                            VStack(spacing: 4) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(cropAspect == aspect ? Color.neuralPrimary : Color.outlineVariant.opacity(0.3), lineWidth: 1.5)
                                        .frame(width: aspect.previewWidth, height: aspect.previewHeight)
                                }
                                .frame(width: 40, height: 40)
                                Text(aspect.rawValue)
                                    .font(.system(size: 8, weight: .medium, design: .monospaced))
                                    .foregroundColor(cropAspect == aspect ? .neuralPrimary : .onSurfaceVariant)
                            }
                            .padding(.vertical, Spacing.sm)
                            .padding(.horizontal, Spacing.sm)
                            .background(cropAspect == aspect ? Color.neuralPrimary.opacity(0.08) : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, Spacing.lg)
            }

            // Straighten slider
            HStack(spacing: Spacing.md) {
                Image(systemName: "level")
                    .font(.system(size: 12))
                    .foregroundColor(.neuralPrimary.opacity(0.6))
                Text("STRAIGHTEN")
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .foregroundColor(.onSurfaceVariant)
                Slider(value: $rotation, in: -45...45, step: 0.5)
                    .tint(.neuralPrimary)
                Text("\(String(format: "%.1f", rotation))\u{00B0}")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.neuralPrimary)
                    .frame(width: 40)
            }
            .padding(.horizontal, Spacing.lg)
        }
        .padding(.vertical, Spacing.sm)
    }

    // MARK: - Effects Panel

    private var photoEffects: [(String, String, Color, String)] {
        [
            ("NEURAL GLOW", "sparkles", Color.neuralPrimary, "AI luminance"),
            ("CYBER GRAIN", "circle.grid.3x3", Color.neuralTertiary, "Digital texture"),
            ("GLITCH FX", "waveform.path.ecg", Color.neuralError, "Signal corrupt"),
            ("HOLOGRAM", "light.beacon.max", Color.neuralSuccess, "3D projection"),
            ("VAPORWAVE", "sunset", Color.neuralWarning, "Retro aesthetic"),
            ("NEON EDGE", "pencil.and.outline", Color.electricBlue, "Edge detect"),
            ("BLUR BG", "camera.aperture", Color.neuralTertiary, "Portrait mode"),
            ("DUOTONE", "circle.lefthalf.filled", Color.neuralPrimary, "Two-tone map"),
            ("PIXELATE", "square.grid.4x3.fill", Color.neuralWarning, "Pixel art"),
            ("CHROMATIC", "camera.filters", Color.neuralError, "RGB split"),
            ("OIL PAINT", "paintbrush.fill", Color.neuralSuccess, "Artistic style"),
            ("SKETCH", "pencil.tip", Color.onSurfaceVariant, "Pencil render"),
        ]
    }

    private var effectsPanel: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: Spacing.sm),
            GridItem(.flexible(), spacing: Spacing.sm),
            GridItem(.flexible(), spacing: Spacing.sm),
            GridItem(.flexible(), spacing: Spacing.sm)
        ], spacing: Spacing.sm) {
            ForEach(Array(photoEffects.enumerated()), id: \.offset) { _, effect in
                Button {
                    applyEffect(effect.0)
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: effect.1)
                            .font(.system(size: 20))
                            .foregroundColor(effect.2)
                        Text(effect.0)
                            .font(.system(size: 7, weight: .medium, design: .monospaced))
                            .foregroundColor(.onSurfaceVariant)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                        Text(effect.3)
                            .font(.system(size: 6, design: .monospaced))
                            .foregroundColor(.onSurfaceVariant.opacity(0.4))
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
        .padding(.vertical, Spacing.sm)
    }

    // MARK: - Layers Panel

    private var layersPanel: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Text("LAYERS")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.onSurfaceVariant.opacity(0.5))
                Spacer()
                Button {
                    layers.append(PhotoLayer(name: "Layer \(layers.count + 1)", type: "adjustment", opacity: 1.0, visible: true, locked: false))
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.neuralPrimary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, Spacing.lg)

            // Blend mode
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.sm) {
                    ForEach(Array(blendModes.enumerated()), id: \.offset) { index, mode in
                        Button { selectedBlendMode = index } label: {
                            Text(mode)
                                .font(.system(size: 8, weight: .medium, design: .monospaced))
                                .foregroundColor(selectedBlendMode == index ? .neuralPrimary : .onSurfaceVariant.opacity(0.5))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(selectedBlendMode == index ? Color.neuralPrimary.opacity(0.1) : Color.clear)
                                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.full))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, Spacing.lg)
            }

            ForEach(Array(layers.enumerated()), id: \.element.id) { index, layer in
                HStack(spacing: Spacing.md) {
                    // Visibility
                    Button {
                        layers[index].visible.toggle()
                    } label: {
                        Image(systemName: layer.visible ? "eye.fill" : "eye.slash.fill")
                            .font(.system(size: 12))
                            .foregroundColor(layer.visible ? .neuralPrimary : .onSurfaceVariant.opacity(0.3))
                    }
                    .buttonStyle(.plain)

                    // Layer icon
                    Image(systemName: layer.type == "image" ? "photo" : layer.type == "text" ? "textformat" : "slider.horizontal.3")
                        .font(.system(size: 12))
                        .foregroundColor(.onSurfaceVariant)

                    VStack(alignment: .leading, spacing: 1) {
                        Text(layer.name)
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .foregroundColor(selectedLayer == index ? .neuralPrimary : .onSurface)
                        Text("\(Int(layer.opacity * 100))% opacity")
                            .font(.system(size: 7, design: .monospaced))
                            .foregroundColor(.onSurfaceVariant.opacity(0.5))
                    }

                    Spacer()

                    // Lock
                    Button {
                        layers[index].locked.toggle()
                    } label: {
                        Image(systemName: layer.locked ? "lock.fill" : "lock.open")
                            .font(.system(size: 10))
                            .foregroundColor(layer.locked ? .neuralWarning : .onSurfaceVariant.opacity(0.3))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.vertical, Spacing.xs)
                .background(selectedLayer == index ? Color.neuralPrimary.opacity(0.06) : Color.clear)
                .onTapGesture { selectedLayer = index }
            }
        }
        .padding(.vertical, Spacing.sm)
    }

    // MARK: - AI Tools Panel

    private var aiToolsList: [(String, String, Color, String)] {
        [
            ("BACKGROUND REMOVE", "person.crop.rectangle", Color.neuralPrimary, "Remove background with AI"),
            ("SUPER RESOLUTION", "arrow.up.left.and.arrow.down.right", Color.neuralTertiary, "Upscale 4x with neural net"),
            ("FACE ENHANCE", "face.smiling", Color.neuralSuccess, "Enhance facial features"),
            ("OBJECT ERASE", "eraser.fill", Color.neuralError, "Remove objects seamlessly"),
            ("STYLE TRANSFER", "paintbrush.pointed.fill", Color.neuralWarning, "Apply artistic styles"),
            ("DENOISE", "waveform.path.ecg.rectangle", Color.neuralPrimary, "AI noise reduction"),
            ("COLORIZE", "paintpalette.fill", Color.neuralTertiary, "Add color to B&W"),
            ("SKY REPLACE", "cloud.sun.fill", Color.electricBlue, "Replace sky with AI"),
        ]
    }

    private var aiToolsPanel: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 12))
                    .foregroundColor(.neuralTertiary)
                Text("NEURAL AI TOOLS")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.onSurfaceVariant.opacity(0.5))
                Spacer()
                Text("POWERED BY NEURAL ETHER")
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.neuralTertiary.opacity(0.5))
            }
            .padding(.horizontal, Spacing.lg)

            ForEach(Array(aiToolsList.enumerated()), id: \.offset) { _, tool in
                Button {
                    runProcess("AI: \(tool.0)...") {}
                } label: {
                    HStack(spacing: Spacing.md) {
                        Image(systemName: tool.1)
                            .font(.system(size: 18))
                            .foregroundColor(tool.2)
                            .frame(width: 28)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(tool.0)
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(.onSurface)
                            Text(tool.3)
                                .font(.system(size: 8, design: .monospaced))
                                .foregroundColor(.onSurfaceVariant.opacity(0.5))
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10))
                            .foregroundColor(.onSurfaceVariant.opacity(0.3))
                    }
                    .padding(.horizontal, Spacing.lg)
                    .padding(.vertical, Spacing.sm)
                    .background(Color.surfaceContainerLow)
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, Spacing.lg)
            }
        }
        .padding(.vertical, Spacing.sm)
    }

    // MARK: - Transform Panel

    private var transformPanel: some View {
        VStack(spacing: Spacing.lg) {
            // Zoom
            HStack(spacing: Spacing.md) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 12))
                    .foregroundColor(.neuralPrimary.opacity(0.6))
                Text("ZOOM")
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .foregroundColor(.onSurfaceVariant)
                    .frame(width: 60, alignment: .leading)
                Slider(value: $zoomLevel, in: 0.1...5.0, step: 0.1).tint(.neuralPrimary)
                Text("\(String(format: "%.0f", zoomLevel * 100))%")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.neuralPrimary)
                    .frame(width: 40)
            }

            // Rotation
            HStack(spacing: Spacing.md) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 12))
                    .foregroundColor(.neuralTertiary.opacity(0.6))
                Text("ROTATE")
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .foregroundColor(.onSurfaceVariant)
                    .frame(width: 60, alignment: .leading)
                Slider(value: $rotation, in: -180...180, step: 1).tint(.neuralTertiary)
                Text("\(Int(rotation))\u{00B0}")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.neuralTertiary)
                    .frame(width: 40)
            }

            // Quick rotation buttons
            HStack(spacing: Spacing.md) {
                transformBtn(icon: "rotate.left", label: "-90\u{00B0}") { rotation -= 90 }
                transformBtn(icon: "rotate.right", label: "+90\u{00B0}") { rotation += 90 }
                transformBtn(icon: "arrow.left.and.right", label: "FLIP H") { flipH.toggle() }
                transformBtn(icon: "arrow.up.and.down", label: "FLIP V") { flipV.toggle() }
                transformBtn(icon: "arrow.counterclockwise", label: "RESET") {
                    rotation = 0; zoomLevel = 1.0; flipH = false; flipV = false
                }
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.sm)
    }

    private func transformBtn(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(.neuralPrimary)
                Text(label)
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundColor(.onSurfaceVariant.opacity(0.6))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.md)
            .background(Color.surfaceContainerLow)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Export Panel

    private var exportFormats: [(String, String, String, Color)] {
        [
            ("PNG", "Lossless \u{2022} Transparent", "Best quality", Color.neuralPrimary),
            ("JPEG", "Compressed \u{2022} Web", "Small file", Color.neuralTertiary),
            ("HEIF", "Apple \u{2022} HDR", "iOS native", Color.neuralSuccess),
            ("TIFF", "Print \u{2022} CMYK", "Professional", Color.neuralWarning),
            ("WEBP", "Web \u{2022} Animated", "Modern web", Color.electricBlue),
            ("RAW", "Unprocessed \u{2022} 48MP", "Full data", Color.neuralError),
        ]
    }

    private var exportPanel: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("EXPORT FORMAT")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(.onSurfaceVariant.opacity(0.5))
                .padding(.horizontal, Spacing.lg)

            ForEach(Array(exportFormats.enumerated()), id: \.offset) { _, format in
                Button { exportPhoto(format: format.0) } label: {
                    HStack(spacing: Spacing.md) {
                        ZStack {
                            RoundedRectangle(cornerRadius: CornerRadius.md)
                                .fill(format.3.opacity(0.1))
                                .frame(width: 40, height: 40)
                            Text(format.0)
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(format.3)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(format.1)
                                .font(.system(size: 10, weight: .medium, design: .monospaced))
                                .foregroundColor(.onSurface)
                            Text(format.2)
                                .font(.system(size: 8, design: .monospaced))
                                .foregroundColor(.onSurfaceVariant.opacity(0.5))
                        }
                        Spacer()
                        Image(systemName: "arrow.down.circle")
                            .font(.system(size: 16))
                            .foregroundColor(format.3)
                    }
                    .padding(Spacing.md)
                    .background(Color.surfaceContainerLow)
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, Spacing.lg)
            }

            // Resolution info
            HStack(spacing: Spacing.md) {
                infoChip("4032 x 3024", icon: "arrow.up.left.and.arrow.down.right")
                infoChip("12.2 MP", icon: "camera")
                infoChip("sRGB", icon: "paintpalette")
                infoChip("48-bit", icon: "cpu")
            }
            .padding(.horizontal, Spacing.lg)
        }
        .padding(.vertical, Spacing.sm)
    }

    private func infoChip(_ text: String, icon: String) -> some View {
        HStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 8))
            Text(text)
                .font(.system(size: 8, weight: .medium, design: .monospaced))
        }
        .foregroundColor(.onSurfaceVariant.opacity(0.5))
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(Color.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.full))
    }

    // MARK: - Actions

    private func exportPhoto(format: String = "PNG") {
        runProcess("EXPORTING \(format)...") {
            orchestrator.systemLogs.insert(
                LogEntry(timestamp: Date(), level: .info, module: "PHOTO",
                         message: "EXPORT_COMPLETE \u{2014} \(format) saved to Neural Vault."),
                at: 0
            )
        }
    }

    private func applyEffect(_ name: String) {
        pushUndo("Effect: \(name)")
        runProcess("APPLYING: \(name)...") {}
    }

    private func runProcess(_ label: String, completion: @escaping () -> Void) {
        processingLabel = label
        isProcessing = true
        orchestrator.systemLogs.insert(
            LogEntry(timestamp: Date(), level: .info, module: "PHOTO", message: label),
            at: 0
        )
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            isProcessing = false
            completion()
        }
    }

    private func pushUndo(_ action: String) {
        undoStack.append(action)
        redoStack.removeAll()
    }

    private func performUndo() {
        if let last = undoStack.popLast() {
            redoStack.append(last)
        }
    }

    private func performRedo() {
        if let last = redoStack.popLast() {
            undoStack.append(last)
        }
    }

    private func resetAll() {
        brightness = 0; contrast = 0; saturation = 0; sharpness = 0
        temperature = 0; vignette = 0; grain = 0; fade = 0
        rotation = 0; zoomLevel = 1.0; flipH = false; flipV = false
        selectedFilter = .none; aiEnhanceActive = false
        undoStack.removeAll(); redoStack.removeAll()
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
    case infrared = "INFRARED"
    case chrome = "CHROME"
    case vintage = "VINTAGE"
    case noir = "NOIR"

    var description: String {
        switch self {
        case .none: return "No filter"
        case .neuralGlow: return "AI glow"
        case .cyberNight: return "Night city"
        case .ethereal: return "Dream"
        case .darkMatter: return "Deep void"
        case .synthwave: return "80s retro"
        case .quantum: return "Particles"
        case .voidSpace: return "Dark abyss"
        case .infrared: return "Heat map"
        case .chrome: return "Metallic"
        case .vintage: return "Film grain"
        case .noir: return "B&W cinematic"
        }
    }

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
        case .infrared: return [Color(hex: "#1A0505"), Color(hex: "#F87171").opacity(0.4)]
        case .chrome: return [Color(hex: "#1A1A1A"), Color(hex: "#C0C0C0").opacity(0.3)]
        case .vintage: return [Color(hex: "#1A1508"), Color(hex: "#FBBF24").opacity(0.2)]
        case .noir: return [Color(hex: "#000000"), Color(hex: "#3A3A3A")]
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
    case cinema = "2.35:1"
    case golden = "1.618:1"

    var previewWidth: CGFloat {
        switch self {
        case .free: return 28
        case .square: return 26
        case .portrait: return 22
        case .landscape: return 32
        case .story: return 16
        case .classic: return 30
        case .cinema: return 34
        case .golden: return 32
        }
    }

    var previewHeight: CGFloat {
        switch self {
        case .free: return 22
        case .square: return 26
        case .portrait: return 28
        case .landscape: return 18
        case .story: return 28
        case .classic: return 20
        case .cinema: return 14
        case .golden: return 20
        }
    }
}

// MARK: - Photo Layer

struct PhotoLayer: Identifiable {
    let id = UUID()
    var name: String
    var type: String
    var opacity: Double
    var visible: Bool
    var locked: Bool

    static let defaults: [PhotoLayer] = [
        PhotoLayer(name: "Background", type: "image", opacity: 1.0, visible: true, locked: false),
        PhotoLayer(name: "Adjustments", type: "adjustment", opacity: 1.0, visible: true, locked: false),
        PhotoLayer(name: "Effects", type: "adjustment", opacity: 0.8, visible: true, locked: false),
    ]
}

#Preview {
    PhotoEditorView()
        .environmentObject(NeuralOrchestrator.shared)
}
