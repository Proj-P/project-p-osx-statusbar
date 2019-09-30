//
//  Menu.swift
//  Statusbar
//
//  Created by Erik de Groot on 03/09/2019.
//  Copyright © 2019 Tjuna. All rights reserved.
//

import Cocoa
import DateToolsSwift
import Foundation

class Menu: NSMenu {
    
    var queueText = "queue_start".localized
    let stincrementCalculator   = StincrementCalculator()
    
    let smellMenuItem   = NSMenuItem()
    let timeMenuItem    = NSMenuItem()
    let stateMenuItem   = NSMenuItem()
    var queueItem = NSMenuItem()
    var titleItem = NSMenuItem()
    var exitItem = NSMenuItem()
    
    var smellText: String = ""
    var lastVisitDateText: String = ""
    var icon = NSImage(named: ("tp2_free"))
    var statusItem: NSStatusItem
    var queued:Bool;
    
    init(title: String, location: LocationModel, statusItem:NSStatusItem, queued:Bool){
        self.queued = queued
        self.statusItem = statusItem
        super.init(title: title)
        queueItem = NSMenuItem(title: self.queueText, action: #selector(AppDelegate.toggleQueue), keyEquivalent:
            "e")
        titleItem = NSMenuItem(title: "ProjectP", action: #selector(AppDelegate.openWeb), keyEquivalent:
            "w")
        exitItem = NSMenuItem(title: "quit".localized, action: #selector(AppDelegate.exitNow), keyEquivalent: "q")
        
        paint()
    }
    
    required init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    func paint(){
        statusItem.image = icon
        //        statusItem.action = #selector(AppDelegate.openWeb)
        
        self.addItem(titleItem)
        self.addItem(NSMenuItem.separator())
        self.addItem(stateMenuItem)
        self.addItem(smellMenuItem)
        self.addItem(NSMenuItem.separator())
        self.addItem(timeMenuItem)
        self.addItem(NSMenuItem.separator())
        self.addItem(queueItem)
        self.addItem(NSMenuItem.separator())
        self.addItem(exitItem)
        
    }
    
    func updateIcon(isOccupied:Bool){
        self.icon = NSImage(named: (isOccupied) ? "tp2_occ" : "tp2_free")
        DispatchQueue.main.async { //image should be changed on main thread
            self.statusItem.image = self.icon
        }
    }
    
    func updateItems(location:LocationModel){
        if(location.lastUpdateDate == nil)
        {
            return
        }
        
        icon?.isTemplate = true // best for dark mode
        titleItem.image = NSImage(named: "icon")
        
        if location.lastUpdateDate == nil{ // location was not yet loaded
            self.addItem(NSMenuItem(title: "network_error".localized, action: nil, keyEquivalent: ""))
            
        }

        //            icon?.template = true // best for dark mode
        

        
        if let lastVisit = location.lastVisit {
            let end🕛       = lastVisit.end🕛
            let duration    = lastVisit.duration
            
            let durationMin     = max(1, duration / 60) // visit time in minutes
            let interval        = end🕛.timeIntervalSinceNow // time ago in seconds
            let intervalMin         = Int(floor(interval / 60))
            
            lastVisitDateText   = stringFromTimeInterval(interval, durationMin) as String
            smellText           = stincrementCalculator.calculate(durationMin, timeAgo🕛: intervalMin)
        } else {
            // no data of subsequent visits to show yet!
            smellText            = "?"
            lastVisitDateText    = "?"
        }
        
        smellMenuItem.title     = "smell_o_meter_label".localized + smellText
        timeMenuItem.title      = "last_visit_label".localized + lastVisitDateText
        
        switch Config.STYLE {
        case 1:
            if location.state🚽🔒 != nil {
                let text = (location.state🚽🔒 == "🔒") ? "Occupado!" : "Go ahead!"
                stateMenuItem.title = "🚽" + location.state🚽🔒! + text
            }
            break
        case 2:
            let imageName = (location.isOccupied! == true)
                ? "project-p-tray-16-closed"
                : "project-p-tray-16-open"
            stateMenuItem.image = NSImage(named: imageName)
            stateMenuItem.title = location.state🚽🔒!
            break
        default:
            break
        }
        
        queueItem.isEnabled = location.isOccupied!
        
        queueItem.title = (queued==false)
            ? "queue_start".localized
            : "queue_stop".localized
        

        self.update()
    }
    
    func stringFromTimeInterval(_ interval: TimeInterval, _ durationMin: Int) -> String {
        
        let hours = Config.API_HOUR_OFFSET
        let offset = Double(hours * 3600)
        let totalInterval = Double(interval + offset)
        let fromDate = Date() - totalInterval
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let lastDate = NSDate().addingTimeInterval(totalInterval)
        let last = formatter.string(from: lastDate as Date)
        let date = fromDate.timeAgoSinceNow
        return "\(date) (\(last), \(durationMin) min)"
    }
}
