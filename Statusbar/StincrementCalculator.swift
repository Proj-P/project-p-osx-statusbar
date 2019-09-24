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

        let elapsed = duration🕛 - timeAgo🕛
        
        let maxStincrementVisit = 10
        let minStincrementVisit = 2
        let stincrementerTimeAmount: Int = 2

        if( duration🕛 < minStincrementVisit  || elapsed < 0)
        {
            return "✨"
        }
        
        if(duration🕛 > maxStincrementVisit) {
            return "☠☠☠"
        }
    
        var smellText = "🙊"
        
        for i in 0..<duration🕛 {
            if(i % stincrementerTimeAmount == 1) {
                smellText += "💩"
            }
        }

        return smellText
    }

}
