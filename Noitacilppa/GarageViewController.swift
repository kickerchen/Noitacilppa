//
//  GarageViewController.swift
//  Noitacilppa
//
//  Created by CHENCHIAN on 8/6/15.
//  Copyright (c) 2015 KICKERCHEN. All rights reserved.
//

import UIKit
import Parse

class GarageViewController: UIViewController {
    
    @IBOutlet weak var logoutLabel: UILabel!
    @IBOutlet weak var countDownLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    
    let logoutSegue = "LogOutSegue"
    
    var logoutTimer: NSTimer? = nil
    var count: Int = 6 {
        didSet {
            if count == 0 {
                
                self.performSegueWithIdentifier(logoutSegue, sender: nil)

            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    deinit {
        if let timer = logoutTimer {
            timer.invalidate()
            logoutTimer = nil
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func logoutButtonPressed(sender: UIButton) {
        
        PFUser.logOut()
        UIView.animateWithDuration(0.5, animations: {
            self.logoutLabel.alpha = 1.0
        })

        logoutTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "countDown", userInfo: nil, repeats: true)
    }
    
    func countDown() {
        
        count--
        if count > 0 {
            countDownLabel.text = "\(count)"
        }
        
    }
}
