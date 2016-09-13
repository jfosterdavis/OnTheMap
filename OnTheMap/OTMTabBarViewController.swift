//
//  OTMTabBarViewController.swift
//  OnTheMap
//
//  Created by Jacob Foster Davis on 9/13/16.
//  Copyright © 2016 Udacity. All rights reserved.
//

import Foundation
import UIKit

protocol OTMTabBarControllerDelegate: class {
    func plotNewPinFromStudentInformation(newStudentInfo : StudentInformation)
}

class OTMTabBarController: UITabBarController, PinPostViewControllerDelegate {
    
    @IBOutlet weak var addNewPinButton: UIBarButtonItem!
    @IBOutlet weak var logOutButton: UIBarButtonItem!
    
    weak var otmDelegate : OTMTabBarControllerDelegate? = nil
    
    /******************************************************/
    /******************* Shared Model **************/
    /******************************************************/
    //MARK: - Shared Model
    
    var UdacityUserInfo: UdacityUserInformation {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).UdacityUserInfo
    }
    
    var NewStudentInfo: StudentInformation {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).NewStudentInfo
    }
    
    var StudentInformations: [StudentInformation]{
        return (UIApplication.sharedApplication().delegate as! AppDelegate).StudentInformations
    }
    
    /******************************************************/
    /******************* Actions **************/
    /******************************************************/
    //MARK: - Actions
    
    
    @IBAction func addNewPinButtonPressed(sender: AnyObject) {
        
        let vc = storyboard?.instantiateViewControllerWithIdentifier("PinPostViewController") as! PinPostViewController
        vc.delegate = self
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    
    @IBAction func logOutButtonPressed(sender: AnyObject) {
    }
    
    
    /******************************************************/
    /******************* PinPostViewControllerDelegate **************/
    /******************************************************/
    //MARK: - PinPostViewControllerDelegate
    
    func newStudentInformationDataReady(newStudentInfo: StudentInformation) {
        setupNewStudentInfo()
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.NewStudentInfo = newStudentInfo
        
        appDelegate.NewStudentInfo.firstName = "Test First Name"
        appDelegate.NewStudentInfo.lastName = "Test Last Name"
        appDelegate.NewStudentInfo.uniqueKey = "Test User ID"
        print("Got new student info from PinPostViewController:")
        print(self.NewStudentInfo)
        
        //make the mapview the displayed tab
        // adapted from http://stackoverflow.com/questions/25325923/programatically-switching-between-tabs-within-swift
        self.selectedIndex = 0
        
        //send this new StudentInfo to the mapview to plot it
        self.otmDelegate!.plotNewPinFromStudentInformation(self.NewStudentInfo)
        
        
    }
    
    /******************************************************/
    /******************* Housekeeping **************/
    /******************************************************/
    //MARK: - Housekeeping
    
    func setupNewStudentInfo() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.NewStudentInfo = StudentInformation()
    }
}