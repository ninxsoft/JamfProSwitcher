//
//  Model.swift
//  Jamf Pro Switcher
//
//  Created by Nindi Gill on 19/8/20.
//

import Cocoa

class Model: ObservableObject {
    static let example: Model = Model()
    @Published var servers: [Server]
    @Published var selectedServer: Server?
    @Published var quitAppsOnClose: Bool = false

    init() {
        servers = []

        guard let dictionaries: [[String: String]] = UserDefaults.standard.array(forKey: "JamfProServers") as? [[String: String]] else {
            return
        }

        do {
            let data: Data = try JSONEncoder().encode(dictionaries)
            let servers: [Server] = try JSONDecoder().decode([Server].self, from: data)
            self.servers = servers
        } catch {
            print(error.localizedDescription)
        }

        quitAppsOnClose = UserDefaults.standard.bool(forKey: "QuitAppsOnClose")

        guard let dictionary: [String: Any] = NSDictionary(contentsOfFile: .jamfPreferencesPath) as? [String: Any],
            let address: String = dictionary["url"] as? String else {
            return
        }

        selectedServer = servers.first { $0.address == address }
    }

    func save() {
        let dictionaries: [[String: String]] = servers.map { $0.dictionary }
        UserDefaults.standard.set(dictionaries, forKey: "JamfProServers")
        UserDefaults.standard.set(quitAppsOnClose, forKey: "QuitAppsOnClose")
    }

    func updateServerVersions() {

        for server in servers {
            server.updateVersion()
        }
    }

    func setServer(_ server: Server?) {

        guard let server: Server = server,
            let dictionary: NSMutableDictionary = NSMutableDictionary(contentsOfFile: .jamfPreferencesPath) else {
            return
        }

        let url: URL = URL(fileURLWithPath: .jamfPreferencesPath)
        dictionary.setValue(server.address, forKey: "url")
        dictionary.write(to: url, atomically: true)
    }
}
