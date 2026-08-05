import SwiftUI

struct InputBar: View {
    @Binding var text: String
    var isStreaming: Bool
    var onSend: () -> Void
    var onStop: () -> Void

    private var transcriber = TranscriptionManager.shared

    // Explicit init: the private `transcriber` property would otherwise make the
    // synthesized memberwise initializer private and inaccessible to callers.
    init(
        text: Binding<String>,
        isStreaming: Bool,
        onSend: @escaping () -> Void,
        onStop: @escaping () -> Void
    ) {
        _text = text
        self.isStreaming = isStreaming
        self.onSend = onSend
        self.onStop = onStop
    }

    private static let iconSize: CGFloat = 20

    var body: some View {
        HStack(spacing: 8) {
            micButton

            TextField(placeholder, text: $text, axis: .vertical)
                .lineLimit(1 ... 5)
                .textFieldStyle(.plain)
                .padding(.vertical, 14)
                .disabled(isStreaming)
                .onSubmit {
                    if !isStreaming && !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        onSend()
                    }
                }

            if isStreaming {
                Button(action: onStop) {
                    Image(systemName: "stop.circle")
                        .font(.system(size: Self.iconSize))
                        .foregroundStyle(.red)
                }
                .buttonStyle(.plain)
            } else {
                Button(action: onSend) {
                    let empty = text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    Text("Send")
                        .fontWeight(empty ? .semibold : .medium)
                        .foregroundStyle(empty ? .secondary : Color.accentColor)
                }
                .buttonStyle(.plain)
                .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(.horizontal, 12)
        .frame(minHeight: 36)
        .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal, 16)
    }

    // MARK: - Microphone / speech-to-text

    private var placeholder: String {
        switch transcriber.phase {
        case .recording: return "Listening…"
        case .transcribing: return "Transcribing…"
        case .idle: return isStreaming ? "Thinking..." : "Ask something..."
        }
    }

    @ViewBuilder
    private var micButton: some View {
        switch transcriber.phase {
        case .transcribing:
            ProgressView()
                .controlSize(.small)
                .frame(width: Self.iconSize, height: Self.iconSize)
        case .recording:
            Button(action: micTapped) {
                Image(systemName: "stop.circle.fill")
                    .font(.system(size: Self.iconSize))
                    .foregroundStyle(.red)
                    .symbolEffect(.pulse, options: .repeating)
            }
            .buttonStyle(.plain)
        case .idle:
            Button(action: micTapped) {
                Image(systemName: "mic.fill")
                    .font(.system(size: Self.iconSize - 3))
                    .foregroundStyle(isStreaming ? Color.secondary : Color.accentColor)
            }
            .buttonStyle(.plain)
            .disabled(isStreaming)
        }
    }

    private func micTapped() {
        switch transcriber.phase {
        case .idle:
            Task { await transcriber.startRecording() }
        case .recording:
            Task {
                if let transcript = await transcriber.stopAndTranscribe() {
                    appendTranscript(transcript)
                }
            }
        case .transcribing:
            break
        }
    }

    private func appendTranscript(_ transcript: String) {
        let existing = text.trimmingCharacters(in: .whitespacesAndNewlines)
        text = existing.isEmpty ? transcript : existing + " " + transcript
    }
}

#Preview {
    VStack {
        InputBar(
            text: .constant(""),
            isStreaming: false,
            onSend: {},
            onStop: {}
        )
        .padding()
        InputBar(
            text: .constant("Hello"),
            isStreaming: false,
            onSend: {},
            onStop: {}
        )
        .padding()
    }
}
