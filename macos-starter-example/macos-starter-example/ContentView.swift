import SwiftUI

enum SidebarItem: String, CaseIterable, Identifiable {
    case chat = "Chat"
    case vision = "Vision"
    case audio = "Audio"
    case embeddings = "Embeddings"
    case rag = "RAG"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .chat: "message"
        case .vision: "eye"
        case .audio: "waveform"
        case .embeddings: "cube"
        case .rag: "magnifyingglass"
        }
    }
}

struct ContentView: View {
    @State private var selectedItem: SidebarItem? = .chat

    var body: some View {
        NavigationSplitView {
            List(SidebarItem.allCases, selection: $selectedItem) { item in
                Label(item.rawValue, systemImage: item.icon)
                    .tag(item)
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
        } detail: {
            switch selectedItem {
            case .chat:
                ModelLoadingContainer(
                    state: AiService.shared.chatState,
                    load: { await AiService.shared.loadChat() }
                ) {
                    ChatView()
                }
            case .vision:
                ModelLoadingContainer(
                    state: AiService.shared.visionHearingChatState,
                    load: { await AiService.shared.loadVisionHearingChat() }
                ) {
                    VisionView()
                }
            case .audio:
                ModelLoadingContainer(
                    state: AiService.shared.visionHearingChatState,
                    load: { await AiService.shared.loadVisionHearingChat() }
                ) {
                    AudioView()
                }
            case .embeddings:
                ModelLoadingContainer(
                    state: AiService.shared.encoderState,
                    load: { await AiService.shared.loadEncoder() }
                ) {
                    EmbeddingsView()
                }
            case .rag:
                RagLoadingContainer()
            case nil:
                Text("Select an item from the sidebar")
                    .foregroundStyle(.secondary)
            }
        }
        .frame(minWidth: 700, minHeight: 500)
    }
}

struct RagLoadingContainer: View {
    private var aiService = AiService.shared

    private var combinedState: ModelState {
        switch (aiService.encoderState, aiService.crossEncoderState) {
        case (.ready, .ready):
            return .ready
        case (.error(let msg), _), (_, .error(let msg)):
            return .error(msg)
        default:
            return .loading
        }
    }

    var body: some View {
        ModelLoadingContainer(
            state: combinedState,
            load: {
                async let e: Void = aiService.loadEncoder()
                async let c: Void = aiService.loadCrossEncoder()
                _ = await (e, c)
            }
        ) {
            RagView()
        }
    }
}

#Preview {
    ContentView()
}
