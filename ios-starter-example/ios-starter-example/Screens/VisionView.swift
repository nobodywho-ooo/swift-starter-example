import SwiftUI

struct VisionView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    HStack(spacing: 16) {
                        BundleImage("image-1")
                        BundleImage("image-2")
                    }
                    Text("Describes the images")
                        .foregroundStyle(.secondary)
                    Button("Analyse") {
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
            }
            .navigationTitle("Vision")
        }
    }
}

private struct BundleImage: View {
    let name: String

    init(_ name: String) {
        self.name = name
    }

    var body: some View {
        if let path = Bundle.main.path(forResource: name, ofType: "png"),
           let uiImage = UIImage(contentsOfFile: path) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

#Preview {
    VisionView()
}
