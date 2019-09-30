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
    let apiURL: String = Config.API_URL
    var state🚽🔒:String?
    var isOccupied: Bool?
    var name: String?
    var lastUpdateDate: Date?
    var locationId: Int
    var lastVisit: LocationVisit?

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
        do {
            let json = try JSONSerialization.jsonObject(with: rawJson.data(using: .utf8)!, options: [])
            let location = Location(data: json as! [String: Any]);
            self.handleUpdate(location);
        }catch _ {
            print("socket returned invalid JSON")
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

        guard let data = result.dictionaryObject else {
            print("parsing error")
            return
        }

        let location = Location(data: data as [String : Any])

        self.handleUpdate(location)
    }

    func handleVisitRestResponse(_ result: JSON) {
        print("visit updated by Rest API")
        let row = result[result.count-1];
        
        guard let data:[String: Any] = row.dictionaryObject else{
            print("parsing error")
            return
        }

        let visit = LocationVisit(data: data)
        
        self.lastVisit = visit;
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "lastVisitUpdate"), object: visit)
    }
    
    

    func handleUpdate(_ data: Location) {

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
