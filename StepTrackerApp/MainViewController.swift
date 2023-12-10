//
//  MainViewController.swift
//  StepTrackerApp
//
//  Created by Caroline Carlson on 12/3/23.
//

import UIKit
import SwiftUI
import HealthKit
import FirebaseFirestore

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private let healthStore = HKHealthStore()
    
    fileprivate var ref: CollectionReference?
    fileprivate var db: Firestore!
    fileprivate var listener: ListenerRegistration?
    var uniqueUserIDs: Set<String> = Set()
    
    @IBOutlet weak var stepsLabel: UILabel!
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var stepsProgress: UIProgressView!
    @IBOutlet weak var percentLabel: UILabel!
    @IBOutlet weak var updateStepsButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func setGoalButtonPressed(_ sender: Any) {
            showStepGoalAlert()
        }

    
    var userEmail : String?
    var leaderboards : [LeaderboardData]?
    var numSteps: Int?
    var stepGoal: Int?
    
    var tableViewData: [(sectionHeader: String, leaderboards: [LeaderboardData])]? {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
        ref = db.collection("leaderboard")
        
        if let email = self.userEmail {
                self.loginLabel.text = ("Welcome, " + email + "!")
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
    
    override func viewWillAppear(_ animated: Bool) {
        registerForFireBaseUpdates()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.listener?.remove()
    }
    
    private func showStepGoalAlert() {
        let alertController = UIAlertController(title: "Set Step Goal", message: "Enter your step goal:", preferredStyle: .alert)

        alertController.addTextField { textField in
            textField.placeholder = "Enter goal"
            textField.keyboardType = .numberPad
        }

        let setAction = UIAlertAction(title: "Set Goal", style: .default) { [weak self] _ in
            if let textField = alertController.textFields?.first,
               let goalText = textField.text,
               let goal = Int(goalText) {
                self?.handleStepGoalSet(goal)
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alertController.addAction(setAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }
    
    private func handleStepGoalSet(_ goal: Int) {
            // Handle the step goal set by the user
            print("Step goal set: \(goal)")

            // Save the goal to the variable
            self.stepGoal = goal

            // Update your UI or perform any other necessary actions with the step goal
            if let goal = self.stepGoal {
                print("Current step goal: \(goal)")

                
                // Update the UI with the new step goal
                let progressPercent: Float = Float(self.numSteps!) / Float(goal)
                self.percentLabel.text = "\(self.numSteps!)/\(goal) steps = \(Float(progressPercent * 100))% of goal"
                
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

        // Get the current step count before querying for new data
        if let currentStepCount = self.numSteps {
            mSample = Double(currentStepCount)
        }

        let type = HKQuantityType.quantityType(forIdentifier: .stepCount)!

        let sampleQuery = HKSampleQuery(
            sampleType: type,
            predicate: getTodayPredicate(),
            limit: HKObjectQueryNoLimit,
            sortDescriptors: nil,
            resultsHandler: { [weak self] (query, results, error) in

                guard let self = self else { return }

                guard let samples = results as? [HKQuantitySample] else {
                    print(error!)
                    return
                }

                for sample in samples {
                    mSample += sample.quantity.doubleValue(for: HKUnit(from: "count"))
                }

                DispatchQueue.main.async {
                    print("Step count is:", Int(mSample))

                    // Use the user-entered step goal if available, otherwise default to 10,000
                    let userStepGoal = self.stepGoal ?? 10000

                    // Display the current step count or 0 if no steps have been recorded yet
                    let currentStepCountText = (mSample > 0) ? "\(Int(mSample))" : "0"

                    self.stepsLabel.text = "You have walked \(currentStepCountText) steps today!"
                    
                    // Update the progress view
                    let progressPercent: Float = Float(mSample) / Float(userStepGoal)
                    self.percentLabel.text = "\(currentStepCountText)/\(userStepGoal) steps = \(Float(progressPercent * 100))% of goal"
                    self.stepsProgress.setProgress(progressPercent, animated: false)

                    self.numSteps = Int(mSample)

                    // Update the step count labels/info
                    if let r = self.ref {
                        let leader = LeaderboardData(name: self.userEmail, stepsWalked: self.numSteps)
                        r.addDocument(data: self.toDictionary(vals: leader))
                    }
                }
            }
        )

        self.healthStore.execute(sampleQuery)
    }






    func toDictionary(vals: LeaderboardData) -> [String: Any] {
        return [
            "name": vals.name as Any,
            "stepsWalked": vals.stepsWalked as Any
        ]
    }



    // Helper method to create a predicate for today
    private func getTodayPredicate() -> NSPredicate {
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: now)!
        return HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
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
            return self.tableViewData?[section].leaderboards.count ?? 0
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

            if let leader = self.tableViewData?[indexPath.section].leaderboards[indexPath.row] {
                cell.textLabel?.text = leader.name
                cell.detailTextLabel?.text = "\(leader.stepsWalked ?? 0) steps"
            }
            return cell
        }

        func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            return self.tableViewData?[section].sectionHeader
        }
    
    fileprivate func registerForFireBaseUpdates() {
        self.listener = self.ref?.order(by: "stepsWalked", descending: true).addSnapshotListener({ [weak self] (snapshot, error) in
            guard let self = self else { return }

            guard let documents = snapshot?.documents else {
                print("Error fetching documents: \(error!)")
                return
            }

            var newLeaderboards = [LeaderboardData]()
            var processedUserIDs = Set<String>()

            for document in documents {
                let data = document.data()
                let name = data["name"] as? String
                let stepsWalked = data["stepsWalked"] as? Int

                // Check if the user ID has been processed
                if let userID = name, !processedUserIDs.contains(userID) {
                    // Add the user ID to the set to mark it as processed
                    processedUserIDs.insert(userID)

                    // Add the leaderboard entry to the newLeaderboards array
                    newLeaderboards.append(LeaderboardData(name: userID, stepsWalked: stepsWalked))
                }

                // Check if we have the top 5 entries
                if newLeaderboards.count == 5 {
                    break
                }
            }

            self.leaderboards = newLeaderboards
            self.tableViewData = [("Top 5 Daily Steps This Week: ", self.leaderboards ?? [])]
            self.tableView.reloadData()
        })
    }


    
    
    
//    func toDictionary(vals: LeaderboardData)->[String:Any] {
//        return [
//            "name": NSString(string: (vals.name!)),
//            "stepsWalked": NSNumber(value: vals.stepsWalked!)
//        ]
//    }

    
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


