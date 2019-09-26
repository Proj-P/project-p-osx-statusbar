//
//  StincrementCalculator.swift
//  Statusbar
//
//  Created by Erik de Groot on 22/07/16.
//  Copyright © 2016 Tjuna. All rights reserved.
//

import Cocoa

class StincrementCalculator: NSObject {

    func  calculate(_ duration🕛:Int, timeAgo🕛:Int) -> String {

        let elapsed = Int(duration🕛 - timeAgo🕛)
        
        let maxStincrementVisit = 10
        let minStincrementVisit = 2
        let stincrementerTimeAmount: Int = 2

        if(elapsed < minStincrementVisit)
        {
            return "✨"
        }
        
        if(elapsed > maxStincrementVisit) {
            return "☠☠☠"
        }
    
        var smellText = "🙊"
        
        for i in 0..<elapsed {
            if(i % stincrementerTimeAmount == 1) {
                smellText += "💩"
            }
        }

        return smellText
    }

}
