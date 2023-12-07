//
//  MainViewController.swift
//  StepTrackerApp
//
//  Created by Caroline Carlson on 12/3/23.
//

import UIKit
import SwiftUI
import HealthKit

class MainViewController: UIViewController {

    private let healthStore = HKHealthStore()
    
    @IBOutlet weak var stepsLabel: UILabel!
    @IBOutlet weak var loginLabel: UILabel!
    
    var userEmail : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let email = self.userEmail {
                self.loginLabel.text = email
        }
        
        authorizeHealthKit() // This function provides to authorize the HealthKit.
        
        gettingStepCount() { stepCount in // This function provides to get the step count of the users.
                    DispatchQueue.main.async {
                        print("Step count is:", Int(stepCount)) // Get the step count.
                        self.stepsLabel.text = "You have walked \(Int(stepCount)) steps!"
                    }
        }
    }
    
        private func authorizeHealthKit() {
            let healthKitTypes: Set = [ HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)! ] // We want to access the step count.
            healthStore.requestAuthorization(toShare: nil, read: healthKitTypes) { (success, error) in  // We will check the authorization.
                if success {} // Authorization is successful.
            }
        }
    
        private func gettingStepCount(completion: @escaping (Double) -> Void) {
            var mSample = 0.0
            let type = HKQuantityType.quantityType(forIdentifier: .stepCount)!
            let sampleQuery = HKSampleQuery.init(sampleType: type,
                                                 predicate: get24hPredicate(),
                                                 limit: HKObjectQueryNoLimit,
                                                 sortDescriptors: nil,
                                                 resultsHandler: { (query, results, error) in
                
                guard let samples = results as? [HKQuantitySample] else {
                    print(error!)
                    return
                }
                for sample in samples {
                    mSample = mSample + sample.quantity.doubleValue(for: HKUnit(from: "count"))
                    //print("Step count : \(mSample)")
                    //self.stepsLabel.text = "You have walked \(Int(mSample)) steps!"
                }
                print("Step count : \(mSample)")
                //self.stepsLabel.text = "You have walked \(Int(mSample)) steps!"
                DispatchQueue.main.async {
                    print("Step count is:", Int(mSample)) // Get the step count.
                    self.stepsLabel.text = "You have walked \(Int(mSample)) steps!"
                }
            })
            //self.stepsLabel.text = "You have walked \(Int(mSample)) steps!"
            self.healthStore .execute(sampleQuery)

        }
    
    private func get24hPredicate() ->  NSPredicate{
            let today = Date()
            let startDate = Calendar.current.date(byAdding: .hour, value: -24, to: today)
            let predicate = HKQuery.predicateForSamples(withStart: startDate,end: today,options: [])
            return predicate
    }

    
}


