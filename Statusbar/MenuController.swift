//
//  MenuViewController.swift
//  Statusbar
//
//  Created by Erik de Groot on 22/07/16.
//  Copyright © 2016 Tjuna. All rights reserved.
//

import Cocoa
import DateToolsSwift


class MenuController: NSObject, NSMenuDelegate {

    let statusItem  = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    
    let siteURL:String          = Config.SITE_URL
    
    var queueText = "queue_start".localized
    var location:LocationModel
    var menu:NSMenu = NSMenu()
    var lastUpdate:Date = Date()
    
//    private var kvoContext: UInt8 = 1
    
    init(locationId:Int){
        
        location  = LocationModel(id: locationId)  // for simplicity, only keep 1 location model
        super.init()
        
        self.update()
        self.placeObservers()
    }
    
    func placeObservers()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(self.locationStateChanged(_:)), name:NSNotification.Name(rawValue: "locationStateUpdate"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.locationStateChanged(_:)), name:NSNotification.Name(rawValue: "minutePassed"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.queueStateChanged(_:)), name:NSNotification.Name(rawValue: "queued"), object: nil)
    }
    
    
    func locationStateChanged(_ notification: Notification){
        self.update()
    }
    
    func create(_ location:LocationModel) -> NSMenu{
        let stincrementCalculator   = StincrementCalculator()
        let menu                    = NSMenu()
        var icon                    = NSImage(named:("tp_free"))
        icon?.isTemplate = true // best for dark mode
        menu.delegate               = self
        
        let titleItem = NSMenuItem(title: "ProjectP", action: #selector(AppDelegate.openWeb) , keyEquivalent:
            "w")
        let queueItem = NSMenuItem(title: self.queueText, action: #selector(AppDelegate.toggleQueue) , keyEquivalent:
            "e")
        titleItem.image = NSImage(named:"icon")
        
        
        
        if location.lastUpdateDate != nil && (location.lastUpdateDate! as Date == self.lastUpdate) == false {
            
            icon = NSImage(named:(location.isOccupied!) ? "tp_occ" : "tp_free")
            
            //            icon?.template = true // best for dark mode
            
            let smellMenuItem   = NSMenuItem()
            let timeMenuItem    = NSMenuItem()
            let stateMenuItem   = NSMenuItem()
            let durationMenuItem = NSMenuItem()
            
            var smellText:String
            var lastVisitDateText:String
            var durationText:String
            
            let end🕛       = location.lastVisit?.end🕛
            let start🕛     = location.lastVisit?.start🕛
            let duration    = location.lastVisit?.duration
            
            if end🕛 != nil && start🕛 != nil {
                
                var lastVisitDuration   = Int(floor(duration! / 60)) // visit time in minutes
                let interval            = end🕛!.timeIntervalSinceNow // time ago in seconds
                
                lastVisitDateText   = self.stringFromTimeInterval(interval) as String
                smellText           = stincrementCalculator.calculate(lastVisitDuration * 60, passed🕛: Int(interval))
                lastVisitDuration         = max(1, lastVisitDuration)
                
                durationText        = "\(lastVisitDuration) min"
                
                if(smellText == "✨" && location.isOccupied! == false)
                {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "allClear"), object: nil)
                }
                
            }else{
                // no data of subsequent visits to show yet!
                smellText            = "?"
                lastVisitDateText    = "?"
                durationText         = "?"
            }
            
            smellMenuItem.title     = "smell_o_meter_label".localized + smellText
            timeMenuItem.title      = "last_visit_label".localized + lastVisitDateText
            durationMenuItem.title  = "duration_label".localized + durationText
            
            switch Config.STYLE{
            case 1:
                if location.state🚽🔒   != nil {
                    stateMenuItem.title = "🚽  " + location.state🚽🔒!
                }
                break
            case 2:
                let imageName = (location.isOccupied! == true)
                    ? "project-p-tray-16-closed"
                    : "project-p-tray-16-open"
                stateMenuItem.image = NSImage(named:imageName)
                stateMenuItem.title = location.state🚽🔒!
                break
            default:
                break
            }
            
            menu.addItem(titleItem)
            menu.addItem(NSMenuItem.separator())
            menu.addItem(smellMenuItem)
            menu.addItem(timeMenuItem)
            menu.addItem(durationMenuItem)
            menu.addItem(queueItem)
            menu.addItem(NSMenuItem.separator())
            menu.addItem(stateMenuItem)
            
        }else{ // location was not yet loaded
            menu.addItem(NSMenuItem(title: "network_error".localized, action:nil, keyEquivalent:""))
        }
        
        statusItem.image = icon
        statusItem.action = #selector(AppDelegate.openWeb)

        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "quit".localized, action:  #selector(self.exitNow), keyEquivalent: "q"))
        return menu

    }
    
    func update(){
        print("updating menu")
        menu = self.create(location)
        statusItem.menu = menu
    }
    

    
    func exitNow() {
        self.location.closeConnection()
        
        NSApplication.shared().terminate(self)
    }
    
    
    deinit {
        
        print("goodbye have a great time!1!")
    }
    
   
   
//    
//    func stringFromTimeInterval(_ interval:TimeInterval) -> String {
//        
//        let ti = NSInteger(interval)
//        
//        
//        let minutes = (ti / 60) % 60
//        let hours = (ti / 3600) - 5
//        
//        
//        
//        if hours != 0{
//            return String(format: "%dh:%0.2dm",hours,minutes)
//        }else{
//            return String(format: "%dm",minutes)
//        }
//    }
    
    func queueStateChanged(_ notification:NSNotification){
        let state = notification.object as! Bool
        self.updateQueueState(state)
    }
    
    func updateQueueState(_ queued:Bool)
    {
        self.queueText = (queued==true) ? "queue_start".localized : "queue_stop".localized;
        self.update()
    }

//  once the api clock issues are fixed, ise this one
    func stringFromTimeInterval(_ interval:TimeInterval) -> String {
        
        
        let hours = Config.API_HOUR_OFFSET;
        let offset = Double(hours * 3600);
        let totalInterval = Double(interval + offset);
        let fromDate = Date() - totalInterval
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let lastDate = NSDate().addingTimeInterval(totalInterval)
        let last = formatter.string(from: lastDate as Date)
        
        return last + " (" + fromDate.timeAgoSinceNow + ")"
    }
}
