//
//  String+Extension.swift
//  Jamf Pro Switcher
//
//  Created by Nindi Gill on 19/8/20.
//

import Cocoa

extension String {

    static let homepage: String = "https://github.com/ninxsoft/JamfProSwitcher"
    static let releasesURL: String = "https://github.com/ninxsoft/JamfProSwitcher/releases"
    static let latestReleaseURL: String = "https://api.github.com/repos/ninxsoft/JamfProSwitcher/releases/latest"
    static var jamfPreferencesPath: String {
        NSHomeDirectory().replacingOccurrences(of: "Containers/com.ninxsoft.jamfproswitcher/Data", with: "") + "Preferences/com.jamfsoftware.jss.plist"
    }
    static var applicationIdentifiers: [String] {
        [
            "com.jamfsoftware.CasperAdmin",
            "com.jamfsoftware.CasperImaging",
            "com.jamfsoftware.CasperRemote",
            "com.jamfsoftware.JamfAdmin",
            "com.jamfsoftware.JamfImaging",
            "com.jamfsoftware.JamfRemote",
            "com.jamfsoftware.Recon"
        ]
    }

    var isValidServerAddress: Bool {
        let regex: String = "((?:http|https)://)?(?:www\\.)?[\\w\\d\\-_]+\\.\\w{2,3}(\\.\\w{2})?(/(?<=/)(?:[\\w\\d\\-./_]+)?)?"
        return self.range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
    }

    var isValidServerVersion: Bool {
        let regex: String = "[0-9]+(\\.[0-9]+)+(-t[0-9]+(\\+G[0-9])?)?"
        return self.range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
    }
}
