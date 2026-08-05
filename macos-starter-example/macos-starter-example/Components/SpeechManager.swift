import AVFoundation
import NobodyWho
import Observation

@Observable
final class SpeechManager {
    static let shared = SpeechManager()

    /// Message currently being prepared (model loading + synthesizing).
    private(set) var preparingMessageId: UUID?
    /// Message currently playing back.
    private(set) var playingMessageId: UUID?

    @ObservationIgnored private var player: AVAudioPlayer?
    @ObservationIgnored private var playerDelegate: AudioPlayerDelegate?
    @ObservationIgnored private var task: Task<Void, Never>?

    private init() {}

    func isPreparing(_ id: UUID) -> Bool { preparingMessageId == id }
    func isPlaying(_ id: UUID) -> Bool { playingMessageId == id }

    /// Speaks the message, or stops if it is already the active one.
    func toggle(_ message: ChatMessage) {
        if preparingMessageId == message.id || playingMessageId == message.id {
            stop()
        } else {
            speak(message)
        }
    }

    func stop() {
        task?.cancel()
        task = nil
        player?.stop()
        player = nil
        playerDelegate = nil
        preparingMessageId = nil
        playingMessageId = nil
    }

    private func speak(_ message: ChatMessage) {
        stop()

        let id = message.id
        let text = message.content
        preparingMessageId = id

        task = Task {
            do {
                let tts = try await loadTts()
                try Task.checkCancellation()
                let wav = try await tts.synthesize(text)
                try Task.checkCancellation()
                try play(wav, id: id)
            } catch is CancellationError {
                // Superseded or explicitly stopped; state already reset.
            } catch {
                if preparingMessageId == id { preparingMessageId = nil }
            }
        }
    }

    private func loadTts() async throws -> Tts {
        if let tts = AiService.shared.tts { return tts }
        await AiService.shared.loadTts()
        guard let tts = AiService.shared.tts else {
            throw SpeechError.modelUnavailable
        }
        return tts
    }

    private func play(_ wav: Data, id: UUID) throws {
        let player = try AVAudioPlayer(data: wav)
        let delegate = AudioPlayerDelegate { [weak self] in
            self?.playbackFinished(id: id)
        }
        player.delegate = delegate
        self.player = player
        self.playerDelegate = delegate

        preparingMessageId = nil
        playingMessageId = id
        player.play()
    }

    private func playbackFinished(id: UUID) {
        guard playingMessageId == id else { return }
        player = nil
        playerDelegate = nil
        playingMessageId = nil
    }
}

private enum SpeechError: LocalizedError {
    case modelUnavailable

    var errorDescription: String? {
        switch self {
        case .modelUnavailable:
            return "The text-to-speech model could not be loaded."
        }
    }
}

/// Retains and forwards `AVAudioPlayer` completion (its `delegate` is weak).
private final class AudioPlayerDelegate: NSObject, AVAudioPlayerDelegate {
    private let onFinish: () -> Void

    init(onFinish: @escaping () -> Void) {
        self.onFinish = onFinish
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        onFinish()
    }
}
