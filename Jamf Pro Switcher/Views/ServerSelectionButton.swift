//
//  ServerSelectionButton.swift
//  Jamf Pro Switcher
//
//  Created by Nindi Gill on 22/11/21.
//

import SwiftUI

struct ServerSelectionButton: View {
    @ObservedObject var server: Server
    @Binding var selectedServer: Server?
    @Binding var hoveringOnSelection: Bool
    private var selected: Bool {
        server == selectedServer
    }
    private var selectedSystemName: String {
        selected || hoveringOnSelection ? "checkmark.circle.fill" : "circle"
    }

    var body: some View {
        Button(action: {
            selectedServer = server
        }, label: {
            Image(systemName: selectedSystemName)
                .font(.largeTitle)
                .foregroundColor(.green)
        })
            .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation {
                hoveringOnSelection = hovering
            }
        }
    }
}

struct ServerSelectionButton_Previews: PreviewProvider {
    static var previews: some View {
        ServerSelectionButton(server: .example, selectedServer: .constant(.example), hoveringOnSelection: .constant(true))
    }
}
