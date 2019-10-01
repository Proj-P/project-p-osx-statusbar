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
    var isOpen: Bool = false
    var location: LocationModel
    var lastUpdate: Date = Date()

    init(location: LocationModel, queueManager: QueueManager) {
        self.location = location
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
        NotificationCenter.default.addObserver(self, selector: #selector(self.locationStateUpdate), name: NSNotification.Name(rawValue: "locationStateUpdate"), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(self.queueStateUpdate), name: NSNotification.Name(rawValue: "queued"), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(self.visitsUpdate), name: NSNotification.Name(rawValue: "lastVisitUpdate"), object: nil)
    }

    func menuDidClose(_ menu: NSMenu) {
        self.isOpen = false
    }

    func menuWillOpen(_ menu: NSMenu) {
        self.isOpen = true
    }

    func updateItems() {
        print("updating menu")

        menu.updateItems(location: self.location)
    }

    func menuNeedsUpdate(_: NSMenu) {
        updateItems()
    }

    @objc func queueStateUpdate(_ notification: NSNotification) {
        let state = notification.object as! Bool
        menu.queued = state
    }

    @objc func visitsUpdate(_ notification: Notification) {
        if(isOpen) {
            self.updateItems()
        }
    }

    @objc func locationStateUpdate(_ notification: Notification) {

        menu.updateIcon(isOccupied: self.location.isOccupied ?? false)

        if(menu.queued && self.location.isOccupied == false) {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "allClear"), object: nil)
        }

        if(isOpen) {
            self.updateItems()
        }
    }
}
