import SwiftUI

struct ModelLoadingContainer<Content: View>: View {
    var state: ModelState
    var load: () async -> Void
    @ViewBuilder var content: () -> Content

    var body: some View {
        switch state {
        case .notLoaded, .loading:
            LoadingView()
                .task { await load() }
        case .ready:
            content()
        case .error(let message):
            ErrorRetryView(message: message) {
                Task { await load() }
            }
        }
    }
}
