//
//  ContentView.swift
//  ios-starter-example
//
//  Created by Pierre Bresson on 04/05/2026.
//

import SwiftUI

enum AppTab {
    case chat, vision, hearing, more
}

struct ContentView: View {
    @State private var selectedTab: AppTab = .chat

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Chat", systemImage: "message", value: AppTab.chat) {
                ChatView()
            }
            Tab("Vision", systemImage: "eye", value: AppTab.vision) {
                VisionView()
            }
            Tab("Hearing", systemImage: "ear", value: AppTab.hearing) {
                HearingView()
            }
            Tab("More", systemImage: "ellipsis", value: AppTab.more) {
                MoreView()
            }
        }
    }
}

#Preview {
    ContentView()
}
