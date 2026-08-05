import AVFoundation
import NobodyWho
import Observation

@Observable
final class TranscriptionManager {
    static let shared = TranscriptionManager()

    enum Phase: Equatable {
        case idle
        case recording
        case transcribing
    }

    private(set) var phase: Phase = .idle
    private(set) var errorMessage: String?

    @ObservationIgnored private var recorder: AVAudioRecorder?
    @ObservationIgnored private var recordingURL: URL?

    private init() {}

    func startRecording() async {
        guard phase == .idle else { return }
        errorMessage = nil

        guard await requestPermission() else {
            errorMessage = "Microphone access is needed to transcribe speech."
            return
        }

        do {
            try beginRecording()
            phase = .recording
        } catch {
            errorMessage = error.localizedDescription
            teardownRecording()
            phase = .idle
        }
    }

    func stopAndTranscribe() async -> String? {
        guard phase == .recording, let recorder, let url = recordingURL else { return nil }

        recorder.stop()
        self.recorder = nil
        phase = .transcribing

        defer {
            try? FileManager.default.removeItem(at: url)
            recordingURL = nil
            deactivateSession()
            phase = .idle
        }

        do {
            let stt = try await loadStt()
            let text = try await stt.transcribeFile(path: url.path).completed()
            let cleaned = Self.sanitize(text)
            return cleaned.isEmpty ? nil : cleaned
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }

    /// Strips Whisper's non-speech markers (e.g. `[BLANK_AUDIO]`, `[MUSIC]`,
    /// `[ Silence ]`) and normalizes the whitespace they leave behind.
    private static func sanitize(_ raw: String) -> String {
        raw
            .replacing(/\[[^\]]*\]/, with: " ")
            .replacing(/\s{2,}/, with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func cancel() {
        guard phase == .recording else { return }
        teardownRecording()
        phase = .idle
    }

    // MARK: - Recording

    private func beginRecording() throws {
        #if os(iOS)
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.record, mode: .measurement)
        try session.setActive(true)
        #endif

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("stt-\(UUID().uuidString).wav")

        // Mono 16 kHz 16-bit PCM — the format Whisper expects.
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 16_000,
            AVNumberOfChannelsKey: 1,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMIsBigEndianKey: false,
        ]

        let recorder = try AVAudioRecorder(url: url, settings: settings)
        guard recorder.record() else {
            throw TranscriptionError.recordingFailed
        }
        self.recorder = recorder
        recordingURL = url
    }

    private func teardownRecording() {
        recorder?.stop()
        recorder = nil
        if let url = recordingURL {
            try? FileManager.default.removeItem(at: url)
        }
        recordingURL = nil
        deactivateSession()
    }

    private func deactivateSession() {
        #if os(iOS)
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        #endif
    }

    // MARK: - Model

    private func loadStt() async throws -> STT {
        if let stt = AiService.shared.stt { return stt }
        await AiService.shared.loadStt()
        guard let stt = AiService.shared.stt else {
            throw TranscriptionError.modelUnavailable
        }
        return stt
    }

    // MARK: - Permission

    private func requestPermission() async -> Bool {
        #if os(iOS)
        return await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
        #else
        return await AVCaptureDevice.requestAccess(for: .audio)
        #endif
    }
}

private enum TranscriptionError: LocalizedError {
    case recordingFailed
    case modelUnavailable

    var errorDescription: String? {
        switch self {
        case .recordingFailed:
            return "Could not start recording from the microphone."
        case .modelUnavailable:
            return "The speech-to-text model could not be loaded."
        }
    }
}
