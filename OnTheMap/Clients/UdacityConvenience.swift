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
    
    func fetchUserData(_ completionHandlerForFetchUserData: @escaping (_ result: UdacityUserInformation?, _ error: NSError?) -> Void) {
        
        self.getUserData() { (result, error) in
            if let result = result {
                completionHandlerForFetchUserData(result, nil)
            } else {
                completionHandlerForFetchUserData(result, error)
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
                
                if let firstName = results?[UdacityClient.JSONResponseKeys.User.User]?![UdacityClient.JSONResponseKeys.User.FirstName] as? String {
                    newUdacityUserInfo.firstName = firstName
                    
                    if let lastName = results?[UdacityClient.JSONResponseKeys.User.User]?![UdacityClient.JSONResponseKeys.User.LastName] as? String {
                        newUdacityUserInfo.lastName = lastName
                        if let nickName = results?[UdacityClient.JSONResponseKeys.User.User]?![UdacityClient.JSONResponseKeys.User.NickName] as? String {
                            newUdacityUserInfo.nickName = nickName
                            
                            if let imageURL = results?[UdacityClient.JSONResponseKeys.User.User]?![UdacityClient.JSONResponseKeys.User.ImageURL] as? String {
                                newUdacityUserInfo.imageURL = imageURL
                                
                                //now have a completed UdacityUserInformation object, so return
                                completionHandlerForGetUserData(newUdacityUserInfo, nil)
                                
                            } else {
                                print("Could not find \(UdacityClient.JSONResponseKeys.User.User) in \(results)")
                                completionHandlerForGetUserData(nil, NSError(domain: "getUserData parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not get user imageURL"]))
                            }
                            
                        } else {
                            print("Could not find \(UdacityClient.JSONResponseKeys.User.User) in \(results)")
                            completionHandlerForGetUserData(nil, NSError(domain: "getUserData parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not get user nickname"]))
                        }
                        
                    } else {
                        print("Could not find \(UdacityClient.JSONResponseKeys.User.User) in \(results)")
                        completionHandlerForGetUserData(nil, NSError(domain: "getUserData parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not get last name"]))
                    }
                    
                } else {
                    print("Could not find \(UdacityClient.JSONResponseKeys.User.User) in \(results)")
                    completionHandlerForGetUserData(nil, NSError(domain: "getUserData parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not get first name"]))
                }
            }
        }
        
    }
    
    func authenticateWithViewController(_ username: String, password : String, hostViewController: UIViewController, completionHandlerForAuth: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        self.getSessionID(username, password: password) { (success, sessionID, userID, errorString) in
            if success {
                
                // success! we have the sessionID!
                self.sessionID = sessionID
                print("Session ID is: " + (sessionID)!)
                self.userID = userID
                print("User ID is: " + (userID)!)
                completionHandlerForAuth(success, nil)
            } else {
                completionHandlerForAuth(success, errorString)
            }
        }
    }
  
    fileprivate func getSessionID(_ username : String, password: String, completionHandlerForSession: @escaping (_ success: Bool, _ sessionID: String?, _ userID: String?, _ errorString: String?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        // No parameters needed to get session ID
        //let parameters = [UdacityClient.ParameterKeys.RequestToken: requestToken!]
        //let parameters = nil
        let jsonBody = "{\"\(UdacityClient.JSONBodyKeys.Udacity.Udacity)\": {\"\(UdacityClient.JSONBodyKeys.Udacity.Username)\": \"\(username)\", \"\(UdacityClient.JSONBodyKeys.Udacity.Password)\": \"\(password)\"}}"
        print("Attempting to get Session ID with the following jsonBody: " + (jsonBody))
        /* 2. Make the request */
        let _ = taskForPOSTMethod(UdacityClient.Methods.AuthenticationSessionNew, parameters: nil, jsonBody: jsonBody) { (results, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                print(error)
                completionHandlerForSession(false, nil, nil, "Login Failed (Session ID).")
            } else {
                //json should have returned a [[String:AnyObject]]
                //print("About to find a Session Id within:")
                //print(results)
                
                if let sessionID = results?[UdacityClient.JSONResponseKeys.Session.Session]?![UdacityClient.JSONResponseKeys.Session.ID] as? String {
                    //completionHandlerForSession(success: true, sessionID: sessionID, errorString: nil)
                    
                    //get userID
                    if let userID = results?[UdacityClient.JSONResponseKeys.Account.Account]?![UdacityClient.JSONResponseKeys.Account.Key] as? String {
                        completionHandlerForSession(success: true, sessionID: sessionID, userID: userID, errorString: nil)
                    } else {
                        print("Could not find \(UdacityClient.JSONResponseKeys.Session.Session) in \(results)")
                        completionHandlerForSession(success: false, sessionID: sessionID, userID: nil, errorString: "Login Failed (Couldn't obtain User ID).")
                    }
                    
                } else {
                    print("Could not find \(UdacityClient.JSONResponseKeys.Session.Session) in \(results)")
                    completionHandlerForSession(false, nil, nil, "Login Failed (Session ID).")
                }
                

            }
        }
    }
}
