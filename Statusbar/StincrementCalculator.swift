//
//  StincrementCalculator.swift
//  Statusbar
//
//  Created by Erik de Groot on 22/07/16.
//  Copyright © 2016 Tjuna. All rights reserved.
//

import Cocoa

class StincrementCalculator: NSObject {
    
    func  calculate(visit🕛:Int) -> String{
        
        let maxStincrementVisit = 10
        let minStincrementVisit = 2
        
        var smellText           = "✨"
        let stinkBaseText       = "🙊"
        let stincrementerText   = "💩"
        
        
        
        if(visit🕛 > maxStincrementVisit)
        {
            smellText = "☠☠☠"
        }else if(visit🕛 > minStincrementVisit)
        {
            
            smellText = stinkBaseText
            for _ in 0..<visit🕛
            {
                smellText+=stincrementerText
            }
        }
        
        
        return smellText
    }
    
}
