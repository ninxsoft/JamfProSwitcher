//
//  ServerRow.swift
//  Jamf Pro Switcher
//
//  Created by Nindi Gill on 19/8/20.
//

import SwiftUI

struct ServerRow: View {
    @Environment(\.openURL) var openURL: OpenURLAction
    @ObservedObject var server: Server
    @Binding var selectedServer: Server?
    @State private var hoveringOnSelection: Bool = false
    @State private var hoveringOnOpen: Bool = false
    private let spacing: CGFloat = 5
    private let height: CGFloat = 80
    private var version: String {
        "Version: " + server.version
    }
    private var selected: Bool {
        server == selectedServer
    }
    private var selectedSystemName: String {
        selected || hoveringOnSelection ? "checkmark.circle.fill" : "circle"
    }
    private var openSystemName: String {
        hoveringOnOpen ? "safari.fill" : "safari"
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            HStack {
                Button(action: {
                    selectedServer = server
                }, label: {
                    Image(systemName: selectedSystemName)
                        .font(.largeTitle)
                        .foregroundColor(.green)
                })
                .buttonStyle(PlainButtonStyle())
                .onHover { hovering in
                    withAnimation {
                        hoveringOnSelection = hovering
                    }
                }
                VStack(alignment: .leading, spacing: spacing) {
                    TextField("Name", text: $server.name)
                        .font(.title3)
                    // swiftlint:disable:next trailing_closure
                    TextField("Address", text: $server.address, onCommit: {
                        server.updateVersion()
                    })
                    Text(version)
                        .font(.caption2)
                }
                Spacer()
                Button(action: {
                    open()
                }, label: {
                    Image(systemName: openSystemName)
                        .font(.largeTitle)
                        .foregroundColor(.blue)
                })
                .buttonStyle(PlainButtonStyle())
                .onHover { hovering in
                    withAnimation {
                        hoveringOnOpen = hovering
                    }
                }
            }
            Spacer()
            Divider()
        }
        .frame(minHeight: height, maxHeight: height)
    }

    private func open() {

        guard let url: URL = URL(string: server.address) else {
            return
        }

        openURL(url)
    }
}

struct ServerRow_Previews: PreviewProvider {
    static var previews: some View {
        ServerRow(server: .example, selectedServer: .constant(.example))
    }
}
