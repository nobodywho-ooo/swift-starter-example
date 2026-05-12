import NobodyWho
import SwiftUI

private let knowledgeBase = [
    "Python supports multiple programming paradigms including object-oriented and functional",
    "JavaScript is primarily used for web development and runs in browsers",
    "SQL is a domain-specific language for managing relational databases",
    "Git is a version control system for tracking changes in source code",
    "NumPy is a Python library for numerical computing and array operations",
    "Pandas is a Python library for data manipulation and analysis",
    "Matplotlib is a Python plotting library for creating static visualizations",
    "Seaborn builds on Matplotlib for statistical data visualization in Python",
    "scikit-learn is a Python library for classical machine learning algorithms",
    "TensorFlow is an end-to-end open-source platform for machine learning",
    "PyTorch is a deep learning framework widely used in research",
    "React is a JavaScript library for building user interfaces",
    "Node.js lets developers run JavaScript on the server side",
    "TypeScript adds optional static typing to JavaScript",
    "Docker packages applications and dependencies into portable containers",
    "Kubernetes orchestrates containerized applications at scale",
    "PostgreSQL is a powerful open-source relational database",
    "Redis is an in-memory data store used as a cache and message broker",
    "GraphQL is a query language for APIs that lets clients request exact data",
    "Rust is a systems programming language focused on safety and performance",
    "Go is a compiled language designed for concurrent network services",
    "Linux is an open-source operating system kernel used across servers",
]

private let query = "What Python libraries are best for data analysis?"

struct RagView: View {
    private var aiService = AiService.shared
    @State private var isProcessing = false
    @State private var topResults: [String] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Query: \(query)")
                    .italic()

                Button(isProcessing ? "Running..." : "Run RAG") {
                    Task { await runRag() }
                }
                .buttonStyle(.bordered)
                .disabled(isProcessing)

                if isProcessing && topResults.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else if !topResults.isEmpty {
                    Text("Top matches:")
                        .bold()
                    ForEach(Array(topResults.enumerated()), id: \.offset) { index, doc in
                        Text("\(index + 1). \(doc)")
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 12)
        .navigationTitle("RAG")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func runRag() async {
        guard let encoder = aiService.encoder,
              let crossEncoder = aiService.crossEncoder else { return }

        topResults = []
        isProcessing = true
        defer { isProcessing = false }

        do {
            var docEmbeddings: [[Float]] = []
            for doc in knowledgeBase {
                try docEmbeddings.append(await encoder.encode(doc))
            }

            let queryEmbedding = try await encoder.encode(query)

            var similarities: [(doc: String, score: Float)] = []
            for (i, docEmbedding) in docEmbeddings.enumerated() {
                let score = cosineSimilarity(a: queryEmbedding, b: docEmbedding)
                similarities.append((knowledgeBase[i], score))
            }
            similarities.sort { $0.score > $1.score }
            let candidateDocs = similarities.prefix(20).map(\.doc)

            let ranked = try await crossEncoder.rankAndSort(
                query: query,
                documents: candidateDocs
            )

            topResults = ranked.prefix(3).map(\.0)
        } catch {
            print("RagView error: \(error)")
        }
    }
}

#Preview {
    NavigationStack {
        RagView()
    }
}
