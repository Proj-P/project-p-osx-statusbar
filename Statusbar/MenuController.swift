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

    let statusItem  = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    let siteURL: String = Config.SITE_URL

    var menu: Menu
    var location: LocationModel
    var lastUpdate: Date = Date()
//    private var kvoContext: UInt8 = 1

    init(location: LocationModel, queueManager: QueueManager) {
        self.location = location;
        self.menu = Menu(
            title: "Main menu",
            location: location,
            statusItem: statusItem,
            queued: queueManager.queued
        )
        
        super.init()
        
        statusItem.menu = menu
        menu.delegate = self
        self.updateItems()
        menu.updateIcon(isOccupied: location.isOccupied ?? false)
        self.placeObservers()
    }
    
    func placeObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.locationStateChanged(_:)), name: NSNotification.Name(rawValue: "locationStateUpdate"), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(self.queueStateChanged(_:)), name: NSNotification.Name(rawValue: "queued"), object: nil)
    }

    @objc func locationStateChanged(_ notification: Notification) {
        menu.updateIcon(isOccupied: location.isOccupied ?? false)
        self.updateItems()
    }

    func updateItems() {
        print("updating menu")
        menu.updateItems(location: location)
    }
    
    func menuNeedsUpdate(_: NSMenu){
        updateItems()
    }


    deinit {
        print("goodbye have a great time!1!")
    }

    @objc func queueStateChanged(_ notification: NSNotification) {
        let state = notification.object as! Bool
        menu.queued = state
    }
}
