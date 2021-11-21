//
//  Server.swift
//  Jamf Pro Switcher
//
//  Created by Nindi Gill on 19/8/20.
//

import Cocoa

class Server: Identifiable, ObservableObject {

    static var example: Server {
        let example: Server = Server()
        example.name = "Name"
        example.address = "https://your-custom-server.jamfcloud.com"
        return example
    }

    @Published var id: String = UUID().uuidString
    @Published var name: String
    @Published var address: String
    @Published var version: String
    var url: URL? {
        URL(string: address)
    }
    var connectionAddress: String {
        "\(address)\(address.hasSuffix("/") ? "" : "/")JSSCheckConnection"
    }
    var dictionary: [String: String] {
        [
            "ID": id,
            "Name": name,
            "Address": address
        ]
    }

    init() {
        name = ""
        address = ""
        version = ""
    }

    required init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        address = try container.decode(String.self, forKey: .address)
        version = ""
    }

    func updateVersion() {

        guard connectionAddress.isValidServerAddress,
            let url: URL = URL(string: connectionAddress) else {
            return
        }

        do {
            let string: String = try String(contentsOf: url)

            if string.isValidServerVersion {
                version = string
            }
        } catch {
            version = ""
            print(error.localizedDescription)
        }
    }
}

extension Server: Codable {

    private enum CodingKeys: String, CodingKey {
        case id = "ID"
        case name = "Name"
        case address = "Address"
    }

    func encode(to encoder: Encoder) throws {
        var container: KeyedEncodingContainer = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(address, forKey: .address)
    }
}

extension Server: Equatable {

    static func == (lhs: Server, rhs: Server) -> Bool {
        lhs.id == rhs.id && lhs.name == rhs.name && lhs.address == rhs.address
    }
}

extension Server: Hashable {

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(address)
    }
}
