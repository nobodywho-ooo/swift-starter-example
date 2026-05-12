import NobodyWho
import SwiftUI

struct AudioView: View {
    private var aiService = AiService.shared
    @State private var result = ""
    @State private var isStreaming = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Transcribe audio.mp3")
                        .foregroundStyle(.secondary)
                    
                    Button(isStreaming ? "Getting speech..." : "Get speech") {
                        Task { await transcribe() }
                    }
                    .buttonStyle(.bordered)
                    .disabled(isStreaming)
                    
                    if isStreaming && result.isEmpty {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else if !result.isEmpty {
                        Text(result)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }
            .navigationTitle("Audio")
        }
    }

    private func transcribe() async {
        guard let chat = aiService.visionHearingChat else { return }
        guard let audioPath = Bundle.main.path(forResource: "audio", ofType: "mp3") else { return }

        result = ""
        isStreaming = true
        defer { isStreaming = false }

        let prompt = Prompt([
            Prompt.text("Tell me what you hear in the audio. Transcribe"),
            Prompt.audio(audioPath),
        ])
        for await token in chat.ask(prompt) {
            result += token
        }
    }
}

#Preview {
    AudioView()
}
