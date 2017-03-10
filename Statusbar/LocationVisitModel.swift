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



class LocationVisitModel: NSObject {
    
    var start🕛: Date
    var end🕛: Date
    
    var locationId:Int
    var locationVisitId:Int
    var duration:Double
    
    init(id:Int, end🕛:String!, start🕛:String!, locationId:Int, duration:Double) {
        // perform some initialization here
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd MM yyyy HH:mm:ss zzz"
        
        
        self.locationVisitId = id
        self.end🕛      = dateFormatter.date(from: end🕛)!
        self.start🕛    = dateFormatter.date(from: start🕛)!
        self.locationId = locationId
        self.duration   = duration
        
        
        print("start date",self.start🕛)
        print("end date", self.end🕛)
        super.init()
        
    }
    
  
    
}
