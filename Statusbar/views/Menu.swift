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
    var icon = NSImage(named: "tp2_free")
    var visitCount = 0

    let stincrementCalculator   = StincrementCalculator()

    let smellMenuItem   = NSMenuItem()
    let timeMenuItem    = NSMenuItem()
    let stateMenuItem   = NSMenuItem()
    var locationItem    = NSMenuItem()
    var errorItem       = NSMenuItem(
        title: "network_error".localized,
        action: nil,
        keyEquivalent: ""
    )

    var queueItem = NSMenuItem(
        title: "queue_start".localized,
        action: #selector(AppDelegate.toggleQueue),
        keyEquivalent: "e"
    )

    var titleItem = NSMenuItem(
        title: "ProjectP",
        action: #selector(AppDelegate.openWeb),
        keyEquivalent: "w"
    )

    var exitItem = NSMenuItem(
        title: "quit".localized,
        action: #selector(AppDelegate.exitNow),
        keyEquivalent: "q"
    )

    var refreshItem = NSMenuItem(
        title: "refresh".localized,
        action: #selector(AppDelegate.refreshInfo),
        keyEquivalent: "r"
    )

    var smellText: String = ""
    var lastVisitDateText: String = ""

    var statusItem: NSStatusItem
    var queued: Bool

    init(title: String, statusItem: NSStatusItem, queued: Bool) {
        self.queued = queued
        self.statusItem = statusItem

        titleItem.image = NSImage(named: "icon")
        super.init(title: title)

        self.updateIcon(isOccupied: false)
        paint()
    }

    required init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func paint() {
        icon!.isTemplate = true // best for dark mode

        self.addItem(titleItem)
        self.addItem(NSMenuItem.separator())
        self.addItem(locationItem)
        self.addItem(NSMenuItem.separator())
        self.addItem(stateMenuItem)
        self.addItem(smellMenuItem)
        self.addItem(NSMenuItem.separator())
        self.addItem(timeMenuItem)
        self.addItem(NSMenuItem.separator())
        self.addItem(queueItem)
        self.addItem(NSMenuItem.separator())
        if(Config.MANUAL_REFRESH) {
            self.addItem(refreshItem)
        }
        self.addItem(NSMenuItem.separator())
        self.addItem(exitItem)

    }

    func updateIcon(isOccupied: Bool) {
        self.icon = NSImage(named: (isOccupied) ? "tp2_occ" : "tp2_free")
        DispatchQueue.main.async { //image should be changed on main thread
            self.statusItem.image = self.icon
        }
    }

    func showError() {
        self.addItem(errorItem)
    }

    func updateItems(location: Location, lastVisit: LocationVisit?) {
        locationItem.title = "\("location".localized): \(location.name)" +
        " (\(visitCount) \("visits today".localized))"

        if (lastVisit != nil) {
            let end🕛       = lastVisit!.endTime
            let duration    = lastVisit!.duration

            let durationMin     = max(1, duration / 60) // visit time in minutes
            let interval        = end🕛.timeIntervalSinceNow // time ago in seconds
            let intervalMin     = Int(floor(interval / 60))

            lastVisitDateText   = stringFromTimeInterval(interval, durationMin) as String
            smellText           = stincrementCalculator.calculate(durationMin, timeAgo🕛: intervalMin)
        } else {
            // no data of subsequent visits to show yet!
            smellText            = "-"
            lastVisitDateText    = "-"
        }

        let stateText = (location.occupied) ?
            "occupied_true".localized :
            "occupied_false".localized

        smellMenuItem.title     = "smell_o_meter_label".localized + smellText
        timeMenuItem.title      = "last_visit_label".localized + lastVisitDateText
        stateMenuItem.title     = "status_label".localized + stateText

        queueItem.isEnabled = location.occupied

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
