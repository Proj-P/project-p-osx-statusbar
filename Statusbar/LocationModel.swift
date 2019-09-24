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


class ApiLocation {
    var average_duration: Int
    let changed_at: Date?
    let id: Int
    let name: String
    let occupied: Bool
    
    required init ( data : [String:Any]) {
        
        self.id = data["id"] as! Int
        self.average_duration = data["average_duration"] as! Int
        self.changed_at = data["changed_at"] as? Date
        self.name = data["name"] as! String
        self.occupied = data["occupied"] as! Bool
    }
}



class LocationModel: NSObject {
    let apiURL: String      = Config.API_URL
    var state🚽🔒:String?
    var isOccupied: Bool?
    var name: String?
    var lastUpdateDate: Date?
    var locationId: Int
    var lastVisit: LocationVisitModel?

    let manager = SocketManager(socketURL: URL(string: Config.API_URL)!, config: [.log(true), .compress])

    var socket: SocketIOClient

    init(id: Int, name: String? = nil) {
        // perform some initialization here
        self.locationId = id
        self.name = name
        self.socket = self.manager.defaultSocket
        super.init()

        self.getLocationFromRest(id)
        self.getLastVisitFromRest(id)
        self.socketConnect()
    }

    func socketConnect() {
        socket.on("connect") {_, _ in
            print("socket connected")
        }

        socket.on("location") {response, _ in
            let json = JSON(response)
            guard let data = json.dictionaryObject else{
                print("invalid response from socket")
                return
            }
            
            self.handleSocketResponse(data)
        }
        
        socket.connect()
    }

    func updateState(_ occupied: Bool) {
        if(occupied == true) {
            print("occupied")
            state🚽🔒   = "🔒"
        } else {
            print("free")
            state🚽🔒   = "🔓"
        }

        self.lastUpdateDate = Date()
        isOccupied = occupied
        NotificationCenter.default.post(name: Notification.Name(rawValue: "locationStateUpdate"), object: nil)
    }

    func handleSocketResponse(_ row: [String:Any]) {
        print("location updated by socket")

        let location = ApiLocation(data: row);
        self.handleUpdate(location.occupied, data: location)
    }

    func handleRestResponse(_ result: JSON) -> Array<LocationModel> {
        var collection = [] as Array<LocationModel>;
        guard let response = result.array as Array<JSON>? else {
            return collection;
        }

        
        for row in response{
            collection.append(LocationModel(
                id: row["id"].int!,
                name: row["name"].string!
            ))
        }
        return collection;
    }

    func handleSingleRestResponse(_ result: JSON) {
        print("location updated by Rest API")
        
        if(result == JSON.null || result.rawString() == "") {
            print("empty response")
            return
        }

        if let error = result["error"].string {
            print("error recieved")
            print(error)
            return
        }

        if let error = result["error"].dictionary {
            //Now you got your value
            print(error)
            return
        }

        guard let row = result.dictionaryObject else {
            return
        }

        let location = ApiLocation(data: row as [String : Any])

        self.handleUpdate(location.occupied, data: location)
    }

    func handleVisitRestResponse(_ result: JSON) {
        print("visit updated by Rest API")

        if(result == JSON.null) {
            return
        }

        let row: JSON = result[result.count-1]

        self.lastVisit = LocationVisitModel(
            id: row["id"].int!,
            end🕛: row["end_time"].string!,
            start🕛: row["start_time"].string!,
            locationId: row["location_id"].int!,
            duration: row["duration"].double!
        )
        NotificationCenter.default.post(name: Notification.Name(rawValue: "locationStateUpdate"), object: nil)
    }

    func handleUpdate(_ isOccupied: Bool, data: ApiLocation) {

        if(isOccupied == false) {
            self.getLastVisitFromRest(locationId)
        }

        self.updateState(isOccupied)

    }

    deinit {
        self.closeConnection()
    }

    func closeConnection() {
        socket.disconnect()
    }

    func getLocationFromRest(_ id: Int) {
        RestApiManager.sharedInstance.getLocationData(id, onCompletion: self.handleSingleRestResponse)
    }

    func getLastVisitFromRest(_ id: Int) {
        RestApiManager.sharedInstance.getLocationVisitData(id, onCompletion: self.handleVisitRestResponse)
    }
}
