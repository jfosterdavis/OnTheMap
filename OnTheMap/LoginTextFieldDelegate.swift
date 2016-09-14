//
//  LoginTextFieldDelegate.swift
//  OnTheMap
//
//  Created by Jacob Foster Davis on 9/10/16.
//  Copyright © 2016 Udacity. All rights reserved.
//

import Foundation
import UIKit

class LoginTextFieldDelegate: NSObject, UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
}
