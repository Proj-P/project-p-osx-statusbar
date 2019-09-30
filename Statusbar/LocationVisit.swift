//
//  locationModel.swift
//  Statusbar
//
//  Created by Erik de Groot on 22/07/16.
//  Copyright © 2016 Tjuna. All rights reserved.
//

import Cocoa
import SocketIO
import SwiftyJSON

class LocationVisit: NSObject {

    var start🕛: Date
    var end🕛: Date
    var locationId: Int
    var locationVisitId: Int
    var duration: Int

    init(id: Int, end🕛:String!, start🕛:String!, locationId: Int, duration: Int) {
        // perform some initialization here
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"

        self.locationVisitId = id
        self.end🕛      = formatter.date(from: end🕛)!
        self.start🕛    = formatter.date(from: start🕛)!
        self.locationId = locationId
        self.duration   = duration

        super.init()
    }

    init(data: [String: Any]) {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"

        self.locationVisitId = data["id"] as! Int
        let end🕛 = data["end_time"] as! String
        let start🕛  = data["start_time"] as! String
        self.locationId = data["location_id"] as! Int
        self.duration = Int(floor(data["duration"] as! Double))

        self.end🕛      = formatter.date(from: end🕛)!
        self.start🕛    = formatter.date(from: start🕛)!
    }

}
