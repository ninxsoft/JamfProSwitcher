//
//  Model.swift
//  Jamf Pro Switcher
//
//  Created by Nindi Gill on 19/8/20.
//

import Cocoa

class Model: ObservableObject {
    static let example: Model = Model()
    static let containerPath: String = "/Containers/com.ninxsoft.jamfproswitcher/Data"
    static let jamfPropertyListPath: String = "/Preferences/com.jamfsoftware.jss.plist"

    @Published var servers: [Server]
    @Published var selectedServer: Server?
    private var jamfPreferencesPath: String {
        NSHomeDirectory().replacingOccurrences(of: Model.containerPath, with: Model.jamfPropertyListPath)
    }

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
            print(error)
        }

        guard let dictionary: [String: Any] = NSDictionary(contentsOfFile: jamfPreferencesPath) as? [String: Any],
            let address: String = dictionary["url"] as? String else {
            return
        }

        selectedServer = servers.first { $0.address == address }
    }

    func save() {
        let dictionaries: [[String: String]] = servers.map { $0.dictionary }
        UserDefaults.standard.set(dictionaries, forKey: "JamfProServers")
    }

    func updateServerVersions() {

        for server in servers {
            server.updateVersion()
        }
    }

    func setServer(_ server: Server?) {

        guard let server: Server = server,
            let dictionary: NSMutableDictionary = NSMutableDictionary(contentsOfFile: jamfPreferencesPath) else {
            return
        }

        let url: URL = URL(fileURLWithPath: jamfPreferencesPath)
        dictionary.setValue(server.address, forKey: "url")
        dictionary.write(to: url, atomically: true)
    }
}
