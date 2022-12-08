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
        hideKeyboardWhenTappedAround()
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

        if userID == nil || password == nil{
            self.errorMessageField.text = "missing email or password"
            self.errorMessageField.alpha = 1
        }else{
            get(email: userID!, password: password!) { (ret) in
                // Handle logic after return here
                
                if(ret == true){
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "loginSuccess", sender: nil)
                    }
                }else{
                    DispatchQueue.main.async {
                        self.errorMessageField.text = "login failed"
                        self.errorMessageField.alpha = 1
                    }
                }
            }
        }

    }
    
    func get(email: String, password: String, completionBlock: @escaping (Bool) -> Void){
        let restEndPoint: String = "http://test-ios.azurewebsites.net/api/login/"
       
      guard let url = URL(string: restEndPoint) else{
        print("error creating url")
        return
      }
       
      var urlRequest = URLRequest(url: url)
      urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
       
      let config = URLSessionConfiguration.default
      let session = URLSession(configuration: config)
        
      let task = session.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
          let loginInfo: [LoginInfo] = try! JSONDecoder().decode([LoginInfo].self, from: data!)
      
          for userData in loginInfo{
              print(userData)
              print(userData.email)
              print(userData.password)
              if (userData.email == email && userData.password == password){
                  completionBlock(true);
              }else{
                  completionBlock(false);
              }
          }
      })
       
      task.resume()
    }

}

extension LoginViewController: UITextFieldDelegate {
    
    // Return button tapped
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Around tapped
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
}
