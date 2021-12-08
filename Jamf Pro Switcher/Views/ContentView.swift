//
//  ContentView.swift
//  Jamf Pro Switcher
//
//  Created by Nindi Gill on 19/8/20.
//

import SwiftUI
import UserNotifications

struct ContentView: View {
    @ObservedObject var model: Model
    @State private var searchString: String = ""
    private let width: CGFloat = 400
    private let height: CGFloat = 600
    @AppStorage("RequestedAuthorizationForNotifications") private var requestedAuthorizationForNotifications: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            List {
                ForEach(Array(filteredServers().enumerated()), id: \.offset) { index, server in
                    ServerRow(server: server, selectedServer: $model.selectedServer)
                        .tag(server)
                        .contextMenu {
                            Button("Delete") {
                                onDelete(offsets: IndexSet(integer: index))
                            }
                        }
                }
                .onMove(perform: onMove)
                .onDelete(perform: onDelete)
            }
            .listStyle(.plain)
            Divider()
            HStack {
                Toggle("Quit Jamf Apps on Close", isOn: $model.quitAppsOnClose)
                Spacer()
                Button("Add Server") {
                    add()
                }
            }
            .padding()
        }
        .frame(width: width, height: height)
        .searchable(text: $searchString)
        .onAppear {
            model.updateServerVersions()
            checkForUpdates()
        }
        .onDisappear {
            model.save()
            quitJamfProApps()
        }
        .onChange(of: model.selectedServer) { server in
            model.setServer(server)
        }
    }

    private func checkForUpdates() {

        guard let url: URL = URL(string: .latestReleaseURL),
            let infoDictionary: [String: Any] = Bundle.main.infoDictionary,
            let version: String = infoDictionary["CFBundleShortVersionString"] as? String else {
            return
        }

        do {
            let string: String = try String(contentsOf: url, encoding: .utf8)

            guard let data: Data = string.data(using: .utf8),
                let dictionary: [String: Any] = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
                let tag: String = dictionary["tag_name"] as? String else {
                return
            }

            let latestVersion: String = tag.replacingOccurrences(of: "v", with: "")

            guard version.compare(latestVersion, options: .numeric) == .orderedAscending else {
                return
            }

            if !requestedAuthorizationForNotifications {
                let notificationCenter: UNUserNotificationCenter = .current()
                notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { _, error in

                    if let error: Error = error {
                        print(error.localizedDescription)
                        return
                    }

                    requestedAuthorizationForNotifications = true
                    sendUpdateNotification(for: latestVersion)
                }
            } else {
                sendUpdateNotification(for: latestVersion)
            }
        } catch {
            print(error.localizedDescription)
        }
    }

    private func sendUpdateNotification(for version: String) {

        let notificationCenter: UNUserNotificationCenter = .current()
        notificationCenter.getNotificationSettings { settings in

            guard [.authorized, .provisional].contains(settings.authorizationStatus) else {
                return
            }

            let identifier: String = UUID().uuidString

            let content: UNMutableNotificationContent = UNMutableNotificationContent()
            content.title = "Update Available"
            content.body = "Version \(version) is available to download."
            content.sound = .default
            content.categoryIdentifier = UNNotificationCategory.Identifier.update

            let trigger: UNTimeIntervalNotificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request: UNNotificationRequest = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

            notificationCenter.add(request) { error in

                if let error: Error = error {
                    print(error.localizedDescription)
                }
            }
        }
    }

    private func add() {
        let server: Server = Server()
        model.servers.append(server)
    }

    private func onMove(source: IndexSet, destination: Int) {
        model.servers.move(fromOffsets: source, toOffset: destination)
    }

    private func onDelete(offsets: IndexSet) {
        model.servers.remove(atOffsets: offsets)
    }

    private func filteredServers() -> [Server] {

        guard !searchString.isEmpty else {
            return model.servers
        }

        let filteredServers: [Server] = model.servers.filter {
            $0.name.lowercased().contains(searchString) ||
            $0.address.lowercased().contains(searchString) ||
            $0.version.lowercased().contains(searchString)
        }

        return filteredServers
    }

    private func quitJamfProApps() {

        guard model.quitAppsOnClose else {
            return
        }

        NSWorkspace.shared.runningApplications.filter { String.applicationIdentifiers.contains($0.bundleIdentifier ?? "") }.forEach { application in
            application.terminate()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(model: .example)
    }
}
