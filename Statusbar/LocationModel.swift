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

        socket.on("location") {result, _ in
            if let data = result as? Array<Dictionary<String, Dictionary<String, AnyObject>>> {
                guard let row = data[0]["data"] else {
                    print("invalid response")
                    return
                }
                self.handleSocketResponse(row)
            }
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

    func handleSocketResponse(_ row: Dictionary<String, AnyObject>) {
        print("location updated by socket")

        let occupied = (row["occupied"] as? Bool == true)

        self.handleUpdate(occupied, data: row)
    }

    func handleRestResponse(_ result: JSON) -> Array<LocationModel> {
        var collection = [] as Array<LocationModel>;
        guard let response = result["data"].array as Array<JSON>? else {
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
        print(result["data"] )
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

        guard let row = result["data"].dictionary else {
            return
        }

        print("hoogashaka")
        let object = row as Dictionary<String, AnyObject>
        guard let status = row["occupied"]?.bool else {
            print("invalid response")
            return
        }

        self.handleUpdate(status, data: object)
        return

    }

    func handleVisitRestResponse(_ result: JSON) {
        print("visit updated by Rest API")

        if(result == JSON.null) {
            return
        }

        let row: JSON = result["data"][result["data"].count-1]

        self.lastVisit = LocationVisitModel(
            id: row["id"].int!,
            end🕛: row["end_time"].string!,
            start🕛: row["start_time"].string!,
            locationId: row["location_id"].int!,
            duration: row["duration"].double!
        )
        NotificationCenter.default.post(name: Notification.Name(rawValue: "locationStateUpdate"), object: nil)
    }

    func handleUpdate(_ occupied: Bool, data: Dictionary<String, AnyObject>) {

        if(occupied == false) {
        self.getLastVisitFromRest(locationId)
        }

        self.updateState(occupied)

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
