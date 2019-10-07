//
//  QueueController.swift
//  Statusbar
//
//  Created by Erik de Groot on 09/03/2017.
//  Copyright © 2017 Tjuna. All rights reserved.
//

import Signals

class QueueManager {

    var queued = false
    var observing = false
    var sound = NSUserNotificationDefaultSoundName
    var onQueue = Signal<Date>()

    func start() {
        NotificationCenter.default.addObserver(self, selector: #selector(signal), name: NSNotification.Name(rawValue: "allClear"), object: nil)

        observing = true
        queued = true

        onQueue.fire(Date())
    }

    @objc func signal() {
        notifyUser()
        self.stop()
    }

    func notifyUser() {
        let notification = NSUserNotification()
        notification.title = "Project-P"
        notification.informativeText = "all_clear".localized
        notification.soundName = self.sound

        NSUserNotificationCenter.default.deliver(notification)
    }

    func stop() {
        if(observing) {
            NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: "allClear"), object: nil)
            observing = false
        }
        queued = false
    }
}
