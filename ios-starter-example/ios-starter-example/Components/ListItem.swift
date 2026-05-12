import SwiftUI

struct ListItem: View {
    let title: String
    let subtitle: String
    let iconName: String
    let iconBackgroundColor: Color
    var disabled: Bool = false
    var isLoading: Bool = false
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: iconName)
                    .font(.system(size: 16))
                    .foregroundStyle(.white)
                    .frame(width: 32, height: 32)
                    .background(iconBackgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .foregroundStyle(.primary)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if isLoading {
                    ProgressView()
                } else {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(disabled)
        .opacity(disabled ? 0.4 : 1)
    }
}

#Preview {
    List {
        ListItem(
            title: "Settings",
            subtitle: "App preferences",
            iconName: "gearshape.fill",
            iconBackgroundColor: .gray
        )
        ListItem(
            title: "About",
            subtitle: "Version and licenses",
            iconName: "info.circle.fill",
            iconBackgroundColor: .blue
        )
        ListItem(
            title: "Disabled",
            subtitle: "Not available",
            iconName: "xmark.circle.fill",
            iconBackgroundColor: .red,
            disabled: true
        )
    }
    .listStyle(.plain)
}
