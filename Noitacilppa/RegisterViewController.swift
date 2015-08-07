//
//  RegisterViewController.swift
//  Noitacilppa
//
//  Created by CHENCHIAN on 8/5/15.
//  Copyright (c) 2015 KICKERCHEN. All rights reserved.
//

import UIKit
import Parse

class RegisterViewController: UIViewController {

    @IBOutlet weak var userTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    let signUpSuccessfulSegue = "SignupSuccesful"
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    // MARK: - Actions
    @IBAction func signUpButtonPressed(sender: AnyObject) {
        //TODO
        
        let user = PFUser()
        user.username = self.userTextField.text
        user.password = self.passwordTextField.text
        user.signUpInBackgroundWithBlock { succeeded, error in
            
            if succeeded {
                //If signup sucessful:
                self.performSegueWithIdentifier(self.signUpSuccessfulSegue, sender: nil)
                
            } else if let error = error {
                
                self.showErrorView(error)
            }
        }
        
        
    }
}
