//
//  ServerRow.swift
//  Jamf Pro Switcher
//
//  Created by Nindi Gill on 19/8/20.
//

import SwiftUI

struct ServerRow: View {
    @ObservedObject var server: Server
    @Binding var selectedServer: Server?
    @State private var hoveringOnSelection: Bool = false
    @State private var hoveringOnOpen: Bool = false
    private let spacing: CGFloat = 5
    private let height: CGFloat = 80
    private var version: String {
        "Version: " + server.version
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            HStack {
                ServerSelectionButton(server: server, selectedServer: $selectedServer, hoveringOnSelection: $hoveringOnSelection)
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
                ServerWebsiteButton(server: server, hoveringOnOpen: $hoveringOnOpen)
            }
            Spacer()
            Divider()
        }
        .frame(minHeight: height, maxHeight: height)
    }
}

struct ServerRow_Previews: PreviewProvider {
    static var previews: some View {
        ServerRow(server: .example, selectedServer: .constant(.example))
    }
}
