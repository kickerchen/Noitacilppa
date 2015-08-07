//
//  UIViewControllerExtension.swift
//  Noitacilppa
//
//  Created by CHENCHIAN on 8/5/15.
//  Copyright (c) 2015 KICKERCHEN. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func showErrorView(error: NSError) {
        if let errorMessage = error.userInfo?["error"] as? String {
            let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
        }
    }
}
