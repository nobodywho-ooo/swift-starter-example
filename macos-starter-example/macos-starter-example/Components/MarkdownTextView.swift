import LLMStream
import SwiftUI

struct MarkdownTextView: View {
    let text: String

    var body: some View {
        LLMStreamView(
            text: text,
            configuration: LLMStreamConfiguration(
                font: FontConfiguration(size: 14.0),
                colors: ColorConfiguration(
                    textColor: Color(nsColor: .labelColor.usingColorSpace(.sRGB) ?? .labelColor),
                    backgroundColor: .clear,
                    tableHeaderBackgroundColor: Color(red: 0.93, green: 0.93, blue: 0.93),
                    tableBorderColor: Color.gray.opacity(0.3),
                    theoremBorderColor: Color.gray,
                    proofBorderColor: Color.gray
                )
            )
        )
    }
}

#Preview {
    ScrollView {
        MarkdownTextView(text: """
        # Heading 1

        ## Heading 2

        This is a paragraph with **bold**, *italic*, and `inline code`.

        ```swift
        func greet(name: String) -> String {
            return "Hello, \\(name)!"
        }
        ```
        """)
        .padding()
    }
}
