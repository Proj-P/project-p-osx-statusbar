//
//  locationModel.swift
//  Statusbar
//
//  Created by Erik de Groot on 22/07/16.
//  Copyright © 2016 Tjuna. All rights reserved.
//

import Cocoa

import SwiftyJSON

class LocationModel: NSObject {
    let apiURL: String      = Config.API_URL
    var state🚽🔒:String?
    var isOccupied: Bool?
    var name: String?
    var lastUpdateDate: Date?
    var locationId: Int
    var lastVisit: LocationVisitModel?

    init(id: Int, name: String? = nil) {
        // perform some initialization here
        self.locationId = id
        self.name = name
        super.init()

        self.getLocationFromRest(id)
        self.getLastVisitFromRest(id)
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
    
    func handleSocketResponse(_ rawJson: String) {
        let decoder = JSONDecoder()
        do {
            let row = try decoder.decode(Location.self, from: rawJson.data(using: .utf8)!)
            
            self.handleUpdate(data: row);
        }catch let parsingError {
            print(parsingError)
        }
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

        let location = Location(row as [String : Any])

        self.handleUpdate(data: location)
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
            duration: Int(floor(row["duration"].double!))
        )
        NotificationCenter.default.post(name: Notification.Name(rawValue: "locationStateUpdate"), object: nil)
    }

    func handleUpdate(data: Location) {

        if(data.occupied == false) {
            self.getLastVisitFromRest(locationId)
        }

        self.updateState(data.occupied)

    }

    func getLocationFromRest(_ id: Int) {
        RestApiManager.sharedInstance.getLocationData(id, onCompletion: self.handleSingleRestResponse)
    }

    func getLastVisitFromRest(_ id: Int) {
        RestApiManager.sharedInstance.getLocationVisitData(id, onCompletion: self.handleVisitRestResponse)
    }
}
