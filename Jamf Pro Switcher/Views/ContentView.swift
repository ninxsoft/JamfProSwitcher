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
            Form {
                TextField("Search", text: $searchString)
                List {
                    ForEach(filteredServers()) { server in
                        ServerRow(server: server, selectedServer: $model.selectedServer)
                            .tag(server)
                    }
                    .onMove(perform: onMove)
                    .onDelete(perform: onDelete)
                }
                .listStyle(PlainListStyle())
            }
            .padding([.top, .horizontal])
            HStack {
                Spacer()
                Button("Add Server") {
                    add()
                }
            }
            .padding()
        }
        .frame(width: width, height: height)
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
        model.save()
    }

    private func onMove(source: IndexSet, destination: Int) {
        model.servers.move(fromOffsets: source, toOffset: destination)
        model.save()
    }

    private func onDelete(offsets: IndexSet) {
        model.servers.remove(atOffsets: offsets)
        model.save()
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
