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

    var visits: [LocationVisit] = []
    var lastVisit: LocationVisit? {
        get {
            guard self.visits.count > 0 else {
                return nil
            }
            print("getting last visit")
            return self.visits.last
        }
        set {
            self.visits.append(newValue!)
            print("setting last visit")
        }
    }

    init(id: Int, name: String? = nil) {
        // perform some initialization here
        self.locationId = id
        self.name = name
        super.init()
        print("init location")
        self.getLocationFromRest(id)
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
            let location = Location(data: json as! [String: Any])
            self.handleUpdate(location)
        } catch _ {
            print("socket returned invalid JSON")
        }
    }

    func handleLocationRestResponse(_ result: JSON) {
        print("location updated by Rest API")

        guard let data = result.dictionaryObject else {
            print("parsing error")
            return
        }

        let location = Location(data: data as [String: Any])

        self.handleUpdate(location)
    }

    func handleUpdate(_ data: Location) {

        if(data.occupied == false) {
            self.getLastVisitFromRest(locationId)
        }

        self.updateState(data.occupied)
    }

    func handleVisitRestResponse(_ result: JSON) {
        print("handling Visit response")
        guard let array = result.array else {
            return
        }

        self.updateVisits(array)

        NotificationCenter.default.post(name: Notification.Name(rawValue: "lastVisitUpdate"), object: nil)
        print("last ended visit: \(String(describing: self.visits.last?.end🕛))")
    }

    func updateVisits(_ array: [JSON]) {
        self.visits.removeAll()

       for row in array {
           guard let data: [String: Any] = row.dictionaryObject else {
               print("parsing error")
               return
           }

           let visit = LocationVisit(data: data)

           guard visit.locationId == Config.LOCATION_ID else {
               continue
           }

           self.visits.append(visit)
       }
    }

    func getLocationFromRest(_ id: Int) {
        let path = "/locations/\(id)"
        RestApiManager.sharedInstance.getData(path, onCompletion: self.handleLocationRestResponse)
    }

    func getLastVisitFromRest(_ id: Int) {
        let path = "/visits/recent"
        RestApiManager.sharedInstance.getData(path, onCompletion: self.handleVisitRestResponse)
    }
}
