//
//  SignUpViewController.swift
//  StepTrackerApp
//
//  Created by Caroline Carlson on 12/3/23.
//

import UIKit
import Firebase
import FirebaseCore
import FirebaseAuth

class SignUpViewController: UIViewController {
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var verifyPasswordField: UITextField!

    override func viewDidLoad() {
            super.viewDidLoad()
            self.emailField.delegate = self
            self.passwordField.delegate = self
            self.verifyPasswordField.delegate = self
        }
        
        func validateFields() -> Bool {
            
            let pwOk = self.isEmptyOrNil(password: self.passwordField.text)
            if !pwOk {
                print(NSLocalizedString("Invalid password", comment: ""))
            }
            
            let pwMatch = self.passwordField.text == self.verifyPasswordField.text
            if !pwMatch {
                print(NSLocalizedString("Passwords do not match.", comment: ""))
            }
            
            let emailOk = self.isValidEmail(emailStr: self.emailField.text)
            if !emailOk {
                print(NSLocalizedString("Invalid email address", comment: ""))
            }
            
            return emailOk && pwOk && pwMatch
        }
                
        @IBAction func signupButtonPressed(_ sender: UIButton) {
            if self.validateFields() {
                print(NSLocalizedString("Congratulations!  You entered correct values.", comment: ""))
                Auth.auth().createUser(withEmail: self.emailField.text!, password: self.passwordField.text!) { authResult, error in
                  // ...
                }
                self.performSegue(withIdentifier: "segueToMainFromSignUp", sender: self)
            }
        }

        // MARK: - Navigation
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "segueToMainFromSignUp" {
                if let destVC = segue.destination.children[0] as? MainViewController {
                    destVC.userEmail = self.emailField.text
                }
            }
        }
        
        @IBAction func cancelButtonPressed(_ sender: UIButton) {
           self.dismiss(animated: true, completion: nil)
        }

    }

    extension SignUpViewController : UITextFieldDelegate {
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            if textField == self.emailField {
                self.passwordField.becomeFirstResponder()
            } else if textField == self.passwordField {
                self.verifyPasswordField.becomeFirstResponder()
            } else {
                if self.validateFields() {
                    print(NSLocalizedString("Congratulations!  You entered correct values.", comment: ""))
                }
            }
            return true
        }
    }
