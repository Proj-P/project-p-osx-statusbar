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
        
        let max = 10
        let min = 2
        let divident: Int = 2

        if(elapsed < min)
        {
            return "✨"
        }
        
        if(elapsed > max) {
            return "☠☠☠"
        }
    
        var smellText = "🙊"
        
        for i in 0..<elapsed {
            if(i % divident == 1) {
                smellText += "💩"
            }
        }

        return smellText
    }

}
