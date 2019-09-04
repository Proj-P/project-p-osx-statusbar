//
//  Timer.swift
//  Statusbar
//
//  Created by Erik de Groot on 22/07/16.
//  Copyright © 2016 Tjuna. All rights reserved.
//

import Cocoa

class TimedNotificationTicker: NSObject {

    var timer: Timer?
    var notificationName: String
    var intervalInSeconds: TimeInterval

    init(notificationName: String, intervalInSeconds: TimeInterval) {
        self.notificationName = notificationName
        self.intervalInSeconds = intervalInSeconds

    }

    func start() {
        timer = Timer.scheduledTimer(timeInterval: self.intervalInSeconds, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)

    }

    @objc func runTimedCode() {
         NotificationCenter.default.post(name: Notification.Name(rawValue: self.notificationName), object: nil)
    }

    func stop() {
        timer!.invalidate()
    }
}
