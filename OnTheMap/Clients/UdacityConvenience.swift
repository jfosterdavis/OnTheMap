//
//  UdacityConvenience.swift
//  OnTheMap
//
//  Derrived from work Created by Jarrod Parkes on 2/11/15.
//  Copyright (c) 2015 Jarrod Parkes. All rights reserved.
//
//  Further devlopment by Jacob Foster Davis in August - September 2016

import UIKit
import Foundation

// MARK: - UdacityClient (Convenient Resource Methods)

extension UdacityClient {
    
    // MARK: Authentication (GET) Methods
    /*
        Steps for Authentication...
        www.udacity.com/api/session
    
        Step 1: Request a session ID
        Step 2: Set the Session ID
    */
    
    /******************************************************/
    /******************* Log Out **************/
    /******************************************************/
    //MARK: - Log Out
    /**
     Logs the user out
     
     -Returns: `true` if successful, `false` otherwise
     
     */
    func logOutUser(_ completionHandlerForLogOutUser: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        self.deleteUserSession() { (result, error) in
            if result != nil {
                completionHandlerForLogOutUser(result, nil)
    
            } else {
                completionHandlerForLogOutUser(nil, error)
            }
        }
        
    } // end of logOutUser
    
    /**
     Network request to delete the current user session
     
     */
    func deleteUserSession(_ completionHandlerForDeleteUserSession: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        //no parameters
        let parameters : [String:AnyObject]? = nil
        let mutableMethod: String = Methods.DeleteSession
        //mutableMethod = subtituteKeyInMethod(mutableMethod, key: UdacityClient.URLKeys.UserID, value: String(UdacityClient.sharedInstance.userID!))!
        
        /* 2. Make the request */
        let _ = taskForDELETEMethod(mutableMethod, parameters: parameters) { (results, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                print(error)
                completionHandlerForDeleteUserSession(nil, error)
            } else {
                //json should have returned a [[String:AnyObject]]
                if let sessionResults = (results?[UdacityClient.JSONResponseKeys.Session.Session] as? [String:AnyObject]) {
                    if (sessionResults[UdacityClient.JSONResponseKeys.Session.ID] as? String) != nil {
                        //completionHandlerForSession(success: true, sessionID: sessionID, errorString: nil)
                        completionHandlerForDeleteUserSession(results, nil)
                    } else {
                        print("Could not find \(UdacityClient.JSONResponseKeys.Session.ID) in \(results)")
                        completionHandlerForDeleteUserSession(nil, NSError(domain: "deleteUserSession parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not find Session ID"]))
                    }
                } else {
                    print("Could not find \(UdacityClient.JSONResponseKeys.Session.Session) in \(results)")
                    completionHandlerForDeleteUserSession(nil, NSError(domain: "deleteUserSession parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not find JSON results"]))
                }
            }
        }
        
        
    } // end of deleteUserSession
    
    /******************************************************/
    /******************* Fetch Public User Data **************/
    /******************************************************/
    //MARK: - Public User Data
    
    /**
     Fetches Public data about a user based on the userID from the Udacity Server
     
     - Parameters:
         - completionHandlerForFetchUserData: completion handler
     */
    func fetchUserData(_ completionHandlerForFetchUserData: @escaping (_ result: UdacityUserInformation?, _ error: NSError?) -> Void) {
        
        self.getUserData() { (result, error) in
            if let result = result {
                completionHandlerForFetchUserData(result, nil)
            } else {
                completionHandlerForFetchUserData(nil, error)
            }
        }
        
    }
    
    func getUserData(_ completionHandlerForGetUserData: @escaping (_ result: UdacityUserInformation?, _ error: NSError?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        //no parameters
        let parameters : [String:AnyObject]? = nil
        var mutableMethod: String = Methods.PublicUserData
        mutableMethod = subtituteKeyInMethod(mutableMethod, key: UdacityClient.URLKeys.UserID, value: String(UdacityClient.sharedInstance.userID!))!
        
        /* 2. Make the request */
        let _ = taskForGETMethod(mutableMethod, parameters: parameters) { (results, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandlerForGetUserData(nil, error)
            } else {
                
                //parse the response and create a UdacityUserInformation object. UserID is already known
                var newUdacityUserInfo = UdacityUserInformation()
                newUdacityUserInfo.userID = UdacityClient.sharedInstance.userID!
                //model: //(results?[UdacityClient.JSONResponseKeys.Account.Account] as? [String:AnyObject])?[UdacityClient.JSONResponseKeys.Account.Key] as? String
                print(results![UdacityClient.JSONResponseKeys.User.User] as? [String:AnyObject])
                if let userResults = (results?[UdacityClient.JSONResponseKeys.User.User] as? [String:AnyObject]) {
                    if let firstName = userResults[UdacityClient.JSONResponseKeys.User.FirstName] as? String {
                        newUdacityUserInfo.firstName = firstName
                        
                        if let lastName = userResults[UdacityClient.JSONResponseKeys.User.LastName] as? String {
                            newUdacityUserInfo.lastName = lastName
                            if let nickName = userResults[UdacityClient.JSONResponseKeys.User.NickName] as? String {
                                newUdacityUserInfo.nickName = nickName
                                
                                if let imageURL = (results?[UdacityClient.JSONResponseKeys.User.User] as? [String:AnyObject])?[UdacityClient.JSONResponseKeys.User.ImageURL] as? String {
                                    newUdacityUserInfo.imageURL = imageURL
                                    
                                    //now have a completed UdacityUserInformation object, so return
                                    completionHandlerForGetUserData(newUdacityUserInfo, nil)
                                    
                                } else {
                                    print("ERROR Could not find \(UdacityClient.JSONResponseKeys.User.ImageURL) in \(results)")
                                    completionHandlerForGetUserData(nil, NSError(domain: "getUserData parsing", code: 5, userInfo: [NSLocalizedDescriptionKey: "Could not get user imageURL"]))
                                }
                                
                            } else {
                                print("ERROR Could not find \(UdacityClient.JSONResponseKeys.User.NickName) in \(results)")
                                completionHandlerForGetUserData(nil, NSError(domain: "getUserData parsing", code: 5, userInfo: [NSLocalizedDescriptionKey: "Could not get user nickname"]))
                            }
                            
                        } else {
                            print("ERROR Could not find \(UdacityClient.JSONResponseKeys.User.LastName) in \(results)")
                            completionHandlerForGetUserData(nil, NSError(domain: "getUserData parsing", code: 5, userInfo: [NSLocalizedDescriptionKey: "Could not get last name"]))
                        }
                        
                    } else {
                        print("ERROR Could not find \(UdacityClient.JSONResponseKeys.User.FirstName) in \(results)")
                        completionHandlerForGetUserData(nil, NSError(domain: "getUserData parsing", code: 5, userInfo: [NSLocalizedDescriptionKey: "Could not get first name"]))
                    }
                } else {
                    print("ERROR Could not find \(UdacityClient.JSONResponseKeys.User.User) in \(results)")
                    completionHandlerForGetUserData(nil, NSError(domain: "getUserData parsing", code: 5, userInfo: [NSLocalizedDescriptionKey: "Could not get user dictionary"]))
                }
            }
        }
        
    }
    
    
    /******************************************************/
    /******************* Log in **************/
    /******************************************************/
    //MARK: - Log in
    
    func authenticateWithViewController(_ username: String, password : String, hostViewController: UIViewController, completionHandlerForAuth: @escaping (_ success: Bool, _ error: NSError?) -> Void) {
        
        self.getSessionID(username, password: password) { (success, sessionID, userID, error) in
            if success {
                
                // success! we have the sessionID!
                self.sessionID = sessionID
                print("Session ID is: " + (sessionID)!)
                self.userID = userID
                print("User ID is: " + (userID)!)
                completionHandlerForAuth(success, nil)
            } else {
                completionHandlerForAuth(success, error)
            }
        }
    }
  
    fileprivate func getSessionID(_ username : String, password: String, completionHandlerForSession: @escaping (_ success: Bool, _ sessionID: String?, _ userID: String?, _ error: NSError?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        // No parameters needed to get session ID

        let jsonBody = "{\"\(UdacityClient.JSONBodyKeys.Udacity.Udacity)\": {\"\(UdacityClient.JSONBodyKeys.Udacity.Username)\": \"\(username)\", \"\(UdacityClient.JSONBodyKeys.Udacity.Password)\": \"\(password)\"}}"
        print("Attempting to get Session ID with the following jsonBody: " + (jsonBody))
        /* 2. Make the request */
        let _ = taskForPOSTMethod(UdacityClient.Methods.AuthenticationSessionNew, parameters: nil, jsonBody: jsonBody) { (results, error) in
            //error sender
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForSession(false, nil, nil, NSError(domain: "getSessionID", code: 4, userInfo: userInfo))
            }
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                print(error)
                completionHandlerForSession(false, nil, nil, error)
            } else {
                //json should have returned a [[String:AnyObject]]
                if let sessionResults = (results?[UdacityClient.JSONResponseKeys.Session.Session] as? [String:AnyObject]) {
                    if let sessionID = sessionResults[UdacityClient.JSONResponseKeys.Session.ID] as? String {
                        //completionHandlerForSession(success: true, sessionID: sessionID, errorString: nil)
                        //get userID
                        if let accountResults = (results?[UdacityClient.JSONResponseKeys.Account.Account] as? [String:AnyObject]) {
                            
                            if let userID = accountResults[UdacityClient.JSONResponseKeys.Account.Key] as? String {
                                completionHandlerForSession(true, sessionID, userID, nil)
                            } else {
                                print("Could not find \(UdacityClient.JSONResponseKeys.Account.Key) in \(results)")
                                sendError("Login Failed (Couldn't obtain User ID).")
                            }
                        } else {
                            print("Could not find \(UdacityClient.JSONResponseKeys.Account.Account) in \(results)")
                            sendError("Login Failed (Couldn't obtain User ID).")
                        }
                        
                    } else {
                        print("Could not find \(UdacityClient.JSONResponseKeys.Session.ID) in \(results)")
                        sendError("Login Failed (Couldn't obtain User ID).")
                    }
                } else {
                    print("Could not find \(UdacityClient.JSONResponseKeys.Session.Session) in \(results)")
                    sendError("Login Failed (Couldn't obtain User ID).")
                }
            }
        }
    }
}
