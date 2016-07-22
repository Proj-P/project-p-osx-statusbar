//
//  MenuViewController.swift
//  Statusbar
//
//  Created by Erik de Groot on 22/07/16.
//  Copyright © 2016 Tjuna. All rights reserved.
//

import Cocoa


class MenuController: NSObject {

    let statusItem  = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
    
    let siteURL:String          = Config.SITE_URL
    let stincrementCalculator   = StincrementCalculator()
    var location:LocationModel
    var menu:NSMenu = NSMenu()
    let timer = TimedNotificationTicker(notificationName:"menuMinutePassed", intervalInSeconds: 60)
    
    private var kvoContext: UInt8 = 1
    
    init(locationId:Int){
        
        location        = LocationModel(id: locationId)  // for simplicity, only keep 1 location model
        super.init()
        
        self.updateMenu()
        self.placeObservers()
        self.timer.start()
    }
    
    func placeObservers()
    {
        location.addObserver(self, forKeyPath: "isOccupied",
                             options: NSKeyValueObservingOptions.New, context: &kvoContext)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MenuController.locationStateChanged(_:)), name:"locationStateUpdate", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MenuController.locationStateChanged(_:)), name:"menuMinutePassed", object: nil)
        
        
    }
    
    func locationStateChanged(notification: NSNotification){
        self.updateMenu();
    }
    
    
    func updateMenu(){
        menu = NSMenu()
        
        if location.lastUpdateDate != nil{
            
            let icon = NSImage(named:(location.isOccupied!) ? "tp_occ" : "tp_free")
            icon?.template = true // best for dark mode
            statusItem.image = icon
        
            statusItem.action = #selector(self.openWeb)
            
            let smellMenuItem   = NSMenuItem()
            let timeMenuItem    = NSMenuItem()
            let stateMenuItem   = NSMenuItem()
            
            var smellText:String            = "?"
            var lastVisitDateText:String    = "?"
        
            if location.end🕛 !== nil && location.start🕛 !== nil {
            
                
                let lastVisit🕛     = Int((location.end🕛!.timeIntervalSinceDate(location.start🕛!) / 60) % 60); // visit time in minutes
                let interval🕛      = Int((location.end🕛!.timeIntervalSinceDate(NSDate()) / 60) % 60); // time ago in minutes
                
                smellText = stincrementCalculator.calculate(lastVisit🕛)
                
                let timeAgoString   = interval🕛 == 0 ? "~1 min" : "\(interval🕛) min"
                let durationString  = "\(lastVisit🕛) min"
                lastVisitDateText   = "" + timeAgoString + " ago (" + durationString + ")"
            
            
            }else{
                // no data of subsequent visits to show yet!
              
            }
        
    
            smellMenuItem.title = "💨  " + smellText
            timeMenuItem.title  = "🕛  " + lastVisitDateText
            if location.state🚽🔒 != nil
            {
                stateMenuItem.title = "🚽  " + location.state🚽🔒!
            }
            menu.addItem(smellMenuItem)
            menu.addItem(timeMenuItem)
            menu.addItem(stateMenuItem)
            
        }else{ // location was not yet loaded
            let icon = NSImage(named:("tp_free"))
            icon?.template = true // best for dark mode
            statusItem.image = icon
        }
        
        menu.addItem(NSMenuItem(title: "ProjectP", action: #selector(self.openWeb), keyEquivalent: "w"))
        menu.addItem(NSMenuItem.separatorItem())
        menu.addItem(NSMenuItem(title: "Quit", action:  #selector(self.exitNow), keyEquivalent: "q"))
        
        
        statusItem.menu = menu
    }
    

    
    func exitNow() {
        self.location.closeConnection()
        timer.stop()
        NSApplication.sharedApplication().terminate(self)
    }
    
    
    deinit {
        timer.stop()
        print("goodbye have a great time!1!")
    }
    
    
    
    func openWeb(){
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: siteURL)!)
    }
}
