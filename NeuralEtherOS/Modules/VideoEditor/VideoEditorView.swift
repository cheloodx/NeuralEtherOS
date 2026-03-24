import SwiftUI

// MARK: - Video Editor View
// Neural Ether video editing module with timeline, effects, and export tools.

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

    enum VideoTool: String, CaseIterable {
        case timeline = "TIMELINE"
        case effects = "FX"
        case audio = "AUDIO"
        case export = "EXPORT"

        var icon: String {
            switch self {
            case .timeline: return "film"
            case .effects: return "sparkles"
            case .audio: return "waveform"
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
                Text("VIDEO_EDITOR")
                    .font(NeuralFont.headlineMedium())
                    .foregroundColor(.onSurface)

                Text("Neural cinematic processing engine")
                    .font(NeuralFont.monoSmall())
                    .foregroundColor(.onSurfaceVariant)
            }

            Spacer()

            // Duration badge
            Text(formatTime(totalDuration))
                .font(NeuralFont.monoSmall())
                .foregroundColor(.neuralPrimary)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.xs)
                .background(Color.neuralPrimary.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.full))
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
    }

    // MARK: - Preview

    private var previewSection: some View {
        ZStack {
            RoundedRectangle(cornerRadius: CornerRadius.lg)
                .fill(Color.surfaceContainerLowest)
                .overlay(
                    VStack(spacing: Spacing.lg) {
                        Image(systemName: "film.stack")
                            .font(.system(size: 44))
                            .foregroundColor(.onSurface.opacity(0.2))

                        Text("NEURAL_PREVIEW")
                            .font(NeuralFont.monoMedium())
                            .foregroundColor(.onSurfaceVariant)

                        HStack(spacing: Spacing.md) {
                            Text(formatTime(currentTime))
                                .font(NeuralFont.monoSmall())
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
                                Circle()
                                    .fill(Color.neuralError)
                                    .frame(width: 8, height: 8)
                                Text("PLAYING")
                                    .font(NeuralFont.monoSmall())
                                    .foregroundColor(.neuralError)
                            }
                        }
                    }
                )

            if isExporting {
                exportOverlay
            }
        }
        .aspectRatio(16/9, contentMode: .fit)
        .padding(.horizontal, Spacing.lg)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
    }

    private var exportOverlay: some View {
        ZStack {
            Color.surface.opacity(0.9)
            VStack(spacing: Spacing.md) {
                Text("EXPORTING_VIDEO")
                    .font(NeuralFont.monoMedium())
                    .foregroundColor(.neuralPrimary)

                ProgressView(value: exportProgress)
                    .tint(.neuralPrimary)
                    .frame(width: 200)

                Text("\(Int(exportProgress * 100))%")
                    .font(NeuralFont.monoSmall())
                    .foregroundColor(.onSurfaceVariant)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
    }

    // MARK: - Playback Controls

    private var playbackControls: some View {
        VStack(spacing: Spacing.md) {
            // Scrubber
            Slider(value: $currentTime, in: 0...totalDuration)
                .tint(.neuralPrimary)
                .padding(.horizontal, Spacing.lg)

            // Control buttons
            HStack(spacing: Spacing.xxl) {
                Button {
                    currentTime = max(0, currentTime - 5)
                } label: {
                    Image(systemName: "gobackward.5")
                        .font(.system(size: 20))
                        .foregroundColor(.onSurfaceVariant)
                }
                .buttonStyle(.plain)

                Button {
                    currentTime = 0
                } label: {
                    Image(systemName: "backward.end.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.onSurfaceVariant)
                }
                .buttonStyle(.plain)

                // Play/Pause
                Button {
                    togglePlayback()
                } label: {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.neuralPrimary)
                        .shadow(color: .neuralPrimary.opacity(0.4), radius: 8)
                }
                .buttonStyle(.plain)

                Button {
                    currentTime = totalDuration
                } label: {
                    Image(systemName: "forward.end.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.onSurfaceVariant)
                }
                .buttonStyle(.plain)

                Button {
                    currentTime = min(totalDuration, currentTime + 5)
                } label: {
                    Image(systemName: "goforward.5")
                        .font(.system(size: 20))
                        .foregroundColor(.onSurfaceVariant)
                }
                .buttonStyle(.plain)
            }

            // Speed selector
            HStack(spacing: Spacing.md) {
                ForEach(PlaybackSpeed.allCases, id: \.rawValue) { speed in
                    Button {
                        playbackSpeed = speed
                    } label: {
                        Text(speed.rawValue)
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .foregroundColor(playbackSpeed == speed ? .neuralPrimary : .onSurfaceVariant)
                            .padding(.horizontal, Spacing.sm)
                            .padding(.vertical, Spacing.xs)
                            .background(
                                playbackSpeed == speed
                                    ? Color.neuralPrimary.opacity(0.12)
                                    : Color.clear
                            )
                            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.sm))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.vertical, Spacing.md)
    }

    // MARK: - Tool Selector

    private var toolSelector: some View {
        HStack(spacing: 0) {
            ForEach(VideoTool.allCases, id: \.rawValue) { tool in
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
                    .padding(.vertical, Spacing.sm)
                    .background(
                        selectedTool == tool ? Color.neuralPrimary.opacity(0.08) : Color.clear
                    )
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, Spacing.lg)
    }

    // MARK: - Tool Panels

    @ViewBuilder
    private var toolPanel: some View {
        ScrollView {
            switch selectedTool {
            case .timeline:
                timelinePanel
            case .effects:
                videoEffectsPanel
            case .audio:
                audioPanel
            case .export:
                exportPanel
            }
        }
        .frame(maxHeight: 160)
    }

    // MARK: Timeline

    private var timelinePanel: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("CLIPS")
                .font(NeuralFont.monoSmall())
                .foregroundColor(.onSurfaceVariant)
                .tracking(1.5)
                .padding(.horizontal, Spacing.lg)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.sm) {
                    ForEach(Array(clips.enumerated()), id: \.element.id) { index, clip in
                        Button {
                            selectedClipIndex = index
                        } label: {
                            VStack(spacing: Spacing.xs) {
                                RoundedRectangle(cornerRadius: CornerRadius.sm)
                                    .fill(clip.color.opacity(0.3))
                                    .frame(width: CGFloat(clip.duration) * 8, height: 40)
                                    .overlay(
                                        Text(clip.name)
                                            .font(.system(size: 7, weight: .medium, design: .monospaced))
                                            .foregroundColor(.onSurface)
                                            .lineLimit(1)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: CornerRadius.sm)
                                            .stroke(
                                                selectedClipIndex == index ? Color.neuralPrimary : Color.outlineVariant.opacity(0.2),
                                                lineWidth: selectedClipIndex == index ? 2 : 1
                                            )
                                    )

                                Text(formatTime(clip.duration))
                                    .font(.system(size: 7, design: .monospaced))
                                    .foregroundColor(.onSurfaceVariant)
                            }
                        }
                        .buttonStyle(.plain)
                    }

                    // Add clip button
                    Button {
                        addClip()
                    } label: {
                        RoundedRectangle(cornerRadius: CornerRadius.sm)
                            .stroke(Color.outlineVariant.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [4]))
                            .frame(width: 50, height: 40)
                            .overlay(
                                Image(systemName: "plus")
                                    .font(.system(size: 16))
                                    .foregroundColor(.onSurfaceVariant.opacity(0.5))
                            )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, Spacing.lg)
            }
        }
        .padding(.vertical, Spacing.md)
    }

    // MARK: Video Effects

    private var videoEffectsPanel: some View {
        let effects = [
            ("SLOW_MO", "tortoise", Color.neuralPrimary),
            ("REVERSE", "arrow.uturn.backward", Color.neuralTertiary),
            ("GLITCH", "waveform.path.ecg", Color.neuralError),
            ("FADE_IN", "circle.lefthalf.filled", Color.neuralWarning),
            ("FADE_OUT", "circle.righthalf.filled", Color.neuralWarning),
            ("ZOOM_IN", "plus.magnifyingglass", Color.neuralSuccess),
        ]

        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: Spacing.md),
            GridItem(.flexible(), spacing: Spacing.md),
            GridItem(.flexible(), spacing: Spacing.md)
        ], spacing: Spacing.md) {
            ForEach(Array(effects.enumerated()), id: \.offset) { _, effect in
                Button {
                    applyVideoEffect(effect.0)
                } label: {
                    VStack(spacing: Spacing.sm) {
                        Image(systemName: effect.1)
                            .font(.system(size: 20))
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

    // MARK: Audio

    private var audioPanel: some View {
        VStack(spacing: Spacing.lg) {
            // Volume control
            VStack(alignment: .leading, spacing: Spacing.sm) {
                HStack {
                    Image(systemName: "speaker.wave.2")
                        .font(.system(size: 14))
                        .foregroundColor(.neuralPrimary)
                    Text("MASTER_VOLUME")
                        .font(NeuralFont.monoSmall())
                        .foregroundColor(.onSurfaceVariant)
                    Spacer()
                    Text("100%")
                        .font(NeuralFont.monoSmall())
                        .foregroundColor(.neuralPrimary)
                }
                Slider(value: .constant(1.0), in: 0...1)
                    .tint(.neuralPrimary)
            }

            // Audio tracks
            VStack(alignment: .leading, spacing: Spacing.md) {
                Text("AUDIO_TRACKS")
                    .font(NeuralFont.monoSmall())
                    .foregroundColor(.onSurfaceVariant)
                    .tracking(1.5)

                audioTrackRow(name: "ORIGINAL_AUDIO", icon: "waveform", color: .neuralPrimary, active: true)
                audioTrackRow(name: "NEURAL_BGM", icon: "music.note", color: .neuralTertiary, active: false)
                audioTrackRow(name: "SFX_LAYER", icon: "speaker.wave.3", color: .neuralWarning, active: false)
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
    }

    private func audioTrackRow(name: String, icon: String, color: Color, active: Bool) -> some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(color)
                .frame(width: 20)

            Text(name)
                .font(NeuralFont.monoSmall())
                .foregroundColor(.onSurface)

            Spacer()

            Text(active ? "ACTIVE" : "OFF")
                .font(.system(size: 8, weight: .medium, design: .monospaced))
                .foregroundColor(active ? .neuralSuccess : .onSurfaceVariant)
                .padding(.horizontal, Spacing.sm)
                .padding(.vertical, 2)
                .background((active ? Color.neuralSuccess : Color.surfaceContainerHighest).opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.full))
        }
        .padding(.vertical, Spacing.xs)
    }

    // MARK: Export

    private var exportPanel: some View {
        VStack(spacing: Spacing.lg) {
            let formats = [
                ("MP4", "4K • H.265", Color.neuralPrimary),
                ("MOV", "ProRes 422", Color.neuralTertiary),
                ("WEBM", "VP9 • Web", Color.neuralSuccess),
            ]

            ForEach(Array(formats.enumerated()), id: \.offset) { _, format in
                Button {
                    startExport(format: format.0)
                } label: {
                    HStack(spacing: Spacing.md) {
                        Image(systemName: "doc.fill")
                            .font(.system(size: 18))
                            .foregroundColor(format.2)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(format.0)
                                .font(NeuralFont.headlineSmall())
                                .foregroundColor(.onSurface)
                            Text(format.1)
                                .font(NeuralFont.monoSmall())
                                .foregroundColor(.onSurfaceVariant)
                        }

                        Spacer()

                        Image(systemName: "arrow.down.circle")
                            .font(.system(size: 18))
                            .foregroundColor(format.2)
                    }
                    .padding(Spacing.md)
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

    private func togglePlayback() {
        isPlaying.toggle()
        if isPlaying {
            simulatePlayback()
        }
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
        let newClip = VideoClip(
            name: "CLIP_\(clips.count + 1)",
            duration: Double.random(in: 3...8),
            color: [Color.neuralPrimary, .neuralTertiary, .neuralWarning, .neuralSuccess].randomElement() ?? .neuralPrimary
        )
        clips.append(newClip)
        totalDuration = clips.reduce(0) { $0 + $1.duration }

        orchestrator.systemLogs.insert(
            LogEntry(
                timestamp: Date(),
                level: .info,
                module: "VIDEO",
                message: "CLIP_ADDED: \(newClip.name) — Duration: \(formatTime(newClip.duration))"
            ),
            at: 0
        )
    }

    private func applyVideoEffect(_ name: String) {
        orchestrator.systemLogs.insert(
            LogEntry(
                timestamp: Date(),
                level: .info,
                module: "VIDEO",
                message: "EFFECT_APPLIED: \(name) — Neural rendering pipeline active."
            ),
            at: 0
        )
    }

    private func startExport(format: String) {
        isExporting = true
        exportProgress = 0.0

        orchestrator.systemLogs.insert(
            LogEntry(
                timestamp: Date(),
                level: .info,
                module: "VIDEO",
                message: "EXPORT_STARTED — Format: \(format), Duration: \(formatTime(totalDuration))"
            ),
            at: 0
        )

        simulateExport()
    }

    private func simulateExport() {
        guard isExporting && exportProgress < 1.0 else {
            if exportProgress >= 1.0 {
                isExporting = false
                orchestrator.systemLogs.insert(
                    LogEntry(
                        timestamp: Date(),
                        level: .info,
                        module: "VIDEO",
                        message: "EXPORT_COMPLETE — Video saved to Neural Vault."
                    ),
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

struct VideoClip: Identifiable {
    let id = UUID()
    let name: String
    let duration: Double
    let color: Color

    static let sampleClips: [VideoClip] = [
        VideoClip(name: "INTRO", duration: 5.0, color: .neuralPrimary),
        VideoClip(name: "SCENE_1", duration: 8.0, color: .neuralTertiary),
        VideoClip(name: "TRANSITION", duration: 2.0, color: .neuralWarning),
        VideoClip(name: "SCENE_2", duration: 10.0, color: .neuralSuccess),
        VideoClip(name: "OUTRO", duration: 5.0, color: .neuralPrimary),
    ]
}

// MARK: - Playback Speed

enum PlaybackSpeed: String, CaseIterable {
    case quarter = "0.25x"
    case half = "0.5x"
    case normal = "1x"
    case double = "2x"
    case quad = "4x"

    var multiplier: Double {
        switch self {
        case .quarter: return 0.25
        case .half: return 0.5
        case .normal: return 1.0
        case .double: return 2.0
        case .quad: return 4.0
        }
    }
}

#Preview {
    VideoEditorView()
        .environmentObject(NeuralOrchestrator.shared)
}
