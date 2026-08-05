import SwiftUI

enum MessageRole {
    case user
    case assistant
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let role: MessageRole
    var content: String
}

struct MessageListItem: View {
    let message: ChatMessage
    var isStreaming: Bool = false

    var body: some View {
        switch message.role {
        case .user:
            HStack {
                Spacer(minLength: 60)
                Text(message.content)
                    .padding(12)
                    .background(Color(nsColor: .controlBackgroundColor))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        case .assistant:
            VStack(alignment: .leading, spacing: 0) {
                MarkdownTextView(text: message.content)
                if !isStreaming {
                    SpeakerButton(message: message)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct SpeakerButton: View {
    let message: ChatMessage
    var speech = SpeechManager.shared

    var body: some View {
        Button {
            speech.toggle(message)
        } label: {
            Group {
                if speech.isPreparing(message.id) {
                    ProgressView()
                        .controlSize(.small)
                } else {
                    Image(systemName: speech.isPlaying(message.id) ? "stop.circle.fill" : "speaker.wave.2.fill")
                }
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
            .frame(width: 28, height: 14, alignment: .leading)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(speech.isPlaying(message.id) ? "Stop speaking message" : "Speak message")
    }
}

#Preview {
    VStack(spacing: 12) {
        MessageListItem(message: ChatMessage(role: .user, content: "Hello!"))
        MessageListItem(message: ChatMessage(role: .assistant, content: "Hi there! How can I help you today?"))
    }
    .padding()
}
