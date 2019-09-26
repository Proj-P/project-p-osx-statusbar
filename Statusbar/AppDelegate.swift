//
//  AppDelegate.swift
//  Statusbar
//
//  Created by Erik de Groot on 12/07/16.
//  Copyright © 2016 Tjuna. All rights reserved.
//

import Cocoa
import Foundation

@NSApplicationMain

class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    var location: LocationModel = LocationModel(id: Config.LOCATION_ID);
    var socket: SocketConnector?
    var menuController: MenuController?
    
    let queueManager = QueueManager();
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Override point for customization after application launch.
        self.location = LocationModel(id: Config.LOCATION_ID);
        self.socket = SocketConnector(model: self.location)
        self.socket!.listen(event: "location")
        
        // Register initial defaults
        let initialDefaults = ["NSApplicationCrashOnExceptions": true]
        menuController = MenuController(location: self.location, queueManager: queueManager)
        
        
        UserDefaults.standard.register(defaults: initialDefaults)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        socket!.closeConnection()
    }

    func applicationWillTerminate() {
        // Insert code here to tear down your application
        socket!.closeConnection()
    }

    @objc func exitNow() {
        socket!.closeConnection()
        NSApplication.shared.terminate(self)
    }

    @objc func openWeb() {
        let siteURL: String          = Config.SITE_URL
        NSWorkspace.shared.open(URL(string: siteURL)!)
    }

    @objc func toggleQueue() {
        if(location.isOccupied == false)
        {
            queueManager.notifyUser();
            return;
        }
        
        if(queueManager.queued == false) {
            queueManager.start()
        } else {
            queueManager.stop()
        }
    }
}
