import Foundation
import NobodyWho
import Observation

enum ModelState: Equatable {
    case notLoaded
    case loading
    case ready
    case error(String)
}

@Observable
final class AiService {
    static let shared = AiService()

    private(set) var chatState: ModelState = .notLoaded
    private(set) var toolCallingChatState: ModelState = .notLoaded
    private(set) var visionHearingChatState: ModelState = .notLoaded
    private(set) var encoderState: ModelState = .notLoaded
    private(set) var crossEncoderState: ModelState = .notLoaded

    private(set) var chat: Chat?
    private(set) var toolCallingChat: Chat?
    private(set) var visionHearingChat: Chat?
    private(set) var encoder: Encoder?
    private(set) var crossEncoder: CrossEncoder?

    private enum Slot: Hashable {
        case chat, toolCallingChat, visionHearingChat, encoder, crossEncoder
    }

    private var loading: Set<Slot> = []

    private enum ModelFile {
        static let chat = "chat-model.gguf"
        static let projection = "projection-model.gguf"
        static let embedding = "embedding-model.gguf"
        static let reranker = "reranker-model.gguf"
    }

    private init() {}

    // MARK: - Chat

    func loadChat(
        useGpu: Bool = true,
        systemPrompt: String? = nil,
        sampler: SamplerConfig? = nil,
        contextSize: UInt32 = 4096
    ) async {
        guard chatState != .ready, loading.insert(.chat).inserted else { return }
        chatState = .loading

        do {
            let path = try bundlePath(for: ModelFile.chat)
            chat = try await Chat.fromPath(
                modelPath: path,
                useGpu: useGpu,
                systemPrompt: systemPrompt,
                contextSize: contextSize,
                sampler: sampler
            )
            chatState = .ready
        } catch {
            chatState = .error(error.localizedDescription)
        }

        loading.remove(.chat)
    }

    // MARK: - Tool-calling chat

    func loadToolCallingChat(
        useGpu: Bool = true,
        tools: [Tool] = [],
        systemPrompt: String? = nil,
        sampler: SamplerConfig? = nil,
        contextSize: UInt32 = 4096
    ) async {
        guard toolCallingChatState != .ready, loading.insert(.toolCallingChat).inserted else { return }
        toolCallingChatState = .loading

        do {
            let path = try bundlePath(for: ModelFile.chat)
            toolCallingChat = try await Chat.fromPath(
                modelPath: path,
                useGpu: useGpu,
                systemPrompt: systemPrompt,
                contextSize: contextSize,
                tools: tools,
                sampler: sampler
            )
            toolCallingChatState = .ready
        } catch {
            toolCallingChatState = .error(error.localizedDescription)
        }

        loading.remove(.toolCallingChat)
    }

    // MARK: - Vision + hearing chat

    func loadVisionHearingChat(
        useGpu: Bool = true,
        systemPrompt: String? = nil,
        contextSize: UInt32 = 4096
    ) async {
        guard visionHearingChatState != .ready, loading.insert(.visionHearingChat).inserted else { return }
        visionHearingChatState = .loading

        do {
            let modelPath = try bundlePath(for: ModelFile.chat)
            let projectionPath = try bundlePath(for: ModelFile.projection)
            let model = try await Model.load(
                modelPath: modelPath,
                useGpu: useGpu,
                projectionModelPath: projectionPath
            )
            visionHearingChat = Chat(
                model: model,
                systemPrompt: systemPrompt,
                contextSize: contextSize
            )
            visionHearingChatState = .ready
        } catch {
            visionHearingChatState = .error(error.localizedDescription)
        }

        loading.remove(.visionHearingChat)
    }

    // MARK: - Encoder (embeddings)

    func loadEncoder(
        useGpu: Bool = true,
        contextSize: UInt32? = nil
    ) async {
        guard encoderState != .ready, loading.insert(.encoder).inserted else { return }
        encoderState = .loading

        do {
            let path = try bundlePath(for: ModelFile.embedding)
            encoder = try await Encoder.fromPath(
                modelPath: path,
                useGpu: useGpu,
                contextSize: contextSize
            )
            encoderState = .ready
        } catch {
            encoderState = .error(error.localizedDescription)
        }

        loading.remove(.encoder)
    }

    // MARK: - Cross-encoder (reranker)

    func loadCrossEncoder(
        useGpu: Bool = true,
        contextSize: UInt32? = nil
    ) async {
        guard crossEncoderState != .ready, loading.insert(.crossEncoder).inserted else { return }
        crossEncoderState = .loading

        do {
            let path = try bundlePath(for: ModelFile.reranker)
            crossEncoder = try await CrossEncoder.fromPath(
                modelPath: path,
                useGpu: useGpu,
                contextSize: contextSize
            )
            crossEncoderState = .ready
        } catch {
            crossEncoderState = .error(error.localizedDescription)
        }

        loading.remove(.crossEncoder)
    }

    // MARK: - Dispose

    func dispose() {
        chat = nil
        toolCallingChat = nil
        visionHearingChat = nil
        encoder = nil
        crossEncoder = nil
        loading.removeAll()
        chatState = .notLoaded
        toolCallingChatState = .notLoaded
        visionHearingChatState = .notLoaded
        encoderState = .notLoaded
        crossEncoderState = .notLoaded
    }

    // MARK: - Helpers

    private func bundlePath(for fileName: String) throws -> String {
        guard let path = Bundle.main.path(forResource: fileName, ofType: nil) else {
            throw AiServiceError.modelNotFound(fileName)
        }
        return path
    }
}

enum AiServiceError: LocalizedError {
    case modelNotFound(String)

    var errorDescription: String? {
        switch self {
        case .modelNotFound(let name):
            return "Model file '\(name)' not found in app bundle."
        }
    }
}
