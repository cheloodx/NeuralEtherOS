import SwiftUI

// MARK: - Video Editor View
// Advanced Neural Ether video editing module with timeline, effects, transitions, color grading, audio, AI tools, and export.

struct VideoEditorView: View {
    @EnvironmentObject var orchestrator: NeuralOrchestrator
    @State private var selectedTool: VideoTool = .timeline
    @State private var isPlaying: Bool = false
    @State private var currentTime: Double = 0.0
    @State private var totalDuration: Double = 30.0
    @State private var playbackSpeed: PlaybackSpeed = .normal
    @State private var clips: [VideoClip] = VideoClip.sampleClips
    @State private var selectedClipIndex: Int? = nil
    @State private var isExporting: Bool = false
    @State private var exportProgress: Double = 0.0
    @State private var masterVolume: Double = 1.0
    @State private var selectedTransition: Int = 0
    @State private var colorTemp: Double = 0.0
    @State private var colorTint: Double = 0.0
    @State private var shadows: Double = 0.0
    @State private var highlights: Double = 0.0
    @State private var vibrance: Double = 0.0
    @State private var exposure: Double = 0.0
    @State private var selectedExportFormat: Int = 0
    @State private var selectedResolution: Int = 1
    @State private var selectedFPS: Int = 1
    @State private var showWaveform: Bool = true
    @State private var markersCount: Int = 0
    @State private var keyframeCount: Int = 0

    enum VideoTool: String, CaseIterable {
        case timeline = "TIMELINE"
        case effects = "FX"
        case transitions = "CUTS"
        case colorGrade = "COLOR"
        case audio = "AUDIO"
        case aiTools = "AI"
        case text = "TEXT"
        case export = "EXPORT"

        var icon: String {
            switch self {
            case .timeline: return "film"
            case .effects: return "sparkles"
            case .transitions: return "rectangle.on.rectangle.angled"
            case .colorGrade: return "paintpalette"
            case .audio: return "waveform"
            case .aiTools: return "brain.head.profile"
            case .text: return "textformat"
            case .export: return "square.and.arrow.up"
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            headerSection
            previewSection
            playbackControls
            toolSelector
            toolPanel
        }
        .background(Color.surface)
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("VIDEO EDITOR")
                    .font(NeuralFont.headlineMedium())
                    .foregroundColor(.onSurface)
                HStack(spacing: Spacing.md) {
                    Text("Neural Cinematic Engine")
                        .font(NeuralFont.monoSmall())
                        .foregroundColor(.onSurfaceVariant)
                    headerBadge("\(clips.count) clips", color: .neuralPrimary)
                    headerBadge(formatTime(totalDuration), color: .neuralTertiary)
                }
            }
            Spacer()
            HStack(spacing: Spacing.sm) {
                // Markers
                Button {
                    markersCount += 1
                } label: {
                    HStack(spacing: 3) {
                        Image(systemName: "flag.fill").font(.system(size: 10))
                        Text("\(markersCount)")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                    }
                    .foregroundColor(.neuralWarning)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.neuralWarning.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.full))
                }
                .buttonStyle(.plain)

