import LLMStream
import SwiftUI

struct MarkdownTextView: View {
    let text: String

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        let textColor: Color = colorScheme == .dark ? .white : .black
        let tableHeaderBackgroundColor: Color = colorScheme == .dark
        ? Color(white: 0.2)
        : Color(red: 0.93, green: 0.93, blue: 0.93)
        
        LLMStreamView(
            text: text,
            configuration: LLMStreamConfiguration(
                font: FontConfiguration(size: 16.0),
                colors: ColorConfiguration(
                    textColor: textColor,
                    backgroundColor: .clear,
                    tableHeaderBackgroundColor: tableHeaderBackgroundColor,
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
        .id(colorScheme)
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
