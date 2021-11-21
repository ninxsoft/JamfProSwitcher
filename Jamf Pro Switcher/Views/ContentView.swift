//
//  ContentView.swift
//  Jamf Pro Switcher
//
//  Created by Nindi Gill on 19/8/20.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var model: Model
    @State private var searchString: String = ""
    private let width: CGFloat = 400
    private let height: CGFloat = 600

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
        }
        .onDisappear {
            model.save()
        }
        .onChange(of: model.selectedServer) { server in
            model.setServer(server)
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(model: .example)
    }
}
