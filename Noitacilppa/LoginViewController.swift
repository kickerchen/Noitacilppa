//
//  LoginViewController.swift
//  Noitacilppa
//
//  Created by CHENCHIAN on 8/5/15.
//  Copyright (c) 2015 KICKERCHEN. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController {

    @IBOutlet weak var userTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    let loginSuccessfulSegue = "LoginSuccesful"
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let user = PFUser.currentUser() {
            if user.isAuthenticated() {
                dispatch_async(dispatch_get_main_queue()){                
                    self.performSegueWithIdentifier(self.loginSuccessfulSegue, sender: nil)
                }
                
            }
        }
    }
    
    // MARK: - Actions
    @IBAction func logInButtonPressed(sender: AnyObject) {
        
        PFUser.logInWithUsernameInBackground(self.userTextField.text, password: self.passwordTextField.text) { ( user, error ) in
            
            if user != nil {
                
                self.performSegueWithIdentifier(self.loginSuccessfulSegue, sender: nil)
                
            } else if let error = error {
                
                self.showErrorView(error)
                
            }
        }
    }}
