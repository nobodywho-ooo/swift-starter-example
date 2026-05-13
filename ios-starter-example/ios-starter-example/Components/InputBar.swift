import SwiftUI

struct InputBar: View {
    @Binding var text: String
    var isStreaming: Bool
    var onSend: () -> Void
    var onStop: () -> Void

    static let height: CGFloat = 48

    var body: some View {
        HStack(spacing: 8) {
            TextField(isStreaming ? "Thinking..." : "Ask something...", text: $text, axis: .vertical)
                .lineLimit(1 ... 5)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .disabled(isStreaming)

            if isStreaming {
                Button(action: onStop) {
                    Image(systemName: "stop.circle")
                        .font(.system(size: 24))
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
