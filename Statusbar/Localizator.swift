//
//  Localizator.swift
//  Statusbar
//
//  Created by Erik de Groot on 13/03/2017.
//  Copyright © 2017 Tjuna. All rights reserved.
//

import Foundation

private class localizer {
    
    static let sharedInstance = localizer() // singleton

    
    func localize(string: String) -> String {
        
        return NSLocalizedString(string, comment: "")
    }
}

extension String {
    var localized: String {
        return localizer.sharedInstance.localize(string: self)
    }
}
