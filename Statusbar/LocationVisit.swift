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

class LocationVisit {

    var startTime: Date
    var endTime: Date
    var locationId: Int
    var locationVisitId: Int
    var duration: Int

    init(id: Int, endTime: String!, startTime: String!, locationId: Int, duration: Int) {
        // perform some initialization here

        self.locationVisitId = id
        self.endTime      = endTime.toDate
        self.startTime    = startTime.toDate
        self.locationId   = locationId
        self.duration     = duration
    }

    init(data: [String: Any]) {

        self.locationVisitId = data["id"] as! Int
        self.locationId      = data["location_id"] as! Int
        self.duration        = Int(floor(data["duration"] as! Double))

        let endTimeString    = data["end_time"] as! String
        let startTimeString  = data["start_time"] as! String

        self.endTime      = endTimeString.toDate
        self.startTime    = startTimeString.toDate
    }

}
