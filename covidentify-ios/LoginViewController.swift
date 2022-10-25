//
//  LoginViewController.swift
//  covidentify-ios
//
//  Created by James Wang on 10/13/22.
//

import UIKit
import Dispatch

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        errorMessageField.alpha = 0
        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var errorMessageField: UILabel!
    
    @IBOutlet weak var tappedLoginActivity: UIActivityIndicatorView!
    
    @IBAction func pressedLogin(_ sender: Any) {
        self.tappedLoginActivity.startAnimating()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){
            self.processLogin()
        }
    }
    
    func processLogin(){
        self.tappedLoginActivity.stopAnimating()
        let userID = self.emailField.text
        let password = self.passwordField.text
        let validateMessage = self.validateLoginCredential(userID: userID!, password: password!)
        if validateMessage=="success"{
            self.performSegue(withIdentifier: "loginSuccess", sender: nil)
        }else{
            self.errorMessageField.text = validateMessage
            self.errorMessageField.alpha = 1
        }
    }
    
    func validateLoginCredential(userID: String, password: String)-> String{
        // check if any field is missing
        if userID.isEmpty || password.isEmpty{
            return "missing email or password"
        }
        // check if the ID and password are valid
        else if userID == "pc177@duke.edu" && password == "password"{
            return "success"}
        // otherwise, return fail message
        return "login failed"
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
