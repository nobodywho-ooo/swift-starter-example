import NobodyWho
import SwiftUI

struct ChatView: View {
    private var aiService = AiService.shared
    @State private var messages: [ChatMessage] = []
    @State private var inputText = ""
    @State private var isStreaming = false
    @State private var streamingTask: Task<Void, Never>?

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(messages) { message in
                            if message.content.isEmpty {
                                ProgressView()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .id(message.id)
                            } else {
                                MessageListItem(message: message)
                                    .id(message.id)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, InputBar.height + 32)
                }
                .onChange(of: messages.last?.content) {
                    withAnimation {
                        proxy.scrollTo(messages.last?.id, anchor: .bottom)
                    }
                }
                .overlay(alignment: .bottom) {
                    InputBar(
                        text: $inputText,
                        isStreaming: isStreaming,
                        onSend: send,
                        onStop: stopStreaming
                    )
                    .padding(.bottom, 14)
                }
            }
            .navigationTitle("Chat")
            .contentMargins(.bottom, 0, for: .scrollIndicators)
        }
    }

    private func send() {
        let userInput = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !userInput.isEmpty, !isStreaming else { return }
        guard let chat = aiService.chat else { return }

        let userMessage = ChatMessage(role: .user, content: userInput)
        let assistantMessage = ChatMessage(role: .assistant, content: "")
        messages.append(userMessage)
        messages.append(assistantMessage)
        inputText = ""
        isStreaming = true

        streamingTask = Task {
            defer { isStreaming = false }

            var accumulated = ""
            let prompt = Prompt([Prompt.text(userInput)])

            for await token in chat.ask(prompt) {
                if Task.isCancelled { break }
                accumulated += token
                if let lastIndex = messages.indices.last {
                    messages[lastIndex].content = accumulated
                }
            }
        }
    }

    private func stopStreaming() {
        streamingTask?.cancel()
        streamingTask = nil
    }
}

#Preview {
    ChatView()
}
