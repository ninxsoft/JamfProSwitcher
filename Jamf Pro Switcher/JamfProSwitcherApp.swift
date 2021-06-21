//
//  JamfProSwitcherApp.swift
//  Jamf Pro Switcher
//
//  Created by Nindi Gill on 19/8/20.
//

import SwiftUI

@main
struct JamfProSwitcherApp: App {
    // swiftlint:disable:next weak_delegate
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate: AppDelegate
    @StateObject private var model: Model = Model()

    @SceneBuilder var body: some Scene {
        WindowGroup {
            ContentView(model: model)
        }
        .commands {
            AppCommands(model: model)
        }
    }
}
