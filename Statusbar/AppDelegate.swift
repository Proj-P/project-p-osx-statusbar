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
    
   
    let menuController = MenuController(locationId: Config.LOCATION_ID)
    let timer = TimedNotificationTicker(notificationName:"minutePassed", intervalInSeconds: 60)
    
    
    func menuWillOpen(){
        
    }
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        Fabric.with([Crashlytics.self])

        
        
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
  
    func applicationWillTerminate() {
        // Insert code here to tear down your application
    }
    

    override init(){
        
        
        super.init()
        self.timer.start()
    }
  
    
    func exitNow() {
        menuController.location.closeConnection()
        timer.stop()
        NSApplication.sharedApplication().terminate(self)
    }
    
    
    deinit {
        timer.stop()
        print("goodbye have a great time!1!")
    }
    
    
    
    func openWeb(){
        let siteURL:String          = Config.SITE_URL
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: siteURL)!)
    }
   
    
}

