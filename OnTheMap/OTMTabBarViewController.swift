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

protocol OTMTabBarControllerLogOutDelegate: class {
    func userLoggedOut()
}

class OTMTabBarController: UITabBarController, PinPostViewControllerDelegate {
    
    @IBOutlet weak var addNewPinButton: UIBarButtonItem!
    @IBOutlet weak var logOutButton: UIBarButtonItem!
    
    weak var otmDelegate : OTMTabBarControllerDelegate? = nil
    var otmLogOutDelegates = [OTMTabBarControllerLogOutDelegate]()
    
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
        
        GCDBlackBox.runNetworkFunctionInBackground {
            UdacityClient.sharedInstance.logOutUser() { (result, error) in
                GCDBlackBox.performUIUpdatesOnMain {
                    //self.stopActivityIndicator()
                    if result != nil {
                        
                        //reset nav bar prompt
                        self.updateNavBarPromptName(nil)
                        
                        
                        
                        //dismiss back to log in screen
                        self.dismiss(animated: true, completion: nil)
                        
                        //run view controller housekeeping
                        for vc in self.otmLogOutDelegates {
                            vc.userLoggedOut()
                        }
                        
                        //cleared out the shared models
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.resetAllSharedModels()
                        
                    } else {
                        //TODO: handle error
                        /*
                         *  <#description#>
                         */
                        
                        print("OTMTabBarController failed to log user out. (empty result set)")
                    }
                }
            }
        }
        
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
    
    func updateNavBarPromptName(_ name: String?) {
        
        if name != nil {
            self.navigationItem.prompt = "Logged in as: " + name!
        } else {
            self.navigationItem.prompt = nil
        }
    }
    
    /******************************************************/
    /******************* POSTing new pins to Parse **************/
    /******************************************************/
    //MARK: - POSTing new pins to Parse
    
    func postNewStudentInformationToParse(postThisStudent: StudentInformation, successfulCompletionHandler: (() -> Void)?) {
        print("Attempting to post a studentLocation to Parse")
        GCDBlackBox.runNetworkFunctionInBackground {
            ParseClient.sharedInstance.postStudentLocation(postThisStudent) { (result, error) in
                GCDBlackBox.performUIUpdatesOnMain {
                    //self.stopActivityIndicator()
                    if let result = result {
                        //update the new student info
                                                //update createdAt
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        
                        if  let createdAtDate = self.NewStudentInfo.stringToDate(inboundString: result[ParseClient.JSONResponseKeys.Results.CreatedAt]!) {
                            appDelegate.NewStudentInfo.createdAt = createdAtDate
                            
                            //update objectId
                        appDelegate.NewStudentInfo.objectID = result[ParseClient.JSONResponseKeys.Results.ObjectID]
                            
                            //great success.  run the optional completion handler
                            if let completion = successfulCompletionHandler {
                                completion()
                            }
                        } else {
                            print("Error, couldn't update newStudentInfo createdAt")
                            //TODO: handle error
                            /*
                             *  <#description#>
                             */
                        }
                        
                        
                        
                    } else {
                        //TODO: handle error
                        /*
                         *  <#description#>
                         */
                        
                        print("OTMTabBarController failed to post a new studentLocation)")
                        
                    }
                }
            }
        }
    }
    
    /******************************************************/
    /******************* PinPostViewControllerDelegate **************/
    /******************************************************/
    //MARK: - PinPostViewControllerDelegate
    
    func newStudentInformationDataReady(_ newStudentInfo: StudentInformation) {
        setupNewStudentInfo()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.NewStudentInfo = newStudentInfo
        
        //first name
        if let newFirstName = UdacityUserInfo.firstName {
            appDelegate.NewStudentInfo.firstName = newFirstName
        } else {
            appDelegate.NewStudentInfo.firstName = "Unknown"
        }
        
        //last name
        if let newLastName = UdacityUserInfo.lastName {
            appDelegate.NewStudentInfo.lastName = newLastName
        } else {
            appDelegate.NewStudentInfo.lastName = "Unknown"
        }
        
        //unique key/account number/userID
        if let newUniqueKey = UdacityUserInfo.userID {
            appDelegate.NewStudentInfo.uniqueKey = newUniqueKey
        } else {
            appDelegate.NewStudentInfo.uniqueKey = "Unknown"
        }
        //created at
        let date = Date()
        appDelegate.NewStudentInfo.createdAt = date
        
        print("Got new student info from PinPostViewController:")
        print(self.NewStudentInfo)
        
        postNewStudentInformationToParse(postThisStudent: appDelegate.NewStudentInfo, successfulCompletionHandler: finishNewStudentInformationDataReady)
 
    }
    
    private func finishNewStudentInformationDataReady() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        //put this pin in the shared model
        //appDelegate.StudentInformations.append(NewStudentInfo)
        
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
