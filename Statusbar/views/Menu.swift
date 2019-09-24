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
    let durationMenuItem = NSMenuItem()
    var queueItem = NSMenuItem()
    var titleItem = NSMenuItem()
    var exitItem = NSMenuItem()
    
    var smellText: String = ""
    var lastVisitDateText: String = ""
    var durationText: String = ""
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
        self.addItem(NSMenuItem.separator())
        self.addItem(smellMenuItem)
        self.addItem(NSMenuItem.separator())
        self.addItem(timeMenuItem)
        self.addItem(durationMenuItem)
        self.addItem(queueItem)
        self.addItem(NSMenuItem.separator())
        self.addItem(exitItem)
        
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
        
        icon = NSImage(named: (location.isOccupied!) ? "tp2_occ" : "tp2_free")
        statusItem.image = icon
        //            icon?.template = true // best for dark mode
        
        let end🕛       = location.lastVisit?.end🕛
        let start🕛     = location.lastVisit?.start🕛
        let duration    = location.lastVisit?.duration
        
        if end🕛 != nil && start🕛 != nil {
            
            var lastVisitDuration   = Int(floor(duration! / 60)) // visit time in minutes
            let interval            = end🕛!.timeIntervalSinceNow // time ago in seconds
            
            lastVisitDateText   = stringFromTimeInterval(interval) as String
            smellText           = stincrementCalculator.calculate(lastVisitDuration, timeAgo🕛: Int(interval))
            lastVisitDuration         = max(1, lastVisitDuration)
            
            durationText        = "\(lastVisitDuration) min"
            
            if(smellText == "✨" && location.isOccupied! == false) {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "allClear"), object: nil)
            }
            
        } else {
            // no data of subsequent visits to show yet!
            smellText            = "?"
            lastVisitDateText    = "?"
            durationText         = "?"
        }
        
        smellMenuItem.title     = "smell_o_meter_label".localized + smellText
        timeMenuItem.title      = "last_visit_label".localized + lastVisitDateText
        durationMenuItem.title  = "duration_label".localized + durationText
        
        switch Config.STYLE {
        case 1:
            if location.state🚽🔒 != nil {
                let text = (location.state🚽🔒 == "🔒") ? "Occupado!" : "Go ahead!"
                stateMenuItem.title = "🚽  " + location.state🚽🔒! + text
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
        
        
        queueItem.title = (queued==false)
            ? "queue_start".localized
            : "queue_stop".localized
        
        self.update()
    }
    
    func stringFromTimeInterval(_ interval: TimeInterval) -> String {
        
        let hours = Config.API_HOUR_OFFSET
        let offset = Double(hours * 3600)
        let totalInterval = Double(interval + offset)
        let fromDate = Date() - totalInterval
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let lastDate = NSDate().addingTimeInterval(totalInterval)
        let last = formatter.string(from: lastDate as Date)
        
        return last + " (" + fromDate.timeAgoSinceNow + ")"
    }
}
