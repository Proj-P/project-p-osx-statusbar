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
    
    let menuController = MenuController(locationId: (UserDefaults.standard.integer(forKey: "locationId") != 0)
        ? UserDefaults.standard.integer(forKey: "locationId")
        : Config.LOCATION_ID)
    
    let queueManager = QueueManager();
    let timer = TimedNotificationTicker(notificationName:"minutePassed", intervalInSeconds: 60)
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Register initial defaults
        let initialDefaults = ["NSApplicationCrashOnExceptions": true]
        
        UserDefaults.standard.register(defaults: initialDefaults)
        Fabric.with([Crashlytics.self])
        self.timer.start()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        menuController.location.closeConnection()
        timer.stop()
    }
    
  
    func applicationWillTerminate() {
        // Insert code here to tear down your application
        menuController.location.closeConnection()
        timer.stop()
    }
    
    
    func exitNow() {
        NSApplication.shared().terminate(self)
    }
    
    
    func openWeb(){
        let siteURL:String          = Config.SITE_URL
        NSWorkspace.shared().open(URL(string: siteURL)!)
    }
    
    func toggleQueue()
    {
        if(queueManager.queued == false)
        {
            queueManager.start()
        }else{
            queueManager.stop()
        }
    }
}

