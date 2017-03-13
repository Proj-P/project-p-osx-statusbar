//
//  QueueController.swift
//  Statusbar
//
//  Created by Erik de Groot on 09/03/2017.
//  Copyright © 2017 Tjuna. All rights reserved.
//

import Cocoa

class QueueManager: NSObject {
    
    var queued = false
    var observing = false
    var sound = NSUserNotificationDefaultSoundName
    func start()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(self.signal), name:NSNotification.Name(rawValue: "allClear"), object: nil)
        
        observing = true;
        queued = true;
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "queued"), object: queued)
    }
    
    func signal(notification:NSNotification) {
        
        let notification = NSUserNotification()
        notification.title = "Project-P"
        notification.informativeText = "all_clear".localized
        notification.soundName = self.sound
        
        NSUserNotificationCenter.default.deliver(notification)
        
        self.stop()
    }
    
    func stop()
    {
        if(observing)
        {
            NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: "allClear"), object: nil)
            observing = false
        }
        queued = false
        NotificationCenter.default.post(name: Notification.Name(rawValue: "queued"), object: queued)
    }
}
