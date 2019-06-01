//
//  ViewController.swift
//  Jamf Pro Switcher
//
//  Created by Nindi Gill on 30/10/18.
//  Copyright © 2018 Ninxsoft. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

  @IBOutlet var tableView: NSTableView?
  @IBOutlet var tableViewHeightConstraint: NSLayoutConstraint?
  @IBOutlet var closeJamfProAppsCheckbox: NSButton?
  @IBOutlet var progressIndicator: NSProgressIndicator?
  @IBOutlet var switchButton: NSButton?

  var jamfProServers = [JamfProServer]()
  var selectedJamfProServer = -1

  static let containerPath = "/Containers/com.ninxsoft.jamfproswitcher/Data"
  static let jamfPlistPath = "/Preferences/com.jamfsoftware.jss.plist"
  static let plistPath = "/Preferences/com.ninxsoft.jamfproswitcher.plist"
  let jamfPreferencesPath = NSHomeDirectory().replacingOccurrences(of: containerPath,
                                                                   with: jamfPlistPath)
  let preferencesPath = NSHomeDirectory().replacingOccurrences(of: containerPath,
                                                               with: plistPath)

  var shouldCloseJamfProApps = false
  let appIdentifiers = ["com.jamfsoftware.CasperAdmin",
                        "com.jamfsoftware.CasperImaging",
                        "com.jamfsoftware.CasperRemote",
                        "com.jamfsoftware.JamfAdmin",
                        "com.jamfsoftware.JamfImaging",
                        "com.jamfsoftware.JamfRemote",
                        "com.jamfsoftware.Recon"]

  override func viewDidLoad() {
    super.viewDidLoad()
    self.loadPreferences()
    self.setSelectedJamfProServer()
    self.updateJamfProServerVersions()
    self.tableView?.target = self
    self.tableView?.doubleAction = #selector(self.tableViewDoubleAction)
  }

  /**
    Loads app preferences from property list
  */
  private func loadPreferences() {

    let path = self.preferencesPath

    guard let dictionary = NSDictionary(contentsOfFile: path),
      let array = dictionary.value(forKey: "JamfProServers") as? [NSDictionary] else {
        return
    }

    for item in array {
      if let name = item.value(forKey: "Name") as? String,
        let address = item.value(forKey: "Address") as? String,
        let version = item.value(forKey: "Version") as? String {
        let jamfProServer = JamfProServer(name: name, address: address, version: version)
        self.jamfProServers.append(jamfProServer)
      }
    }

    if let boolean = dictionary.value(forKey: "CloseJamfProApps") as? Bool {
      self.shouldCloseJamfProApps = boolean
    }
  }

  /**
    Determines which Jamf Pro Server is currently selected (used to display the green tick).
  */
  private func setSelectedJamfProServer() {

    let path = self.jamfPreferencesPath

    guard let dictionary = NSDictionary(contentsOfFile: path),
      let address = dictionary.value(forKey: "url") as? String else {
        return
    }

    for (index, jamfProServer) in self.jamfProServers.enumerated() where jamfProServer.address == address {
      self.selectedJamfProServer = index
      return
    }
  }

  /**
    Loops through each Jamf Pro Server and attempts to look up the version number,
    and updates the corresponding table cell view if a version string is found.
  */
  private func updateJamfProServerVersions() {

    DispatchQueue.global(qos: .userInitiated).async {

      for jamfProServer in self.jamfProServers {

        if let url = URL(string: jamfProServer.address) {

          do {
            let html = try String(contentsOf: url, encoding: .ascii)

            if let version = self.getVersionFromHTML(html) {
              jamfProServer.version = version
            }
          } catch {
            jamfProServer.version = ""
            print("Error: \(error)")
          }
        }
      }

      self.updatePreferences()

      DispatchQueue.main.async(execute: {

        for (index, jamfProServer) in self.jamfProServers.enumerated() {
          if let cell = self.tableView?.view(atColumn: 0, row: index, makeIfNecessary: true) as? TableCellView {
            cell.versionTextField?.stringValue = jamfProServer.version
          }
        }
      })
    }
  }

  /**
    Attempts to parse html and get a version string.
    - Parameters:
      - html: The html string used to search for a valid version string.
    - Returns:
      - A valid version string if one is found.
      - nil if no valid version string is found.
  */
  private func getVersionFromHTML(_ html: String) -> String? {

    let prefix = "<meta name=\"version\" content=\""
    let suffix = "\">"

    var string = html.replacingOccurrences(of: "\\n", with: "", options: .regularExpression)
    string = string.replacingOccurrences(of: ".*\(prefix)", with: "", options: .regularExpression)
    string = string.replacingOccurrences(of: "\(suffix).*", with: "", options: .regularExpression)
    return string.isValidJamfProVersion ? string : ""
  }

  override func viewWillAppear() {

    // dynamically set the height of the tableview
    if let tableViewHeaderHeight = self.tableView?.headerView?.frame.height,
      let tableViewRowHeight = self.tableView?.rowHeight {
      let rows = CGFloat(5)
      self.tableViewHeightConstraint?.constant = tableViewHeaderHeight + tableViewRowHeight * rows
    }

    self.closeJamfProAppsCheckbox?.state = self.shouldCloseJamfProApps ? .on : .off
    self.switchButton?.isEnabled = self.jamfProServers.isEmpty ? false : self.tableView?.selectedRow != -1
  }

  /**
    Called when the plus (+) button is clicked (to add a row).
  */
  @IBAction func addButtonClicked(sender: NSButton) {

    guard let row = self.tableView?.selectedRow else {
      return
    }

    let newRow = row == -1 ? self.jamfProServers.count : row + 1
    let jamfProServer = JamfProServer()
    self.jamfProServers.insert(jamfProServer, at: newRow)
    self.tableView?.insertRows(at: IndexSet(arrayLiteral: newRow), withAnimation: [.slideDown, .effectFade])
    self.tableView?.selectRowIndexes(IndexSet(arrayLiteral: newRow), byExtendingSelection: false)
    self.tableView?.scrollRowToVisible(newRow)

    // update the new row
    if let cell = self.tableView?.view(atColumn: 0, row: newRow, makeIfNecessary: true) as? TableCellView {
      cell.nameTextField?.becomeFirstResponder()
    }
  }

  /**
    Called when the minus (-) button is clicked (to remove a row).
  */
  @IBAction func removeButtonClicked(sender: NSButton) {

    guard let row = self.tableView?.selectedRow,
      row != -1 else {
      return
    }

    self.tableView?.removeRows(at: IndexSet(arrayLiteral: row), withAnimation: [.slideUp, .effectFade])
    self.jamfProServers.remove(at: row)
    self.updatePreferences()
  }

  func controlTextDidEndEditing(_ obj: Notification) {

    guard let textField = obj.object as? NSTextField else {
      return
    }

    var addressChanged = false

    for (index, jamfProServer) in self.jamfProServers.enumerated() {

      if let cell = self.tableView?.view(atColumn: 0, row: index, makeIfNecessary: true) as? TableCellView {
        if cell.nameTextField == textField {
          jamfProServer.name = textField.stringValue
        } else if cell.addressTextField == textField {
          jamfProServer.address = textField.stringValue
          addressChanged = true
        }
      }
    }

    self.updatePreferences()

    // only attempt to look up new version strings if the address was changed
    if addressChanged {
      self.updateJamfProServerVersions()
    }
  }

  /**
   Called when a Table View Cell was double-clicked.
  */
  @objc func tableViewDoubleAction(sender: AnyObject) {

    guard let row = self.tableView?.selectedRow,
    row != -1 else {
      return
    }

    let address = jamfProServers[row].address

    // open the url in the default web browser
    if let url = URL(string: address) {
      NSWorkspace.shared.open(url)
    }
  }

  /**
   Writes the app preferences to property list.
  */
  private func updatePreferences() {

    let path = self.preferencesPath
    let url = URL(fileURLWithPath: path)
    var dictionary = NSMutableDictionary()

    // grab the current dictionary if it exists
    if let dictionaryFromFile = NSMutableDictionary(contentsOfFile: path) {
      dictionary = dictionaryFromFile
    }

    var jamfProServersArray = [NSMutableDictionary]()

    for jamfProServer in self.jamfProServers {
      let jamfProServerDictionary = NSMutableDictionary()
      jamfProServerDictionary.setValue(jamfProServer.name, forKey: "Name")
      jamfProServerDictionary.setValue(jamfProServer.address, forKey: "Address")
      jamfProServerDictionary.setValue(jamfProServer.version, forKey: "Version")
      jamfProServersArray.append(jamfProServerDictionary)
    }

    dictionary.setValue(jamfProServersArray, forKey: "JamfProServers")
    dictionary.setValue(self.shouldCloseJamfProApps, forKey: "CloseJamfProApps")
    dictionary.write(to: url, atomically: true)
  }

  /**
   Called when the Close Jamf Pro Apps checkbox is clicked.
  */
  @IBAction func closeJamfProAppsCheckboxClicked(sender: NSButton) {
    self.shouldCloseJamfProApps = sender.state == .on
    self.updatePreferences()
  }

  /**
   Called when the Switch button is clicked.
  */
  @IBAction func switchButtonClicked(sender: NSButton) {

    if self.shouldCloseJamfProApps && self.areJamfProAppsRunning {
      self.quitJamfProApps()
    } else {
      self.updateJamfPreferences()
    }
  }

  /**
    Determines if any of the Jamf Pro Apps are running.
  */
  private var areJamfProAppsRunning: Bool {

    var runningApplications = [NSRunningApplication]()

    for application in NSWorkspace.shared.runningApplications {

      if let identifier = application.bundleIdentifier,
        self.appIdentifiers.contains(identifier) {
        runningApplications.append(application)
      }
    }

    return !runningApplications.isEmpty
  }

  /**
   Attempts to close any open Jamf Pro Apps, looping until no Jamf Pro Apps remain open.
  */
  private func quitJamfProApps() {

    // lock down the ui
    self.tableView?.isEnabled = false
    self.closeJamfProAppsCheckbox?.isEnabled = false
    self.switchButton?.isEnabled = false
    self.progressIndicator?.startAnimation(self)

    DispatchQueue.global(qos: .userInitiated).async {

      while true {

        var runningApplications = [NSRunningApplication]()

        for application in NSWorkspace.shared.runningApplications {

          if let identifier = application.bundleIdentifier,
            self.appIdentifiers.contains(identifier) {
            runningApplications.append(application)
          }
        }

        if runningApplications.isEmpty {
          DispatchQueue.main.async(execute: {
            // unlock the ui
            self.progressIndicator?.stopAnimation(self)
            self.tableView?.isEnabled = true
            self.closeJamfProAppsCheckbox?.isEnabled = true
            self.switchButton?.isEnabled = true
            self.updateJamfPreferences()
          })
          break
        }

        for application in runningApplications {
          application.terminate()
        }

        sleep(1)
      }
    }
  }

  /**
   Writes the jamf preferences to property list.
  */
  func updateJamfPreferences() {

    let path = self.jamfPreferencesPath
    let url = URL(fileURLWithPath: path)

    // grab the current dictionary if it exists, and only continue if a row is selected
    guard let dictionary = NSMutableDictionary(contentsOfFile: path),
      let row = self.tableView?.selectedRow,
      row != -1 else {
      return
    }

    let address = self.jamfProServers[row].address

    dictionary.setValue(address, forKey: "url")
    dictionary.write(to: url, atomically: true)

    self.setSelectedJamfProServer()

    // update the selected row
    for index in self.jamfProServers.indices {
      if let cell = self.tableView?.view(atColumn: 0, row: index, makeIfNecessary: true) as? TableCellView {
        cell.tickView?.isHidden = index != self.selectedJamfProServer
      }
    }
  }
}

extension ViewController: NSTableViewDataSource {

  func numberOfRows(in tableView: NSTableView) -> Int {
    return self.jamfProServers.count
  }
}

extension ViewController: NSTableViewDelegate {

  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {

    let identifier = NSUserInterfaceItemIdentifier(rawValue: "TableCellView")

    guard let cell = tableView.makeView(withIdentifier: identifier, owner: self) as? TableCellView else {
      return nil
    }

    cell.nameTextField?.stringValue = self.jamfProServers[row].name
    cell.addressTextField?.stringValue = self.jamfProServers[row].address
    cell.versionTextField?.stringValue = self.jamfProServers[row].version
    cell.tickView?.isHidden = row != self.selectedJamfProServer
    return cell
  }

  func tableViewSelectionDidChange(_ notification: Notification) {
    // only enable the Switch button if a row is selected
    self.switchButton?.isEnabled = self.jamfProServers.isEmpty ? false : self.tableView?.selectedRow != -1
  }
}

extension String {

  /**
    Determines if the string is valid based on a version string regular expression.
  */
  var isValidJamfProVersion: Bool {
    let regex = "[0-9]+(\\.[0-9]+)+(-t[0-9]+(\\+G[0-9])?)?"
    return self.range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
  }
}
