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

    var body: some View {
        switch message.role {
        case .user:
            HStack {
                Spacer(minLength: 60)
                Text(message.content)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        case .assistant:
            HStack {
                MarkdownTextView(text: message.content)
            }
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        MessageListItem(message: ChatMessage(role: .user, content: "Hello!"))
        MessageListItem(message: ChatMessage(role: .assistant, content: "Hi there! How can I help you today? I'm an helpful assistant."))
    }
    .padding()
}
