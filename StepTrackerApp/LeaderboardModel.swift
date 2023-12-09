//
//  LeaderboardModel.swift
//  StepTrackerApp
//
//  Created by Caroline Carlson on 12/9/23.
//

import Foundation
class LeaderboardModel {
    fileprivate var items : [LeaderboardData] = [LeaderboardData]()
    
    init() {
        createLeaderboardData()
    }
    
    func getLeaderboardData() -> [LeaderboardData]
    {
        return self.items
    }
    
    fileprivate func createLeaderboardData()
    {
        items.append(LeaderboardData(name: "PersonOne", stepsWalked: 122))
        items.append(LeaderboardData(name: "PersonTwo", stepsWalked: 100))
        items.append(LeaderboardData(name: "PersonThree", stepsWalked: 50))
        items.append(LeaderboardData(name: "PersonFour", stepsWalked: 12))
    }
}
