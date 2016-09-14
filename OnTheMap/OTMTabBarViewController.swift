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
    func plotNewPinFromStudentInformation(_ newStudentInfo : StudentInformation)
}

class OTMTabBarController: UITabBarController, PinPostViewControllerDelegate {
    
    @IBOutlet weak var addNewPinButton: UIBarButtonItem!
    @IBOutlet weak var logOutButton: UIBarButtonItem!
    
    weak var otmDelegate : OTMTabBarControllerDelegate? = nil
    
    var newUserInfo : UdacityUserInformation?
    
    /******************************************************/
    /******************* Shared Model **************/
    /******************************************************/
    //MARK: - Shared Model
    
    var UdacityUserInfo: UdacityUserInformation {
        return (UIApplication.shared.delegate as! AppDelegate).UdacityUserInfo
    }
    
    var NewStudentInfo: StudentInformation {
        return (UIApplication.shared.delegate as! AppDelegate).NewStudentInfo
    }
    
    var StudentInformations: [StudentInformation]{
        return (UIApplication.shared.delegate as! AppDelegate).StudentInformations
    }
    
    /******************************************************/
    /******************* Life Cycle **************/
    /******************************************************/
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        
        //attempt to get user info
        fetchUserData()
        //check to see if data was retrived, and set shared model if so

        
    }
    
    /******************************************************/
    /******************* Actions **************/
    /******************************************************/
    //MARK: - Actions
    
    
    @IBAction func addNewPinButtonPressed(_ sender: AnyObject) {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "PinPostViewController") as! PinPostViewController
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    
    @IBAction func logOutButtonPressed(_ sender: AnyObject) {
    }
    
    /******************************************************/
    /******************* User Data **************/
    /******************************************************/
    //MARK: - User Data
    
    func fetchUserData() -> Void {
        print("Attempting to fetch user data from OTMTabBarController")
        GCDBlackBox.runNetworkFunctionInBackground {
            UdacityClient.sharedInstance.fetchUserData() { (result, error) in
                GCDBlackBox.performUIUpdatesOnMain {
                    //self.stopActivityIndicator()
                    if let result = result {
                        //check that this userID matches the one we already have
                        if self.UdacityUserInfo.userID == result.userID! {
                            //they match, so set the temporary newUserInfo
                            
                            self.newUserInfo = result
                            print("OTMTabBarController successfully retrieved and set newUserInfo")
                            self.updateUdacityModelFromNewUserInfo()
                        } else {
                            //something has gone wrong and we have a different user
                            //TODO: handle error
                            /*
                             *  <#description#>
                             */
                            print("OTMTabBarController failed to retrieve and set newUserInfo (userID mismatch)")
                            self.newUserInfo = nil
                        }
                        
                    } else {
                        //TODO: handle error
                        /*
                         *  <#description#>
                         */
                        
                        print("OTMTabBarController failed to retrieve and set newUserInfo (empty result set)")
                        self.newUserInfo = nil
                    }
                }
            }
        }
    }
    
    func updateUdacityModelFromNewUserInfo(){
        if let tempNewUserInfo = newUserInfo {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.UdacityUserInfo = tempNewUserInfo
            print("Set the shared UdacityUserInfo model:")
            print(UdacityUserInfo)
            
            //update the "logged in as"
            updateNavBarPromptName("\(UdacityUserInfo.firstName!) \(UdacityUserInfo.lastName!)")
        }
    }
    
    func updateNavBarPromptName(_ name: String) {
        self.navigationItem.prompt = "Logged in as: " + name
    }
    
    
    /******************************************************/
    /******************* PinPostViewControllerDelegate **************/
    /******************************************************/
    //MARK: - PinPostViewControllerDelegate
    
    func newStudentInformationDataReady(_ newStudentInfo: StudentInformation) {
        setupNewStudentInfo()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
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
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.NewStudentInfo = StudentInformation()
    }
}
