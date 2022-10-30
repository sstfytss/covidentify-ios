//
//  SignupViewController.swift
//  covidentify-ios
//
//  Created by James Wang on 10/13/22.
//

import UIKit

class SignupViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        errorMessageField.alpha = 0
        activityMonitor.stopAnimating()
        // Do any additional setup after loading the view.
    }
    

    @IBOutlet weak var activityMonitor: UIActivityIndicatorView!
    @IBOutlet weak var errorMessageField: UILabel!
    @IBOutlet weak var nameField: UITextField!
    
    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var passwordCheckField: UITextField!
    
    @IBAction func pressedSignUp(_ sender: Any) {
        activityMonitor.startAnimating()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){
            self.processSignUp()
        }
    }
    
    func processSignUp(){
        self.activityMonitor.stopAnimating()
        let userName = nameField.text
        let userEmail = emailField.text
        let userPassword = passwordField.text
        let userPasswordCheck = passwordCheckField.text
        let validateMessage = self.validateSignUp(userName: userName!, userEmail: userEmail!, userPassword: userPassword!, userPasswordCheck: userPasswordCheck!)
        if validateMessage == "success"{
            self.performSegue(withIdentifier: "signupSuccess", sender: nil)
        } else {
            self.errorMessageField.text = validateMessage
            self.errorMessageField.alpha = 1
        }
    }
    
    func validateSignUp(userName: String, userEmail: String, userPassword: String, userPasswordCheck: String)->String{
        // check if any field is missing
        if userName.isEmpty || userEmail.isEmpty || userPassword.isEmpty || userPasswordCheck.isEmpty {
            return "missing info"
        }
        // check if the passwords match
        else if userPassword != userPasswordCheck{
            return "Passwords don't match"
        }
        // check if the email already exists
        else if userEmail == "existing@duke.edu"{
            return "Existing ID. Please log in"
        }
        // otherwise, return fail message
        return "success"
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
