//
//  MainViewController.swift
//  StepTrackerApp
//
//  Created by Caroline Carlson on 12/3/23.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var loginLabel: UILabel!
    var userEmail : String?
    
    override func viewDidLoad() {
            super.viewDidLoad()
            if let email = self.userEmail {
                self.loginLabel.text = email
            }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
