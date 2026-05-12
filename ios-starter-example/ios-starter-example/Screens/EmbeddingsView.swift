import NobodyWho
import SwiftUI

private let documents = [
    "Python supports multiple programming paradigms including object-oriented and functional",
    "JavaScript is primarily used for web development and runs in browsers",
    "SQL is a domain-specific language for managing relational databases",
    "Git is a version control system for tracking changes in source code",
]

private let query = "What language should I use for database queries?"

struct EmbeddingsView: View {
    private var aiService = AiService.shared
    @State private var isProcessing = false
    @State private var bestMatch = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Example")
                    .font(.title3)
                    .bold()

                ForEach(documents, id: \.self) { doc in
                    Text(doc)
                        .foregroundStyle(.secondary)
                }

                Button(isProcessing ? "Running..." : "Run Embeddings") {
                    Task { await runEmbeddings() }
                }
                .buttonStyle(.bordered)
                .disabled(isProcessing)

                if isProcessing && bestMatch.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else if !bestMatch.isEmpty {
                    Text("Query: \(query)")
                        .italic()
                    Text("Best match: \(bestMatch)")
                }
            }
            .padding()
        }
        .navigationTitle("Embeddings")
    }

    private func runEmbeddings() async {
        guard let encoder = aiService.encoder else { return }

        bestMatch = ""
        isProcessing = true
        defer { isProcessing = false }

        do {
            var docEmbeddings: [[Float]] = []
            for doc in documents {
                try docEmbeddings.append(await encoder.encode(doc))
            }

            let queryEmbedding = try await encoder.encode(query)

            var maxSimilarity: Float = -1
            var bestIdx = 0
            for (i, docEmbedding) in docEmbeddings.enumerated() {
                let similarity = cosineSimilarity(a: queryEmbedding, b: docEmbedding)
                if similarity > maxSimilarity {
                    maxSimilarity = similarity
                    bestIdx = i
                }
            }
            bestMatch = documents[bestIdx]
        } catch {
            print("EmbeddingsView error: \(error)")
        }
    }
}

#Preview {
    NavigationStack {
        EmbeddingsView()
    }
}
