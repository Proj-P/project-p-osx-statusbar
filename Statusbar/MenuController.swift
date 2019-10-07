//
//  MenuViewController.swift
//  Statusbar
//
//  Created by Erik de Groot on 22/07/16.
//  Copyright © 2016 Tjuna. All rights reserved.
//

import Cocoa

class MenuController: NSObject, NSMenuDelegate {

    let statusItem  = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let siteURL: String = Config.SITE_URL
    var menu: Menu
    var isOpen: Bool = false
    var locationModel: LocationModel
    var lastUpdate: Date = Date()
    var queueManager: QueueManager

    init(locationModel: LocationModel, queueManager: QueueManager) {
        self.locationModel = locationModel
        self.queueManager = queueManager

        self.menu = Menu(
            title: "Main menu",
            statusItem: statusItem,
            queued: queueManager.queued
        )

        super.init()

        statusItem.menu = menu
        menu.delegate = self
        menu.visitCount = self.locationModel.visits.count

        menu.updateIcon(isOccupied: false)
        self.updateItems()

        self.placeObservers()
    }

    private func placeObservers() {
        self.locationModel.onOccupationChange.subscribe(with: self) { (occupied) in
            self.menu.updateIcon(isOccupied: occupied)

            if(self.queueManager.queued && occupied == false) {
                self.queueManager.signal()
            }

            if(self.isOpen) {
               self.updateItems()
            }
        }

        self.locationModel.onVisits.subscribe(with: self) {_ in
            if(self.isOpen) {
                self.updateItems()
            }
        }
    }

    func menuDidClose(_ menu: NSMenu) {
        self.isOpen = false
    }

    func menuWillOpen(_ menu: NSMenu) {
        locationModel.getLastVisitsFromRest(self.locationModel.locationId)
        menu.update()
        self.isOpen = true
    }

    func updateItems() {
        menu.queued = self.queueManager.queued

        guard let location = self.locationModel.location else {
            return
        }

        menu.visitCount = self.locationModel.getVisitsToday()
        menu.updateItems(location: location, lastVisit: self.locationModel.lastVisit)
    }

    func menuNeedsUpdate(_: NSMenu) {
        updateItems()
    }
}
