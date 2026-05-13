import SwiftUI

struct InputBar: View {
    @Binding var text: String
    var isStreaming: Bool
    var onSend: () -> Void
    var onStop: () -> Void

    private static let verticalPadding: CGFloat = 10
    private static let iconSize: CGFloat = 24
    private static let lineHeight: CGFloat = UIFont.preferredFont(forTextStyle: .body).lineHeight

    static var height: CGFloat {
        lineHeight > iconSize ? lineHeight : iconSize + verticalPadding * 2
    }

    var body: some View {
        HStack(spacing: 8) {
            TextField(isStreaming ? "Thinking..." : "Ask something...", text: $text, axis: .vertical)
                .lineLimit(1 ... 5)
                .padding(.horizontal, 12)
                .padding(.vertical, Self.verticalPadding)
                .disabled(isStreaming)

            if isStreaming {
                Button(action: onStop) {
                    Image(systemName: "stop.circle")
                        .font(.system(size: Self.iconSize))
                        .foregroundStyle(.red)
                }
            } else {
                Button(action: onSend) {
                    Text("Send")
                        .fontWeight(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .semibold : .medium)
                        .foregroundStyle(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .secondary : Color.accentColor)
                }
                .disabled(text.isEmpty)
            }
        }
        .padding(.horizontal, 12)
        .frame(minHeight: Self.height)
        .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 24))
        .padding(.horizontal, 16)
    }
}

#Preview {
    VStack {
        InputBar(
            text: .constant(""),
            isStreaming: false,
            onSend: {},
            onStop: {}
        )
        .padding()
        InputBar(
            text: .constant("Hello"),
            isStreaming: false,
            onSend: {},
            onStop: {}
        )
        .padding()
        InputBar(
            text: .constant(""),
            isStreaming: true,
            onSend: {},
            onStop: {}
        )
        .padding()
    }
}