                // Keyframes
                Button {
                    keyframeCount += 1
                } label: {
                    HStack(spacing: 3) {
                        Image(systemName: "diamond.fill").font(.system(size: 8))
                        Text("\(keyframeCount)")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                    }
                    .foregroundColor(.neuralTertiary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.neuralTertiary.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.full))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
    }

    private func headerBadge(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.system(size: 9, weight: .medium, design: .monospaced))
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.full))
    }

    // MARK: - Preview

    private var previewSection: some View {
        ZStack {
            RoundedRectangle(cornerRadius: CornerRadius.lg)
                .fill(Color.surfaceContainerLowest)
                .overlay(
                    VStack(spacing: Spacing.md) {
                        Image(systemName: "film.stack")
                            .font(.system(size: 40))
                            .foregroundColor(.onSurface.opacity(0.2))

                        Text("NEURAL PREVIEW")
                            .font(NeuralFont.monoMedium())
                            .foregroundColor(.onSurfaceVariant)

                        HStack(spacing: Spacing.md) {
                            Text(formatTime(currentTime))
                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                                .foregroundColor(.neuralPrimary)
                            Text("/")
                                .font(NeuralFont.monoSmall())
                                .foregroundColor(.onSurfaceVariant)
                            Text(formatTime(totalDuration))
                                .font(NeuralFont.monoSmall())
                                .foregroundColor(.onSurfaceVariant)
                        }

                        if isPlaying {
                            HStack(spacing: Spacing.sm) {
                                Circle().fill(Color.neuralError).frame(width: 8, height: 8)
                                Text("PLAYING \(playbackSpeed.rawValue)")
                                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                                    .foregroundColor(.neuralError)
                            }
                        }

                        // Preview info bar
                        HStack(spacing: Spacing.lg) {
                            previewInfo("RES", value: ["720p", "1080p", "4K", "8K"][selectedResolution])
                            previewInfo("FPS", value: ["24", "30", "60", "120"][selectedFPS])
                            previewInfo("CODEC", value: "H.265")
                            previewInfo("HDR", value: "ON")
                        }
                    }
                )

            if isExporting { exportOverlay }
        }
        .aspectRatio(16/9, contentMode: .fit)
        .padding(.horizontal, Spacing.lg)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
    }

    private func previewInfo(_ label: String, value: String) -> some View {
        VStack(spacing: 1) {
            Text(value)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(.neuralPrimary)
            Text(label)
                .font(.system(size: 6, weight: .medium, design: .monospaced))
                .foregroundColor(.onSurfaceVariant.opacity(0.4))
        }
    }

    private var exportOverlay: some View {
        ZStack {
            Color.surface.opacity(0.9)
            VStack(spacing: Spacing.md) {
                Text("RENDERING VIDEO")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(.neuralPrimary)
                ProgressView(value: exportProgress)
                    .tint(.neuralPrimary)
                    .frame(width: 200)
                HStack(spacing: Spacing.lg) {
                    Text("\(Int(exportProgress * 100))%")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(.neuralPrimary)
                    Text("ETA: \(Int((1.0 - exportProgress) * 30))s")
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(.onSurfaceVariant)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
    }

    // MARK: - Playback Controls

    private var playbackControls: some View {
        VStack(spacing: Spacing.sm) {
            // Scrubber with waveform bg
            ZStack(alignment: .leading) {
                if showWaveform {
                    HStack(alignment: .bottom, spacing: 1) {
                        ForEach(0..<60, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 1)
                                .fill(Color.neuralPrimary.opacity(0.15))
                                .frame(width: 3, height: CGFloat.random(in: 3...14))
                        }
                    }
                    .frame(height: 16)
                    .padding(.horizontal, Spacing.lg)
                }
                Slider(value: $currentTime, in: 0...totalDuration)
                    .tint(.neuralPrimary)
                    .padding(.horizontal, Spacing.lg)
            }

            // Control buttons
            HStack(spacing: Spacing.xl) {
                Button { currentTime = max(0, currentTime - 5) } label: {
                    Image(systemName: "gobackward.5")
                        .font(.system(size: 18)).foregroundColor(.onSurfaceVariant)
                }
                .buttonStyle(.plain)

                Button { currentTime = max(0, currentTime - 1.0 / 30.0) } label: {
                    Image(systemName: "backward.frame.fill")
                        .font(.system(size: 16)).foregroundColor(.onSurfaceVariant)
                }
                .buttonStyle(.plain)

                Button { currentTime = 0 } label: {
                    Image(systemName: "backward.end.fill")
                        .font(.system(size: 16)).foregroundColor(.onSurfaceVariant)
                }
                .buttonStyle(.plain)

                Button { togglePlayback() } label: {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 38))
                        .foregroundColor(.neuralPrimary)
                        .shadow(color: .neuralPrimary.opacity(0.4), radius: 8)
                }
                .buttonStyle(.plain)

                Button { currentTime = totalDuration } label: {
                    Image(systemName: "forward.end.fill")
                        .font(.system(size: 16)).foregroundColor(.onSurfaceVariant)
                }
                .buttonStyle(.plain)

                Button { currentTime = min(totalDuration, currentTime + 1.0 / 30.0) } label: {
                    Image(systemName: "forward.frame.fill")
                        .font(.system(size: 16)).foregroundColor(.onSurfaceVariant)
                }
                .buttonStyle(.plain)

                Button { currentTime = min(totalDuration, currentTime + 5) } label: {
                    Image(systemName: "goforward.5")
                        .font(.system(size: 18)).foregroundColor(.onSurfaceVariant)
                }
                .buttonStyle(.plain)
            }

            // Speed selector
            HStack(spacing: Spacing.sm) {
                ForEach(PlaybackSpeed.allCases, id: \.rawValue) { speed in
                    Button { playbackSpeed = speed } label: {
                        Text(speed.rawValue)
                            .font(.system(size: 9, weight: .medium, design: .monospaced))
                            .foregroundColor(playbackSpeed == speed ? .neuralPrimary : .onSurfaceVariant.opacity(0.5))
                            .padding(.horizontal, Spacing.sm)
                            .padding(.vertical, 3)
                            .background(playbackSpeed == speed ? Color.neuralPrimary.opacity(0.12) : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.sm))
                    }
                    .buttonStyle(.plain)
                }

                Spacer()

                // Waveform toggle
                Button { showWaveform.toggle() } label: {
                    Image(systemName: "waveform")
                        .font(.system(size: 12))
                        .foregroundColor(showWaveform ? .neuralPrimary : .onSurfaceVariant.opacity(0.3))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, Spacing.lg)
        }
        .padding(.vertical, Spacing.sm)
    }

    // MARK: - Tool Selector

    private var toolSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.sm) {
                ForEach(VideoTool.allCases, id: \.rawValue) { tool in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) { selectedTool = tool }
                    } label: {
                        VStack(spacing: Spacing.xs) {
                            Image(systemName: tool.icon).font(.system(size: 14))
                            Text(tool.rawValue).font(.system(size: 8, weight: .medium, design: .monospaced))
                        }
                        .foregroundColor(selectedTool == tool ? .neuralPrimary : .onSurfaceVariant)
                        .frame(width: 50)
                        .padding(.vertical, Spacing.sm)
                        .background(selectedTool == tool ? Color.neuralPrimary.opacity(0.08) : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, Spacing.lg)
        }
    }

    // MARK: - Tool Panels

    @ViewBuilder
    private var toolPanel: some View {
        ScrollView {
            switch selectedTool {
            case .timeline: timelinePanel
            case .effects: videoEffectsPanel
            case .transitions: transitionsPanel
            case .colorGrade: colorGradePanel
            case .audio: audioPanel
            case .aiTools: aiToolsPanel
            case .text: textToolsPanel
            case .export: exportPanel
            }
        }
        .frame(maxHeight: 180)
    }

    // MARK: - Timeline

    private var timelinePanel: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Text("CLIPS")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.onSurfaceVariant.opacity(0.5))
                Spacer()
                HStack(spacing: Spacing.sm) {
                    timelineActionBtn(icon: "scissors", label: "SPLIT") { splitClip() }
                    timelineActionBtn(icon: "trash", label: "DELETE") { deleteClip() }
                    timelineActionBtn(icon: "doc.on.doc", label: "COPY") { duplicateClip() }
                }
            }
            .padding(.horizontal, Spacing.lg)

            // Timeline track
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 2) {
                    ForEach(Array(clips.enumerated()), id: \.element.id) { index, clip in
                        Button { selectedClipIndex = index } label: {
                            VStack(spacing: 2) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: CornerRadius.sm)
                                        .fill(
                                            LinearGradient(
                                                colors: [clip.color.opacity(0.4), clip.color.opacity(0.15)],
                                                startPoint: .top, endPoint: .bottom
                                            )
                                        )
                                        .frame(width: max(30, CGFloat(clip.duration) * 8), height: 44)

                                    VStack(spacing: 1) {
                                        Text(clip.name)
                                            .font(.system(size: 7, weight: .bold, design: .monospaced))
                                            .foregroundColor(.onSurface)
                                            .lineLimit(1)
                                        Text(formatTime(clip.duration))
                                            .font(.system(size: 6, design: .monospaced))
                                            .foregroundColor(.onSurfaceVariant.opacity(0.6))
                                    }
                                }
                                .overlay(
                                    RoundedRectangle(cornerRadius: CornerRadius.sm)
                                        .stroke(
                                            selectedClipIndex == index ? Color.neuralPrimary : Color.outlineVariant.opacity(0.15),
                                            lineWidth: selectedClipIndex == index ? 2 : 0.5
                                        )
                                )

                                // Audio waveform mini
                                HStack(alignment: .bottom, spacing: 0.5) {
                                    ForEach(0..<Int(max(5, clip.duration * 2)), id: \.self) { _ in
                                        RoundedRectangle(cornerRadius: 0.5)
                                            .fill(clip.color.opacity(0.3))
                                            .frame(width: 2, height: CGFloat.random(in: 2...8))
                                    }
                                }
                                .frame(height: 10)
                            }
                        }
                        .buttonStyle(.plain)
                    }

                    // Add clip
                    Button { addClip() } label: {
                        RoundedRectangle(cornerRadius: CornerRadius.sm)
                            .stroke(Color.outlineVariant.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [4]))
                            .frame(width: 44, height: 44)
                            .overlay(
                                VStack(spacing: 2) {
                                    Image(systemName: "plus").font(.system(size: 14))
                                    Text("ADD").font(.system(size: 6, weight: .medium, design: .monospaced))
                                }
                                .foregroundColor(.onSurfaceVariant.opacity(0.4))
                            )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, Spacing.lg)
            }

            // Selected clip info
            if let idx = selectedClipIndex, idx < clips.count {
                HStack(spacing: Spacing.md) {
                    clipInfo("NAME", value: clips[idx].name)
                    clipInfo("DURATION", value: formatTime(clips[idx].duration))
                    clipInfo("TYPE", value: clips[idx].type)
                    clipInfo("START", value: formatTime(clips[0..<idx].reduce(0) { $0 + clips[$1 == clips[0] ? 0 : 1].duration }))
                }
                .padding(.horizontal, Spacing.lg)
            }
        }
        .padding(.vertical, Spacing.sm)
    }

    private func timelineActionBtn(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 3) {
                Image(systemName: icon).font(.system(size: 10))
                Text(label).font(.system(size: 8, weight: .medium, design: .monospaced))
            }
            .foregroundColor(.neuralPrimary)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.neuralPrimary.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.full))
        }
        .buttonStyle(.plain)
    }

    private func clipInfo(_ label: String, value: String) -> some View {
        VStack(spacing: 1) {
            Text(value)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(.onSurface)
            Text(label)
                .font(.system(size: 6, weight: .medium, design: .monospaced))
                .foregroundColor(.onSurfaceVariant.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
        .background(Color.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.sm))
    }

    // MARK: - Video Effects

    private var videoEffects: [(String, String, Color, String)] {
        [
            ("SLOW MO", "tortoise", Color.neuralPrimary, "Time warp"),
            ("REVERSE", "arrow.uturn.backward", Color.neuralTertiary, "Play backward"),
            ("GLITCH", "waveform.path.ecg", Color.neuralError, "Signal distort"),
            ("ZOOM IN", "plus.magnifyingglass", Color.neuralSuccess, "Ken Burns"),
            ("SHAKE", "iphone.radiowaves.left.and.right", Color.neuralWarning, "Camera shake"),
            ("BLUR", "camera.aperture", Color.neuralPrimary, "Gaussian blur"),
            ("FREEZE", "snowflake", Color.electricBlue, "Freeze frame"),
            ("STROBE", "bolt.fill", Color.neuralWarning, "Flash effect"),
            ("MIRROR", "arrow.left.and.right", Color.neuralTertiary, "Flip mirror"),
            ("ROTATE", "arrow.clockwise", Color.neuralSuccess, "Spin effect"),
            ("SPEED RAMP", "gauge.with.dots.needle.67percent", Color.neuralPrimary, "Variable speed"),
            ("CHROMATIC", "camera.filters", Color.neuralError, "RGB aberration"),
        ]
    }

    private var videoEffectsPanel: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: Spacing.sm),
            GridItem(.flexible(), spacing: Spacing.sm),
            GridItem(.flexible(), spacing: Spacing.sm),
            GridItem(.flexible(), spacing: Spacing.sm)
        ], spacing: Spacing.sm) {
            ForEach(Array(videoEffects.enumerated()), id: \.offset) { _, effect in
                Button { applyVideoEffect(effect.0) } label: {
                    VStack(spacing: 3) {
                        Image(systemName: effect.1)
                            .font(.system(size: 18))
                            .foregroundColor(effect.2)
                        Text(effect.0)
                            .font(.system(size: 7, weight: .medium, design: .monospaced))
                            .foregroundColor(.onSurfaceVariant)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                        Text(effect.3)
                            .font(.system(size: 6, design: .monospaced))
                            .foregroundColor(.onSurfaceVariant.opacity(0.4))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.sm)
                    .background(Color.surfaceContainerLow)
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.sm)
    }

    // MARK: - Transitions

    private var transitionTypes: [(String, String, Color)] {
        [
            ("CUT", "scissors", Color.onSurfaceVariant),
            ("CROSS DISSOLVE", "circle.lefthalf.filled", Color.neuralPrimary),
            ("FADE BLACK", "rectangle.fill", Color.onSurfaceVariant),
            ("FADE WHITE", "rectangle", Color.neuralPrimary),
            ("SLIDE LEFT", "arrow.left", Color.neuralTertiary),
            ("SLIDE RIGHT", "arrow.right", Color.neuralTertiary),
            ("SLIDE UP", "arrow.up", Color.neuralWarning),
            ("ZOOM", "plus.magnifyingglass", Color.neuralSuccess),
            ("WIPE", "line.diagonal", Color.neuralWarning),
            ("SWIRL", "tornado", Color.neuralError),
            ("GLITCH CUT", "waveform.path.ecg", Color.neuralError),
            ("FLASH", "bolt.fill", Color.neuralWarning),
        ]
    }

    private var transitionsPanel: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("TRANSITIONS")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(.onSurfaceVariant.opacity(0.5))
                .padding(.horizontal, Spacing.lg)

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: Spacing.sm),
                GridItem(.flexible(), spacing: Spacing.sm),
                GridItem(.flexible(), spacing: Spacing.sm)
            ], spacing: Spacing.sm) {
                ForEach(Array(transitionTypes.enumerated()), id: \.offset) { index, trans in
                    Button { selectedTransition = index } label: {
                        VStack(spacing: 4) {
                            Image(systemName: trans.1)
                                .font(.system(size: 18))
                                .foregroundColor(selectedTransition == index ? trans.2 : .onSurfaceVariant.opacity(0.5))
                            Text(trans.0)
                                .font(.system(size: 7, weight: .medium, design: .monospaced))
                                .foregroundColor(selectedTransition == index ? trans.2 : .onSurfaceVariant.opacity(0.5))
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.md)
                        .background(selectedTransition == index ? trans.2.opacity(0.08) : Color.surfaceContainerLow)
                        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
                        .overlay(
                            RoundedRectangle(cornerRadius: CornerRadius.md)
                                .stroke(selectedTransition == index ? trans.2.opacity(0.3) : Color.clear, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, Spacing.lg)

            // Duration slider
            HStack(spacing: Spacing.md) {
                Text("DURATION")
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .foregroundColor(.onSurfaceVariant)
                Slider(value: .constant(0.5), in: 0.1...3.0).tint(.neuralPrimary)
                Text("0.5s")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.neuralPrimary)
            }
            .padding(.horizontal, Spacing.lg)
        }
        .padding(.vertical, Spacing.sm)
    }

    // MARK: - Color Grade

    private var colorGradePanel: some View {
        VStack(spacing: Spacing.md) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: "paintpalette").font(.system(size: 12)).foregroundColor(.neuralTertiary)
                Text("COLOR GRADING")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.onSurfaceVariant.opacity(0.5))
                Spacer()
            }
            .padding(.horizontal, Spacing.lg)

            colorSlider(label: "EXPOSURE", value: $exposure, range: -2.0...2.0, color: .neuralWarning, icon: "sun.max")
            colorSlider(label: "TEMPERATURE", value: $colorTemp, range: -1.0...1.0, color: .neuralWarning, icon: "thermometer.medium")
            colorSlider(label: "TINT", value: $colorTint, range: -1.0...1.0, color: .neuralTertiary, icon: "drop.fill")
            colorSlider(label: "SHADOWS", value: $shadows, range: -1.0...1.0, color: .onSurfaceVariant, icon: "circle.bottomhalf.filled")
            colorSlider(label: "HIGHLIGHTS", value: $highlights, range: -1.0...1.0, color: .neuralPrimary, icon: "circle.tophalf.filled")
            colorSlider(label: "VIBRANCE", value: $vibrance, range: 0.0...1.0, color: .neuralSuccess, icon: "paintpalette")

            // Color LUT presets
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.sm) {
                    ForEach(["CINEMATIC", "ORANGE+TEAL", "VINTAGE", "COLD", "WARM", "BLEACH", "NOIR", "NEON"], id: \.self) { lut in
                        Button {} label: {
                            Text(lut)
                                .font(.system(size: 8, weight: .medium, design: .monospaced))
                                .foregroundColor(.neuralPrimary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.neuralPrimary.opacity(0.08))
                                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.full))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, Spacing.lg)
            }
        }
        .padding(.vertical, Spacing.sm)
    }

    private func colorSlider(label: String, value: Binding<Double>, range: ClosedRange<Double>, color: Color, icon: String) -> some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 11))
                .foregroundColor(color.opacity(0.6))
                .frame(width: 16)
            Text(label)
                .font(.system(size: 8, weight: .medium, design: .monospaced))
                .foregroundColor(.onSurfaceVariant)
                .frame(width: 80, alignment: .leading)
            Slider(value: value, in: range).tint(color)
            Text(String(format: "%+.0f", value.wrappedValue * 100))
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(color)
                .frame(width: 34, alignment: .trailing)
        }
        .padding(.horizontal, Spacing.lg)
    }

    // MARK: - Audio

    private var audioPanel: some View {
        VStack(spacing: Spacing.lg) {
            // Master volume
            HStack(spacing: Spacing.md) {
                Image(systemName: "speaker.wave.2")
                    .font(.system(size: 14)).foregroundColor(.neuralPrimary)
                Text("MASTER VOLUME")
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .foregroundColor(.onSurfaceVariant)
                Slider(value: $masterVolume, in: 0...1).tint(.neuralPrimary)
                Text("\(Int(masterVolume * 100))%")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.neuralPrimary)
                    .frame(width: 34)
            }

            VStack(alignment: .leading, spacing: Spacing.md) {
                Text("AUDIO TRACKS")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.onSurfaceVariant.opacity(0.5))

                audioTrackRow(name: "ORIGINAL AUDIO", icon: "waveform", color: .neuralPrimary, active: true, volume: 100)
                audioTrackRow(name: "VOICE OVER", icon: "mic.fill", color: .neuralTertiary, active: false, volume: 80)
                audioTrackRow(name: "MUSIC BGM", icon: "music.note", color: .neuralWarning, active: true, volume: 40)
                audioTrackRow(name: "SFX LAYER", icon: "speaker.wave.3", color: .neuralSuccess, active: false, volume: 60)
                audioTrackRow(name: "AMBIENT", icon: "leaf.fill", color: .onSurfaceVariant, active: false, volume: 20)
            }

            // Audio FX
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.sm) {
                    ForEach(["NORMALIZE", "DENOISE", "COMPRESS", "EQ", "REVERB", "ECHO", "BASS BOOST", "FADE IN/OUT"], id: \.self) { fx in
                        Button {} label: {
                            Text(fx)
                                .font(.system(size: 8, weight: .medium, design: .monospaced))
                                .foregroundColor(.neuralTertiary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 5)
                                .background(Color.neuralTertiary.opacity(0.08))
                                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.full))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.sm)
    }

    private func audioTrackRow(name: String, icon: String, color: Color, active: Bool, volume: Int) -> some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 12)).foregroundColor(color).frame(width: 18)
            Text(name)
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .foregroundColor(.onSurface)
            Spacer()
            Text("\(volume)%")
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(color)
            Text(active ? "ON" : "OFF")
                .font(.system(size: 7, weight: .bold, design: .monospaced))
                .foregroundColor(active ? .neuralSuccess : .onSurfaceVariant.opacity(0.4))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background((active ? Color.neuralSuccess : Color.surfaceContainerHighest).opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.full))
        }
    }

    // MARK: - AI Tools

    private var aiVideoTools: [(String, String, Color, String)] {
        [
            ("AUTO CUT", "scissors", Color.neuralPrimary, "AI detects best cuts"),
            ("STABILIZE", "hand.raised.slash", Color.neuralTertiary, "Remove camera shake"),
            ("SCENE DETECT", "eye.fill", Color.neuralSuccess, "Split scenes auto"),
            ("OBJECT TRACK", "scope", Color.neuralWarning, "Follow objects"),
            ("BACKGROUND SWAP", "person.crop.rectangle", Color.neuralError, "Replace background"),
            ("AUTO CAPTION", "text.bubble", Color.electricBlue, "Generate subtitles"),
            ("DENOISE VIDEO", "waveform.path.ecg.rectangle", Color.neuralPrimary, "AI noise removal"),
            ("SUPER RES", "arrow.up.left.and.arrow.down.right", Color.neuralTertiary, "Upscale to 4K"),
        ]
    }

    private var aiToolsPanel: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: "brain.head.profile").font(.system(size: 12)).foregroundColor(.neuralTertiary)
                Text("NEURAL AI VIDEO TOOLS")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.onSurfaceVariant.opacity(0.5))
            }
            .padding(.horizontal, Spacing.lg)

            ForEach(Array(aiVideoTools.enumerated()), id: \.offset) { _, tool in
                Button {} label: {
                    HStack(spacing: Spacing.md) {
                        Image(systemName: tool.1).font(.system(size: 16)).foregroundColor(tool.2).frame(width: 24)
                        VStack(alignment: .leading, spacing: 1) {
                            Text(tool.0)
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(.onSurface)
                            Text(tool.3)
                                .font(.system(size: 8, design: .monospaced))
                                .foregroundColor(.onSurfaceVariant.opacity(0.5))
                        }
                        Spacer()
                        Image(systemName: "chevron.right").font(.system(size: 10)).foregroundColor(.onSurfaceVariant.opacity(0.3))
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

    // MARK: - Text Tools

    private var textToolsPanel: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("TEXT & TITLES")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(.onSurfaceVariant.opacity(0.5))
                .padding(.horizontal, Spacing.lg)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.sm) {
                textTemplate(name: "LOWER THIRD", desc: "News-style name bar", icon: "rectangle.bottomthird.inset.filled", color: .neuralPrimary)
                textTemplate(name: "TITLE CARD", desc: "Full screen title", icon: "textformat.size.larger", color: .neuralTertiary)
                textTemplate(name: "SUBTITLE", desc: "Bottom caption", icon: "text.below.photo", color: .neuralSuccess)
                textTemplate(name: "CALL OUT", desc: "Arrow pointer text", icon: "arrow.up.right", color: .neuralWarning)
                textTemplate(name: "CREDITS", desc: "Scrolling end credits", icon: "text.justify", color: .onSurfaceVariant)
                textTemplate(name: "COUNTER", desc: "Animated numbers", icon: "number", color: .neuralError)
            }
            .padding(.horizontal, Spacing.lg)

            // Font style chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.sm) {
                    ForEach(["BOLD", "ITALIC", "OUTLINE", "SHADOW", "NEON GLOW", "GLITCH", "TYPEWRITER", "3D"], id: \.self) { style in
                        Button {} label: {
                            Text(style)
                                .font(.system(size: 8, weight: .medium, design: .monospaced))
                                .foregroundColor(.neuralPrimary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.neuralPrimary.opacity(0.08))
                                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.full))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, Spacing.lg)
            }
        }
        .padding(.vertical, Spacing.sm)
    }

    private func textTemplate(name: String, desc: String, icon: String, color: Color) -> some View {
        Button {} label: {
            VStack(spacing: 4) {
                Image(systemName: icon).font(.system(size: 20)).foregroundColor(color)
                Text(name)
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .foregroundColor(.onSurface)
                Text(desc)
                    .font(.system(size: 6, design: .monospaced))
                    .foregroundColor(.onSurfaceVariant.opacity(0.5))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.md)
            .background(Color.surfaceContainerLow)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Export

    private let exportFormats = ["MP4", "MOV", "WEBM", "AVI", "GIF"]
    private let resolutions = ["720p", "1080p", "4K", "8K"]
    private let frameRates = ["24 fps", "30 fps", "60 fps", "120 fps"]

    private var exportPanel: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // Format
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("FORMAT")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(.onSurfaceVariant.opacity(0.5))
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.sm) {
                        ForEach(Array(exportFormats.enumerated()), id: \.offset) { index, fmt in
                            Button { selectedExportFormat = index } label: {
                                Text(fmt)
                                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                                    .foregroundColor(selectedExportFormat == index ? .neuralPrimary : .onSurfaceVariant)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(selectedExportFormat == index ? Color.neuralPrimary.opacity(0.12) : Color.surfaceContainerLow)
                                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: CornerRadius.md)
                                            .stroke(selectedExportFormat == index ? Color.neuralPrimary.opacity(0.3) : Color.clear, lineWidth: 1)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }

            // Resolution
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("RESOLUTION")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(.onSurfaceVariant.opacity(0.5))
                HStack(spacing: Spacing.sm) {
                    ForEach(Array(resolutions.enumerated()), id: \.offset) { index, res in
                        Button { selectedResolution = index } label: {
                            Text(res)
                                .font(.system(size: 9, weight: .medium, design: .monospaced))
                                .foregroundColor(selectedResolution == index ? .neuralTertiary : .onSurfaceVariant)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(selectedResolution == index ? Color.neuralTertiary.opacity(0.12) : Color.surfaceContainerLow)
                                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            // FPS
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("FRAME RATE")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(.onSurfaceVariant.opacity(0.5))
                HStack(spacing: Spacing.sm) {
                    ForEach(Array(frameRates.enumerated()), id: \.offset) { index, fps in
                        Button { selectedFPS = index } label: {
                            Text(fps)
                                .font(.system(size: 9, weight: .medium, design: .monospaced))
                                .foregroundColor(selectedFPS == index ? .neuralSuccess : .onSurfaceVariant)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(selectedFPS == index ? Color.neuralSuccess.opacity(0.12) : Color.surfaceContainerLow)
                                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            // Export button
            Button { startExport(format: exportFormats[selectedExportFormat]) } label: {
                HStack(spacing: Spacing.md) {
                    Image(systemName: "arrow.down.circle.fill").font(.system(size: 18))
                    VStack(alignment: .leading, spacing: 1) {
                        Text("EXPORT \(exportFormats[selectedExportFormat])")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                        Text("\(resolutions[selectedResolution]) \u{2022} \(frameRates[selectedFPS]) \u{2022} H.265")
                            .font(.system(size: 8, design: .monospaced))
                            .foregroundColor(.surfaceContainerLowest.opacity(0.7))
                    }
                    Spacer()
                    Text("~\(Int.random(in: 50...500)) MB")
                        .font(.system(size: 9, weight: .medium, design: .monospaced))
                        .foregroundColor(.surfaceContainerLowest.opacity(0.7))
                }
                .foregroundColor(.surfaceContainerLowest)
                .padding(Spacing.md)
                .background(LinearGradient.neuralPrimaryGradient)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.sm)
    }

    // MARK: - Actions

    private func togglePlayback() {
        isPlaying.toggle()
        if isPlaying { simulatePlayback() }
    }

    private func simulatePlayback() {
        guard isPlaying else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if self.isPlaying && self.currentTime < self.totalDuration {
                self.currentTime += 0.1 * self.playbackSpeed.multiplier
                self.simulatePlayback()
            } else if self.currentTime >= self.totalDuration {
                self.isPlaying = false
                self.currentTime = 0
            }
        }
    }

    private func addClip() {
        let colors: [Color] = [.neuralPrimary, .neuralTertiary, .neuralWarning, .neuralSuccess, .neuralError]
        let types = ["video", "image", "title"]
        let newClip = VideoClip(
            name: "CLIP_\(clips.count + 1)",
            duration: Double.random(in: 2...10),
            color: colors.randomElement() ?? .neuralPrimary,
            type: types.randomElement() ?? "video"
        )
        clips.append(newClip)
        totalDuration = clips.reduce(0) { $0 + $1.duration }
        orchestrator.systemLogs.insert(
            LogEntry(timestamp: Date(), level: .info, module: "VIDEO",
                     message: "CLIP_ADDED: \(newClip.name) \u{2014} \(formatTime(newClip.duration))"),
            at: 0
        )
    }

    private func splitClip() {
        guard let idx = selectedClipIndex, idx < clips.count else { return }
        let clip = clips[idx]
        let half = clip.duration / 2.0
        clips[idx] = VideoClip(name: "\(clip.name)_A", duration: half, color: clip.color, type: clip.type)
        clips.insert(VideoClip(name: "\(clip.name)_B", duration: half, color: clip.color, type: clip.type), at: idx + 1)
    }

    private func deleteClip() {
        guard let idx = selectedClipIndex, idx < clips.count else { return }
        clips.remove(at: idx)
        selectedClipIndex = nil
        totalDuration = clips.reduce(0) { $0 + $1.duration }
    }

    private func duplicateClip() {
        guard let idx = selectedClipIndex, idx < clips.count else { return }
        let clip = clips[idx]
        clips.insert(VideoClip(name: "\(clip.name)_COPY", duration: clip.duration, color: clip.color, type: clip.type), at: idx + 1)
        totalDuration = clips.reduce(0) { $0 + $1.duration }
    }

    private func applyVideoEffect(_ name: String) {
        orchestrator.systemLogs.insert(
            LogEntry(timestamp: Date(), level: .info, module: "VIDEO",
                     message: "EFFECT_APPLIED: \(name) \u{2014} Neural rendering active."),
            at: 0
        )
    }

    private func startExport(format: String) {
        isExporting = true
        exportProgress = 0.0
        orchestrator.systemLogs.insert(
            LogEntry(timestamp: Date(), level: .info, module: "VIDEO",
                     message: "EXPORT_STARTED \u{2014} \(format) \(resolutions[selectedResolution]) \(frameRates[selectedFPS])"),
            at: 0
        )
        simulateExport()
    }

    private func simulateExport() {
        guard isExporting && exportProgress < 1.0 else {
            if exportProgress >= 1.0 {
                isExporting = false
                orchestrator.systemLogs.insert(
                    LogEntry(timestamp: Date(), level: .info, module: "VIDEO",
                             message: "EXPORT_COMPLETE \u{2014} Video saved to Neural Vault."),
                    at: 0
                )
            }
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.exportProgress += 0.02
            self.simulateExport()
        }
    }

    private func formatTime(_ seconds: Double) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        let ms = Int((seconds.truncatingRemainder(dividingBy: 1)) * 10)
        return String(format: "%02d:%02d.%d", mins, secs, ms)
    }
}

// MARK: - Video Clip Model

struct VideoClip: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let duration: Double
    let color: Color
    var type: String = "video"

    static func == (lhs: VideoClip, rhs: VideoClip) -> Bool {
        lhs.id == rhs.id
    }

    static let sampleClips: [VideoClip] = [
        VideoClip(name: "INTRO", duration: 5.0, color: .neuralPrimary, type: "title"),
        VideoClip(name: "SCENE_1", duration: 8.0, color: .neuralTertiary, type: "video"),
        VideoClip(name: "B-ROLL", duration: 3.0, color: .neuralWarning, type: "video"),
        VideoClip(name: "TRANSITION", duration: 2.0, color: .neuralSuccess, type: "image"),
        VideoClip(name: "SCENE_2", duration: 10.0, color: .neuralPrimary, type: "video"),
        VideoClip(name: "SFX_INSERT", duration: 1.5, color: .neuralError, type: "video"),
        VideoClip(name: "OUTRO", duration: 4.0, color: .neuralTertiary, type: "title"),
    ]
}

// MARK: - Playback Speed

enum PlaybackSpeed: String, CaseIterable {
    case quarter = "0.25x"
    case half = "0.5x"
    case normal = "1x"
    case oneAndHalf = "1.5x"
    case double = "2x"
    case quad = "4x"

    var multiplier: Double {
        switch self {
        case .quarter: return 0.25
        case .half: return 0.5
        case .normal: return 1.0
        case .oneAndHalf: return 1.5
        case .double: return 2.0
        case .quad: return 4.0
        }
    }
}

#Preview {
    VideoEditorView()
        .environmentObject(NeuralOrchestrator.shared)
}
