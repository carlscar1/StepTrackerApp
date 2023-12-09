//
//  LeaderboardData.swift
//  StepTrackerApp
//
//  Created by Caroline Carlson on 12/9/23.
//

import Foundation

struct LeaderboardData {
    var key : String?
    var name : String?
    var stepsWalked : Int?
    
    init(key: String?, name: String?, stepsWalked: Int?)
    {
        self.key = key
        self.name = name
        self.stepsWalked = stepsWalked
    }
    
    init(name: String?, stepsWalked: Int?)
    {
        self.init(key: nil, name: name, stepsWalked: stepsWalked)
    }
    
    init() {
        self.init(key: nil, name: nil, stepsWalked: nil)
    }
    
}
