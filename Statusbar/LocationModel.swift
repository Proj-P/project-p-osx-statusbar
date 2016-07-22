//
//  locationModel.swift
//  Statusbar
//
//  Created by Erik de Groot on 22/07/16.
//  Copyright © 2016 Tjuna. All rights reserved.
//

import Cocoa
import SocketIOClientSwift
import SwiftyJSON



class LocationModel: NSObject {
    let apiURL:String      = Config.API_URL
    var state🚽🔒:String?
    var isOccupied:Bool?
    var start🕛: NSDate?
    var end🕛: NSDate?
    var lastUpdateDate:NSDate?
    
    let socket      = SocketIOClient(socketURL: NSURL(string: Config.API_URL)!, options: [.Log(false), .ForcePolling(true)]) // needs to be class variable, or else arc will kill it
    var locationId:Int
    
    init(id:Int) {
        // perform some initialization here
        self.locationId = id
        super.init()
        self.checkLastVisit()
        self.socketConnect()
    }
    
    func socketConnect()
    {
        
        
        socket.on("connect") {data, ack in
            print("socket connected")
        }
        
        socket.on("location") {data, ack in
            print("location updated")

            if let dateString = data[0]["data"]!!["changed_at"]{
                
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-dd-MM'T'HH:mm:ss'Z'"
                let date = dateFormatter.dateFromString(String(dateString))
                let state = data[0]["data"]!!["occupied"]
                if(state == 1)
                {
                    self.start🕛 =  date;
                }else{
                    self.end🕛   =  date;
                }
            }
            if let state = data[0]["data"]!!["occupied"]  {
                self.updateState(state == 1)
            }
            
            
        }
        
        socket.connect()
    }
    
    func updateState(occupied:Bool)
    {
        if(occupied == true)
        {
            print("isOccupied");
            state🚽🔒   =  "🔒"
            start🕛     =  NSDate()
        }else{
            print("free");
            state🚽🔒   = "🔓"
            end🕛       =  NSDate()
        }
        
        self.lastUpdateDate = NSDate()
        isOccupied = occupied
        NSNotificationCenter.defaultCenter().postNotificationName("locationStateUpdate", object: nil)
    }
    
    func handleLocationData(result:JSON)
    {
        
        let state :Int = Int(result["data"]["occupied"].int!)
        let dateString = result["data"]["changed_at"].string!
        
                
                
                let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-dd-MM'T'HH:mm:ss'Z'"
            if let date = dateFormatter.dateFromString(dateString)
            {
                if(state == 1)
                {
                    start🕛 =  date;
                }else{
                    end🕛   =  date;
                }
            }
        
            self.updateState(state == 1)
    }
    
    deinit{
        self.closeConnection();
    }
 
    func closeConnection() {
        socket.disconnect()
    }
    
    func checkLastVisit()
    {
        RestApiManager.sharedInstance.getLocationData(locationId, onCompletion: self.handleLocationData);
    }
}
