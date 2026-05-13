import NobodyWho
import SwiftUI

struct VisionView: View {
    private var aiService = AiService.shared
    @State private var result = ""
    @State private var isStreaming = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    BundleImage("image-1")
                    BundleImage("image-2")
                }
                .frame(maxWidth: 600, maxHeight: 300)

                Text("Analyze & Describe")
                    .font(.title3)
                    .bold()
                Text("Find out what the model can see in the images.")
                    .foregroundStyle(.secondary)

                Button(isStreaming ? "Analyzing..." : "Analyze") {
                    Task { await analyse() }
                }
                .buttonStyle(.bordered)
                .disabled(isStreaming)

                if isStreaming && result.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else if !result.isEmpty {
                    MarkdownTextView(text: result)
                }
            }
            .padding()
        }
        .navigationTitle("Vision")
    }

    private func analyse() async {
        guard let chat = aiService.visionHearingChat else { return }
        guard let image1Path = Bundle.main.path(forResource: "image-1", ofType: "png"),
              let image2Path = Bundle.main.path(forResource: "image-2", ofType: "png") else { return }

        result = ""
        isStreaming = true
        defer { isStreaming = false }

        let prompt = Prompt([
            Prompt.text("Tell me what you see in the first image."),
            Prompt.image(image1Path),
            Prompt.text("Also tell me what you see in the second image."),
            Prompt.image(image2Path),
        ])
        for await token in chat.ask(prompt) {
            result += token
        }
    }
}

private struct BundleImage: View {
    let name: String

    init(_ name: String) {
        self.name = name
    }

    var body: some View {
        if let path = Bundle.main.path(forResource: name, ofType: "png"),
           let nsImage = NSImage(contentsOfFile: path)
        {
            Image(nsImage: nsImage)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

#Preview {
    VisionView()
}
