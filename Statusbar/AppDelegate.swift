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
    
   
    let menuController = MenuController(locationId: Config.LOCATION_ID)
    
    
    
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        
        
        
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
  
    func applicationWillTerminate() {
        // Insert code here to tear down your application
    }
    
 
   
    
   
    
}

