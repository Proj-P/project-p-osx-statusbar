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



class LocationModel: NSObject {
    let apiURL:String      = Config.API_URL
    var state🚽🔒:String?
    var isOccupied:Bool?
    var lastUpdateDate:Date?
    var locationId:Int
    var lastVisit:LocationVisitModel?
    
    let socket      = SocketIOClient(socketURL: URL(string: Config.API_URL)!) // needs to be class variable, or else arc will kill it
    
    
    init(id:Int) {
        // perform some initialization here
        self.locationId = id
        
        super.init()
        
        self.getLocationFromRest(id)
        self.getLastVisitFromRest(id)
        self.socketConnect()
    }
    
    func socketConnect()
    {
        socket.on("connect") {data, ack in
            print("socket connected")
        }
        
        socket.on("location") {result, ack in
            if let data = result as? Array<Dictionary<String, Dictionary<String, AnyObject>>>{
                let row = data[0]["data"]!;
                self.handleSocketResponse(row)
            }
        }
        
        socket.connect()
    }
   
    
    func updateState(_ occupied:Bool)
    {
        if(occupied == true)
        {
            print("occupied");
            state🚽🔒   = "🔒"
        }else{
            print("free");
            state🚽🔒   = "🔓"
        }
        
        self.lastUpdateDate = Date()
        isOccupied = occupied
        NotificationCenter.default.post(name: Notification.Name(rawValue: "locationStateUpdate"), object: nil)
    }
    
    func handleSocketResponse(_ row:Dictionary<String, AnyObject>)
    {
        print("location updated by socket")
        print(row)
        let occupied = (row["occupied"] as! Bool == true);
        self.handleUpdate(occupied, data: row)
    }
    
    func handleRestResponse(_ result:JSON)
    {
        print("location updated by Rest API")
        
        if(result != JSON.null)
        {
            let row = result["data"].dictionaryObject! as Dictionary<String, AnyObject>
            self.handleUpdate(row["occupied"] as! Bool, data: row)
        }
    }
    
    func handleVisitRestResponse(_ result:JSON)
    {
        print("visit updated by Rest API")
        
        if(result == JSON.null)
        {
            return
        }
        
        let row:JSON = result["data"][result["data"].count-1]

        self.lastVisit = LocationVisitModel(
            id:         row["id"].int!,
            end🕛:      row["end_time"].string!,
            start🕛:    row["start_time"].string!,
            locationId: row["location_id"].int!,
            duration:   row["duration"].double!
        )
        NotificationCenter.default.post(name: Notification.Name(rawValue: "locationStateUpdate"), object: nil)
    }
    
    func handleUpdate(_ occupied:Bool, data:Dictionary<String, AnyObject>){
        
        if(occupied == false)
        {
        self.getLastVisitFromRest(locationId)
        }
        
        self.updateState(occupied)

    }
    
    deinit{
        self.closeConnection();
    }
    

 
    func closeConnection() {
        socket.disconnect()
    }
  
    func getLocationFromRest(_ id:Int)
    {
        RestApiManager.sharedInstance.getLocationData(id, onCompletion: self.handleRestResponse);
    }
    
    func getLastVisitFromRest(_ id:Int)
    {
        RestApiManager.sharedInstance.getLocationVisitData(id, onCompletion: self.handleVisitRestResponse);
    }
}
