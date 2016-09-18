//
//  StudentInformationsModel.swift
//  OnTheMap
//
//  Created by Jacob Foster Davis on 9/17/16.
//  Copyright © 2016 Udacity. All rights reserved.
//

import Foundation
import UIKit

class StudentInformationsModel: NSObject {
    
    //singleton
    static let sharedInstance = StudentInformationsModel()
    
    var StudentInformations = [StudentInformation]()
    
    func resetStudentInformations() {
        self.StudentInformations = [StudentInformation]()
    }
    
}

