//
//  AppCommands.swift
//  Jamf Pro Switcher
//
//  Created by Nindi Gill on 19/8/20.
//

import SwiftUI

struct AppCommands: Commands {
    @Environment(\.openURL) var openURL: OpenURLAction

    @CommandsBuilder var body: some Commands {
        CommandGroup(replacing: .newItem) { }
        CommandGroup(replacing: .help) {
            Button("Jamf Pro Switcher Help") {
                help()
            }
        }
    }

    func help() {

        guard let url: URL = URL(string: .homepage) else {
            return
        }

        openURL(url)
    }
}
