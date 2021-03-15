//
//  KeyedDecodingContainer+Extension.swift
//  Jamf Pro Switcher
//
//  Created by Nindi Gill on 9/12/20.
//

import Cocoa

extension KeyedDecodingContainer {

    func decode<T>(key: K, defaultValue: T) throws -> T where T: Decodable {
        (try? decodeIfPresent(T.self, forKey: key)) ?? defaultValue
    }
}
