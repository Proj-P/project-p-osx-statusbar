//
//  StincrementCalculator.swift
//  Statusbar
//
//  Created by Erik de Groot on 22/07/16.
//  Copyright © 2016 Tjuna. All rights reserved.
//

import Cocoa

class StincrementCalculator: NSObject {

    func  calculate(_ duration🕛:Int, passed🕛:Int) -> String {

        let visit🕛:Int = duration🕛 + passed🕛
        let maxStincrementVisit = 10
        let minStincrementVisit = 2

        var smellText           = "✨"
        let stinkBaseText       = "🙊"
        let stincrementerText   = "💩"
        let stincrementerTimeAmount: Int = 2

        if(visit🕛 > maxStincrementVisit) {
            smellText = "☠☠☠"
        } else if(visit🕛 > minStincrementVisit) {

            smellText = stinkBaseText
            for i in 0..<visit🕛 {
                if(i % stincrementerTimeAmount == 1) {
                    smellText+=stincrementerText
                }
            }
        }

        return smellText
    }

}
