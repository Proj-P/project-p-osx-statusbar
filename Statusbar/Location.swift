//
//  Location.swift
//  Statusbar
//
//  Created by Erik de Groot on 26/09/2019.
//  Copyright © 2019 Tjuna. All rights reserved.
//

import Foundation

struct Location: Codable {
    let changed_at: String?
    let id: Int
    let name: String
    let occupied: Bool

    init (_ data: [String:Any]) {
        
        self.id = data["id"] as! Int
        self.changed_at = data["changed_at"] as? String
        self.name = data["name"] as! String
        self.occupied = data["occupied"] as! Bool
    }
}
