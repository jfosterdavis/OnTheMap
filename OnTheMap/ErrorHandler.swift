//
//  ErrorHandler.swift
//  OnTheMap
//
//  Created by Jacob Foster Davis on 9/17/16.
//  Copyright © 2016 Udacity. All rights reserved.
//

import Foundation
import UIKit

struct ErrorHandler {
    
    /// gives the user an alert. adapted from http://www.ioscreator.com/tutorials/display-an-alert-view-in-ios8-with-swift
    static func alertUser(_ sender: UIViewController, alertTitle: String, alertMessage: String) -> Void {
        //create an alert controller
        let alertController = UIAlertController(title: alertTitle, message:
            alertMessage, preferredStyle: UIAlertControllerStyle.alert)
        
        //add dismiss button
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
        
        //present the alert
        sender.present(alertController, animated: true, completion: nil)
    } // end of alertUser
    
}
