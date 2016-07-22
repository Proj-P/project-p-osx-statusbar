//
//  Timer.swift
//  Statusbar
//
//  Created by Erik de Groot on 22/07/16.
//  Copyright © 2016 Tjuna. All rights reserved.
//

import Cocoa

class TimedNotificationTicker: NSObject {

    var timer:NSTimer?
    var notificationName: String
    var intervalInSeconds:NSTimeInterval
    
    init(notificationName:String, intervalInSeconds:NSTimeInterval)
    {
        self.notificationName = notificationName
        self.intervalInSeconds = intervalInSeconds
        
    }
    
    func start() {
       timer = NSTimer.scheduledTimerWithTimeInterval(self.intervalInSeconds, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)
      
    }
    
    func runTimedCode() {
         NSNotificationCenter.defaultCenter().postNotificationName(self.notificationName, object: nil)
    }
    
    func stop() {
        timer!.invalidate()
    }
}
