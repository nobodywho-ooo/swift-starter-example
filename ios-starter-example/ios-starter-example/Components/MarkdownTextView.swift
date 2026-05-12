import LLMStream
import SwiftUI

struct MarkdownTextView: View {
    let text: String

    var body: some View {
        LLMStreamView(
            text: text,
            configuration: LLMStreamConfiguration(
                font: FontConfiguration(size: 16.0),
                colors: ColorConfiguration(
                    textColor: .black,
                    backgroundColor: .clear,
                    tableHeaderBackgroundColor: Color(red: 0.93, green: 0.93, blue: 0.93),
                    tableBorderColor: Color.gray.opacity(0.3),
                    theoremBorderColor: Color.gray,
                    proofBorderColor: Color.gray
                )
            )
        ) { url in
            if let url = URL(string: url) {
                UIApplication.shared.open(url)
            }
        }
    }
}

#Preview {
    ScrollView {
        MarkdownTextView(text: """
        # Heading 1

        ## Heading 2

        This is a paragraph with **bold**, *italic*, and `inline code`.

        ### List

        - First item
        - Second item
        - Third item with a [link](https://example.com)

        ### Code Block

        ```swift
        func greet(name: String) -> String {
            return "Hello, \\(name)!"
        }
        ```

        ### Table

        | Feature | Status |
        |---------|--------|
        | Markdown | Supported |
        | Tables | Supported |
        | Code | Supported |

        ---

        > This is a blockquote with some wisdom.

        That's all folks!
        """)
        .padding()
    }
}
