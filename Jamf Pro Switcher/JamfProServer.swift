//
//  JamfProServer.swift
//  Jamf Pro Switcher
//
//  Created by Nindi Gill on 30/10/18.
//  Copyright © 2018 Ninxsoft. All rights reserved.
//

import Cocoa

class JamfProServer: NSObject {

  var name = ""
  var address = ""
  var version = ""

  convenience init(name: String, address: String, version: String) {
    self.init()
    self.name = name
    self.address = address
    self.version = version
  }
}
