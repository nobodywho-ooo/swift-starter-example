import SwiftUI

struct ErrorRetryView: View {
    var message: String
    var onRetry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text(message)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Try again", action: onRetry)
                .buttonStyle(.bordered)
        }
        .padding()
    }
}

#Preview {
    ErrorRetryView(message: "Something went wrong.") {}
}
