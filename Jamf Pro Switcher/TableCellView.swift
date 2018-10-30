//
//  TableCellView.swift
//  Jamf Pro Switcher
//
//  Created by Nindi Gill on 30/10/18.
//  Copyright © 2018 Ninxsoft. All rights reserved.
//

import Cocoa

class TableCellView: NSTableCellView {

  @IBOutlet var nameTextField: NSTextField?
  @IBOutlet var addressTextField: NSTextField?
  @IBOutlet var versionTextField: NSTextField?
  @IBOutlet var tickView: TickView?
}
