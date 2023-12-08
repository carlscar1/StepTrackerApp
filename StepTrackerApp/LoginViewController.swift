//
//  ViewController.swift
//  StepTrackerApp
//
//  Created by Caroline Carlson on 11/28/23.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // dismiss keyboard when tapping outside of text fields
        let detectTouch = UITapGestureRecognizer(target: self, action:
        #selector(self.dismissKeyboard))
        self.view.addGestureRecognizer(detectTouch)
                                          
        // make this controller the delegate of the text fields.
        self.emailField.delegate = self
        self.passwordField.delegate = self
    }
    
    @objc func dismissKeyboard() {
      self.view.endEditing(true)
    }

        func validateFields() -> Bool {
        let pwOk = self.isValidPassword(password: self.passwordField.text)
        if !pwOk {
            print(NSLocalizedString("Invalid password",comment: ""))
        }
        
        let emailOk = self.isValidEmail(emailStr: self.emailField.text)
        if !emailOk {
            print(NSLocalizedString("Invalid email address", comment: ""))
        }
        
        return emailOk && pwOk
    }

    
    @IBAction func signInButtonPressed(_ sender: UIButton) {

        let email = self.emailField.text!
        let password = self.passwordField.text!

                Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                    if let error = error as NSError? {
                        switch error.code {
                        case AuthErrorCode.userNotFound.rawValue:
                            // User does not exist, show shake animation
                            self.showShakeAnimation(on: [self.emailField, self.passwordField])
                            print("User does not exist with the provided email")
                            // You may choose to show an alert or perform other actions here
                        case AuthErrorCode.wrongPassword.rawValue:
                            // Wrong password, handle accordingly
                            print("Wrong password. Please check your password and try again.")
                            // You may choose to show an alert or perform other actions here
                        default:
                            // Handle other errors, e.g., show an error message to the user
                            self.showShakeAnimation(on: [self.emailField, self.passwordField])
                            print("Sign-in failed with error: \(error.localizedDescription)")
                        }
                    } else {
                        // User signed in successfully
                        self.performSegue(withIdentifier: "segueToMain", sender: self)
                        print("User signed in with UID: \(authResult?.user.uid ?? "")")
                        // Handle success, e.g., navigate to the next screen
                    }
                }
    }
    
    private func showShakeAnimation(on views: [UIView]) {
            let shakeAnimation = CABasicAnimation(keyPath: "position")
            shakeAnimation.duration = 0.07
            shakeAnimation.repeatCount = 3
            shakeAnimation.autoreverses = true

            for view in views {
                let fromPoint = CGPoint(x: view.center.x - 10, y: view.center.y)
                let toPoint = CGPoint(x: view.center.x + 10, y: view.center.y)
                shakeAnimation.fromValue = NSValue(cgPoint: fromPoint)
                shakeAnimation.toValue = NSValue(cgPoint: toPoint)
                view.layer.add(shakeAnimation, forKey: "position")
            }
        }
    
    
    @IBAction func logout(segue : UIStoryboardSegue) {
        print("Logged out")
        self.passwordField.text = ""
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToMain" {
            if let destVC = segue.destination.children[0] as? MainViewController {
                destVC.userEmail = self.emailField.text
            }
        }
    }
    
}

extension LoginViewController : UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == self.emailField {
      self.passwordField.becomeFirstResponder()
    } else {
      if self.validateFields() {
        print(NSLocalizedString("Congratulations!  You entered correct values.", comment: ""))
      }
    }
    return true
  }
}
