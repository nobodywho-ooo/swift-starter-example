import SwiftUI

struct MoreView: View {
    @State private var path = NavigationPath()

    private var aiService = AiService.shared

    private var isEncoderDisabled: Bool { aiService.encoderState != .ready }
    private var isEncoderLoading: Bool { aiService.encoderState == .loading }

    private var isRagDisabled: Bool { aiService.crossEncoderState != .ready || aiService.encoderState != .ready }
    private var isRagLoading: Bool { aiService.crossEncoderState == .loading || aiService.encoderState == .loading }

    var body: some View {
        NavigationStack(path: $path) {
            List {
                ListItem(
                    title: "Embeddings",
                    subtitle: "Use embeddings to find the relevant documents",
                    iconName: "document.fill",
                    iconBackgroundColor: .blue,
                    disabled: isEncoderDisabled,
                    isLoading: isEncoderLoading
                ) {
                    path.append("embeddings")
                }
                .listRowSeparator(.hidden, edges: .top)

                ListItem(
                    title: "RAG",
                    subtitle: "Demonstrate a two-stage retrieval system using RAG",
                    iconName: "magnifyingglass",
                    iconBackgroundColor: .teal,
                    disabled: isRagDisabled,
                    isLoading: isRagLoading
                ) {
                    path.append("rag")
                }
                .listRowSeparator(.hidden, edges: .bottom)
            }
            .listStyle(.plain)
            .navigationTitle("More")
            .navigationDestination(for: String.self) { route in
                switch route {
                case "embeddings":
                    EmbeddingsView()
                case "rag":
                    RagView()
                default:
                    EmptyView()
                }
            }
            .onAppear {
                Task { await aiService.loadEncoder() }
                Task { await aiService.loadCrossEncoder() }
            }
        }
    }
}

#Preview {
    MoreView()
}
