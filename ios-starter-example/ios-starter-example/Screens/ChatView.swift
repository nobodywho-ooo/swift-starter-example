import NobodyWho
import SwiftUI

struct ChatView: View {
    private let inputBarBottomPadding: CGFloat = 14
    private let contentExtraPadding: CGFloat = 16

    private var aiService = AiService.shared
    @State private var messages: [ChatMessage] = []
    @State private var inputText = ""
    @State private var isStreaming = false
    @State private var streamingTask: Task<Void, Never>?

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    if messages.isEmpty {
                        ContentUnavailableView {
                            VStack(spacing: 8) {
                                Image(systemName: "bubble.fill")
                                    .font(.system(size: 56))
                                    .foregroundStyle(Color(uiColor: .systemGray6))
                                Text("Start a chat").foregroundStyle(Color(uiColor: .gray))
                            }
                        }
                        .padding(.top, 150)
                    } else {
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
                        .padding(.bottom, InputBar.height + inputBarBottomPadding + contentExtraPadding)
                    }
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
                    .padding(.bottom, inputBarBottomPadding)
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
