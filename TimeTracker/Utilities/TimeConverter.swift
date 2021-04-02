//
//  TimeConverter.swift
//  TimeTracker
//
//  Created by Tony Chi on 18/2/21.
//

import Foundation

struct TimeConverter {
    
    func convertTime(time: Int) -> (Int, Int) {
        var hours: Int
        var minutes: Int
        
        hours = Int(time/60)
        minutes = Int(time) - 60 * hours
        
        
        return (hours, minutes)
    }
}
