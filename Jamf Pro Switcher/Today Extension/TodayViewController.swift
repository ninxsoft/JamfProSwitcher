//
//  TodayViewController.swift
//  Today Extension
//
//  Created by Nindi Gill on 30/10/18.
//  Copyright © 2018 Ninxsoft. All rights reserved.
//

import Cocoa
import NotificationCenter

class TodayViewController: NSViewController, NCWidgetProviding {
  
  @IBOutlet var tableView: NSTableView?
  @IBOutlet var tableViewHeightConstraint: NSLayoutConstraint?
  @IBOutlet var progressIndicator: NSProgressIndicator?
  @IBOutlet var launchButton: NSButton?
  @IBOutlet var switchButton: NSButton?
  
  var jamfProServers = [JamfProServer]()
  var selectedJamfProServer = -1
  
  let jamfPreferencesPath = NSHomeDirectory().replacingOccurrences(of: "/Containers/com.ninxsoft.jamfproswitcher.todayextension/Data", with: "/Preferences/com.jamfsoftware.jss.plist")
  let preferencesPath = NSHomeDirectory().replacingOccurrences(of: "/Containers/com.ninxsoft.jamfproswitcher.todayextension/Data", with: "/Preferences/com.ninxsoft.jamfproswitcher.plist")

  var shouldCloseJamfProApps = false
  let appIdentifiers = ["com.jamfsoftware.CasperAdmin",
                        "com.jamfsoftware.CasperImaging",
                        "com.jamfsoftware.CasperRemote",
                        "com.jamfsoftware.JamfAdmin",
                        "com.jamfsoftware.JamfImaging",
                        "com.jamfsoftware.JamfRemote",
                        "com.jamfsoftware.Recon"]
  
  override var nibName: NSNib.Name? {
    return NSNib.Name("TodayViewController")
  }
  
  func widgetMarginInsets(forProposedMarginInsets defaultMarginInset: NSEdgeInsets) -> NSEdgeInsets {
    return NSEdgeInsetsZero
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.loadPreferences()
    self.setSelectedJamfProServer()
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
    
    for (index, jamfProServer) in self.jamfProServers.enumerated() {
      if jamfProServer.address == address {
        self.selectedJamfProServer = index
        return
      }
    }
  }
  
  override func viewWillAppear() {
    
    // dynamically set the height of the tableview
    if let tableViewRowHeight = self.tableView?.rowHeight {
      self.tableViewHeightConstraint?.constant = tableViewRowHeight * CGFloat(self.jamfProServers.count)
    }
    
    self.switchButton?.isEnabled = self.jamfProServers.isEmpty ? false : self.tableView?.selectedRow != -1
  }
  
  /**
    Called when the Switch button is clicked.
  */
  @IBAction func switchButtonClicked(sender: NSButton) {
    
    if self.shouldCloseJamfProApps && self.areJamfProAppsRunning {
      self.quitJamfProApps()
    }
    else {
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
    self.progressIndicator?.startAnimation(self)
    self.tableView?.isEnabled = false
    self.switchButton?.isEnabled = false
    
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
    for (index, _) in self.jamfProServers.enumerated() {
      if let cell = self.tableView?.view(atColumn: 0, row: index, makeIfNecessary: true) as? TableCellView {
        cell.tickView?.isHidden = index != self.selectedJamfProServer
      }
    }
  }
  
  /**
    Called when the Launch button is clicked.
  */
  @IBAction func launchAppButtonClicked(sender: NSButton) {
    // launch the parent app
    NSWorkspace.shared.launchApplication("Jamf Pro Switcher")
  }
}

extension TodayViewController: NSTableViewDataSource {
  
  func numberOfRows(in tableView: NSTableView) -> Int {
    return self.jamfProServers.count
  }
}

extension TodayViewController: NSTableViewDelegate {
  
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
    self.switchButton?.isEnabled = self.tableView?.selectedRow != -1
  }
}
