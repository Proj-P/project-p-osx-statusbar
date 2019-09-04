//
//  AppDelegate.swift
//  Statusbar
//
//  Created by Erik de Groot on 12/07/16.
//  Copyright © 2016 Tjuna. All rights reserved.
//

import Cocoa
import Foundation
import Fabric
import Crashlytics

@NSApplicationMain

class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    let location = LocationModel(id: Config.LOCATION_ID)
    var menuController: MenuController?
    
    let queueManager = QueueManager();
    let timer = TimedNotificationTicker(notificationName: "minutePassed", intervalInSeconds: 60)

    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Register initial defaults
        let initialDefaults = ["NSApplicationCrashOnExceptions": true]
        menuController = MenuController(location: self.location, queueManager: queueManager)
        
        
        UserDefaults.standard.register(defaults: initialDefaults)
        Fabric.with([Crashlytics.self])
        self.timer.start()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        menuController!.location.closeConnection()
        timer.stop()
    }

    func applicationWillTerminate() {
        // Insert code here to tear down your application
        menuController!.location.closeConnection()
        timer.stop()
    }

    @objc func exitNow() {
        self.location.closeConnection()
        NSApplication.shared.terminate(self)
    }

    @objc func openWeb() {
        let siteURL: String          = Config.SITE_URL
        NSWorkspace.shared.open(URL(string: siteURL)!)
    }

    @objc func toggleQueue() {
        if(queueManager.queued == false) {
            queueManager.start()
        } else {
            queueManager.stop()
        }
    }
}
