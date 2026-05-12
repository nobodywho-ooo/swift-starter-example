import SwiftUI

struct MoreView: View {
    private var aiService = AiService.shared

    var body: some View {
        NavigationStack {
            List {
                ListItem(
                    title: "Embeddings",
                    subtitle: "Use embeddings to find the relevant documents",
                    iconName: "document.fill",
                    iconBackgroundColor: .blue,
                    disabled: aiService.encoderState != .ready,
                    isLoading: aiService.encoderState == .loading
                ) {
                }
                .listRowSeparator(.hidden, edges: .top)

                ListItem(
                    title: "RAG",
                    subtitle: "Demonstrate a two-stage retrieval system using RAG",
                    iconName: "magnifyingglass",
                    iconBackgroundColor: .teal,
                    disabled: aiService.crossEncoderState != .ready,
                    isLoading: aiService.crossEncoderState == .loading
                ) {
                }
                .listRowSeparator(.hidden, edges: .bottom)
            }
            .listStyle(.plain)
            .navigationTitle("More")
            .task {
                async let _ = aiService.loadEncoder()
                async let _ = aiService.loadCrossEncoder()
            }
        }
    }
}

#Preview {
    MoreView()
}
