//
//  MainViewController.swift
//  StepTrackerApp
//
//  Created by Caroline Carlson on 12/3/23.
//

import UIKit
import SwiftUI
import HealthKit

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private let healthStore = HKHealthStore()
    
    @IBOutlet weak var stepsLabel: UILabel!
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var stepsProgress: UIProgressView!
    @IBOutlet weak var percentLabel: UILabel!
    @IBOutlet weak var updateStepsButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    var userEmail : String?
    var leaderboards : [LeaderboardData]?
    
    var tableViewData: [(sectionHeader: String, leaderboards: [LeaderboardData])]? {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
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
                        //these things do not update here...
                    }
        }
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        let model = LeaderboardModel()
        self.leaderboards = model.getLeaderboardData()
        //self.sortIntoSections(leaderboards: self.leaderboards!)
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
                    self.stepsLabel.text = "You have walked \(Int(mSample)) steps today!"
                    let progressPercent: Float = Float(mSample/10000)
                    self.percentLabel.text = "\(Int(mSample))/10,000 steps = \(Float(progressPercent*100))% of goal!"
                    self.stepsProgress.setProgress(progressPercent, animated: false)
                    // here is where to update the step count labels/info
                }
            })
            self.healthStore .execute(sampleQuery)

        }
    
    private func get24hPredicate() ->  NSPredicate{
            let today = Date()
            let startDate = Calendar.current.date(byAdding: .hour, value: -24, to: today)
            let predicate = HKQuery.predicateForSamples(withStart: startDate,end: today,options: [])
            return predicate
    }

    @IBAction func updateStepsButtonPressed(_ sender: Any) {
        gettingStepCount() { stepCount in // This function provides to get the step count of the users.
                    DispatchQueue.main.async {
                        print("Step count is:", Int(stepCount)) // Get the step count.
                        self.stepsLabel.text = "You have walked \(Int(stepCount)) steps!"
                        //these things do not update here...
                    }
        }
    }
    
    /*func sortIntoSections(leaderboards: [LeaderboardData]) {
            
            // We assume the model already provides them ascending date order.
            //var currentSection  = [Journal]()
            //var futureSection = [Journal]()
            //var pastSection = [Journal]()
        //var newlist = leaderboards
        
        //newlist = newlist.sort(by: <)!
        //self.leaderboards = newList
            //self.tableViewData = tmpData
    }*/
    
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        //return self.tableViewData?.count ?? 0
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return self.tableViewData?[section].leaderboards.count ?? 0
        if let leads = self.leaderboards {
            return leads.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "Cell", for:
            indexPath)
            
        if let leader = self.leaderboards?[indexPath.row] {
            cell.textLabel?.text = leader.name
            cell.detailTextLabel?.text = String(leader.stepsWalked!)
        }
        return cell
            
    }
    
    /*
    // MARK: - UITableViewDelegate
        func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
        {
            return self.tableViewData?[section].sectionHeader
        }
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
        {
            return 200.0
        }
        
        func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView,
                       forSection section: Int)
        {
            let header = view as! UITableViewHeaderFooterView
            header.textLabel?.textColor = UIColor.red
            header.contentView.backgroundColor = UIColor.white
        }
        
        func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView,
                       forSection section: Int)
        {
            let header = view as! UITableViewHeaderFooterView
            header.textLabel?.textColor = UIColor.red
            header.contentView.backgroundColor = UIColor.white
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            guard let leader = tableViewData?[indexPath.section].leaderboards[indexPath.row] else {
                return
            }
            print("Selected\(String(describing: leader.name))")
        }*/
    
}


