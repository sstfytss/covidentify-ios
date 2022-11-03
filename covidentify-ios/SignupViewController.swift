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
            self.post_signup_info(userName: userName!, userEmail: userEmail!, userPassword: userPassword!)
            self.performSegue(withIdentifier: "signupSuccess", sender: nil)
            
        } else {
            self.errorMessageField.text = validateMessage
            self.errorMessageField.alpha = 1
        }
    }
    
    func validateSignUp(userName: String, userEmail: String, userPassword: String, userPasswordCheck: String)->String{
        // check if any field is missing
        get_login_db()
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
    
    func post_signup_info(userName: String, userEmail: String, userPassword: String){
            let nameComponents = userName.components(separatedBy: " ")
            let firstName = nameComponents[0]
            let lastName = nameComponents[1]
            guard let url = URL(string: "http://test-ios.azurewebsites.net/api/login"),
                  let payload = "{\"id\":0,\"device_id\":0,\"first_name\":\"\(firstName)\",\"last_name\":\"\(lastName)\",\"email\":\"\(userEmail)\",\"password\":\"\(userPassword)\"}".data(using: .utf8)
            else {
                return
            }
            print(payload)
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("text/plain", forHTTPHeaderField: "accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = payload
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                print("request, \(response)")
                guard error == nil else { print(error!.localizedDescription); return }
                guard let data = data else { print("Empty data"); return }

                if let str = String(data: data, encoding: .utf8) {
                    print(str)
                }
            }.resume()
        }
    
    func get_login_db(){
        let restEndPoint: String = "http://test-ios.azurewebsites.net/api/login"
            
           guard let url = URL(string: restEndPoint) else{
             print("error creating url")
             return
           }
            
           var urlRequest = URLRequest(url: url)
           urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
           let config = URLSessionConfiguration.default
           let session = URLSession(configuration: config)
            
           let task = session.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
             print("error")
             print(error)
             print("response")
             print(response)
             print("data")
             print(String(data: data!, encoding: .utf8))
           })
           task.resume()
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
