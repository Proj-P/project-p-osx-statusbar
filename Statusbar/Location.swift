//
//  Location.swift
//  Statusbar
//
//  Created by Erik de Groot on 26/09/2019.
//  Copyright © 2019 Tjuna. All rights reserved.
//

import Foundation

class Location: Codable {
    let changed_at: Date?
    let id: Int
    let name: String
    let occupied: Bool
    let average_duration: Int

    init (id: Int,
          changedAt: String,
          averageDuration: Int,
          name: String,
          occupied: Bool
        ) {

        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"

        self.id = id

        self.changed_at = formatter.date(from: changedAt)
        self.average_duration = averageDuration

        self.name = name
        self.occupied = occupied
    }

    init (data: [String: Any]) {

        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"

        self.id = data["id"] as! Int
        let changedAt = data["changed_at"] as! String

        self.changed_at = formatter.date(from: changedAt)
        self.average_duration = data["average_duration"] as! Int

        self.name = data["name"] as! String
        self.occupied = data["occupied"] as! Bool
    }
}
