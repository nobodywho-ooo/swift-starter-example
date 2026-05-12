import SwiftUI

struct AudioView: View {
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Transcribe audio.mp3")
                    .foregroundStyle(.secondary)
                Button("Get speech") {
                }
                .buttonStyle(.bordered)
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .navigationTitle("Audio")
        }
    }
}

#Preview {
    AudioView()
}
