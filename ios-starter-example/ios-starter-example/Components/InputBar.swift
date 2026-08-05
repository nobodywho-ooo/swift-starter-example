import SwiftUI

struct InputBar: View {
    @Binding var text: String
    var isStreaming: Bool
    var onSend: () -> Void
    var onStop: () -> Void

    private var transcriber = TranscriptionManager.shared
    @FocusState private var isFocused: Bool

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

    private static let verticalPadding: CGFloat = 10
    private static let iconSize: CGFloat = 24
    private static let lineHeight: CGFloat = UIFont.preferredFont(forTextStyle: .body).lineHeight

    static var height: CGFloat {
        lineHeight > iconSize ? lineHeight : iconSize + verticalPadding * 2
    }

    var body: some View {
        HStack(spacing: 8) {
            micButton

            TextField(placeholder, text: $text, axis: .vertical)
                .lineLimit(1 ... 5)
                .padding(.vertical, Self.verticalPadding)
                .focused($isFocused)
                .disabled(isStreaming)

            if isStreaming {
                Button(action: onStop) {
                    Image(systemName: "stop.circle")
                        .font(.system(size: Self.iconSize))
                        .foregroundStyle(.red)
                }
            } else {
                Button {
                    isFocused = false
                    onSend()
                } label: {
                    let empty = text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    Text("Send")
                        .fontWeight(empty ? .semibold : .medium)
                        .foregroundStyle(empty ? .secondary : Color.accentColor)
                }
                .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(.horizontal, 12)
        .frame(minHeight: Self.height)
        .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 24))
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
        case .idle:
            Button(action: micTapped) {
                Image(systemName: "mic.fill")
                    .font(.system(size: Self.iconSize - 4))
                    .foregroundStyle(isStreaming ? Color.secondary : Color.accentColor)
            }
            .disabled(isStreaming)
        }
    }

    private func micTapped() {
        switch transcriber.phase {
        case .idle:
            isFocused = false
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
        InputBar(
            text: .constant(""),
            isStreaming: true,
            onSend: {},
            onStop: {}
        )
        .padding()
    }
}
