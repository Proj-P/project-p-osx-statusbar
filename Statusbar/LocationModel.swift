//
//  locationModel.swift
//  Statusbar
//
//  Created by Erik de Groot on 22/07/16.
//  Copyright © 2016 Tjuna. All rights reserved.
//

import SwiftyJSON
import Signals

class LocationModel: NSObject {

    let apiURL: String = Config.API_URL

    var isOccupied: Bool?
    var lastUpdateDate: Date?
    var locationId: Int

    let onLocation = Signal<(Location)>()
    let onVisits = Signal<([LocationVisit])>()
    let onOccupationChange = Signal<Bool>()

    var visits: [LocationVisit] = []
    var location: Location?

    var lastVisit: LocationVisit? {
        get {
            guard self.visits.count > 0 else {
                return nil
            }
            return self.visits.last
        }
    }

    init(id: Int) {
        self.locationId = id

        super.init()

        placeObservers()

        self.getLocationFromRest(id)
        self.getLastVisitsFromRest(id)

    }

    private func placeObservers() {
        self.onLocation.subscribe(with: self) { (location) in
            let occupied = location.occupied
            self.location = location

            self.lastUpdateDate = Date()
            self.isOccupied = occupied
            self.onOccupationChange.fire(occupied)
        }

        self.onVisits.subscribe(with: self) { visits in
            self.visits = visits
        }
    }

    func getVisitsToday() -> Int {
        let startDate = Date().midnight
        return self.visits.filter {$0.endTime > startDate}.count
    }

    func handleSocketResponse(_ rawJson: String) {
        do {
            let json = try JSONSerialization.jsonObject(with: rawJson.data(using: .utf8)!, options: [])
            let location = Location(data: json as! [String: Any])
            self.onLocation.fire((location))
            self.getLastVisitsFromRest(self.locationId)
        } catch _ {
            print("socket returned invalid JSON")
        }
    }

    func getLocationFromRest(_ id: Int) {
        let path = "/locations/\(id)"
        RestApiManager.sharedInstance.getData(path, onCompletion: self.handleLocationRestResponse)
    }

    func handleLocationRestResponse(_ result: JSON) {
        guard let data = result.dictionaryObject else {
            print("parsing error")
            return
        }

        let location = Location(data: data as [String: Any])
        self.onLocation.fire(location)
    }

    func getLastVisitsFromRest(_ id: Int) {
        let path = "/visits/recent"
        RestApiManager.sharedInstance.getData(path, onCompletion: self.handleVisitRestResponse)
    }

    func handleVisitRestResponse(_ result: JSON) {
        guard let array = result.array else {
            return
        }

        var visits: [LocationVisit] = []
        for row in array {
            guard let data: [String: Any] = row.dictionaryObject else {
                  print("parsing error")
                  continue
              }

            let visit = LocationVisit(data: data)
            guard visit.locationId == Config.LOCATION_ID else {
                continue
            }
            visits.append(visit)
        }

        onVisits.fire(visits)
    }
}
