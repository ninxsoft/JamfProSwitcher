//
//  ServerWebsiteButton.swift
//  Jamf Pro Switcher
//
//  Created by Nindi Gill on 22/11/21.
//

import SwiftUI

struct ServerWebsiteButton: View {
    @Environment(\.openURL) var openURL: OpenURLAction
    @ObservedObject var server: Server
    @Binding var hoveringOnOpen: Bool
    private var openSystemName: String {
        hoveringOnOpen ? "safari.fill" : "safari"
    }

    var body: some View {
        Button(action: {
            open()
        }, label: {
            Image(systemName: openSystemName)
                .font(.largeTitle)
                .foregroundColor(.blue)
        })
            .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation {
                hoveringOnOpen = hovering
            }
        }
    }

    private func open() {

        guard let url: URL = URL(string: server.address) else {
            return
        }

        openURL(url)
    }
}

struct ServerWebsiteButton_Previews: PreviewProvider {
    static var previews: some View {
        ServerWebsiteButton(server: .example, hoveringOnOpen: .constant(true))
    }
}
