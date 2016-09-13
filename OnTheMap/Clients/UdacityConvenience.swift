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
    func authenticateWithViewController(username: String, password : String, hostViewController: UIViewController, completionHandlerForAuth: (success: Bool, errorString: String?) -> Void) {
        
        self.getSessionID(username, password: password) { (success, sessionID, userID, errorString) in
            if success {
                
                // success! we have the sessionID!
                self.sessionID = sessionID
                print("Session ID is: " + (sessionID)!)
                self.userID = userID
                print("User ID is: " + (userID)!)
                completionHandlerForAuth(success: success, errorString: nil)
            } else {
                completionHandlerForAuth(success: success, errorString: errorString)
            }
        }
    }
  
    private func getSessionID(username : String, password: String, completionHandlerForSession: (success: Bool, sessionID: String?, userID: String?, errorString: String?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        // No parameters needed to get session ID
        //let parameters = [UdacityClient.ParameterKeys.RequestToken: requestToken!]
        //let parameters = nil
        let jsonBody = "{\"\(UdacityClient.JSONBodyKeys.Udacity.Udacity)\": {\"\(UdacityClient.JSONBodyKeys.Udacity.Username)\": \"\(username)\", \"\(UdacityClient.JSONBodyKeys.Udacity.Password)\": \"\(password)\"}}"
        print("Attempting to get Session ID with the following jsonBody: " + (jsonBody))
        /* 2. Make the request */
        taskForPOSTMethod(UdacityClient.Methods.AuthenticationSessionNew, parameters: nil, jsonBody: jsonBody) { (results, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                print(error)
                completionHandlerForSession(success: false, sessionID: nil, userID: nil, errorString: "Login Failed (Session ID).")
            } else {
                //json should have returned a [[String:AnyObject]]
                //print("About to find a Session Id within:")
                //print(results)
                if let sessionID = results[UdacityClient.JSONResponseKeys.Session.Session]?![UdacityClient.JSONResponseKeys.Session.ID] as? String {
                    //completionHandlerForSession(success: true, sessionID: sessionID, errorString: nil)
                    
                    //get userID
                    if let userID = results[UdacityClient.JSONResponseKeys.Account.Account]?![UdacityClient.JSONResponseKeys.Account.Key] as? String {
                        completionHandlerForSession(success: true, sessionID: sessionID, userID: userID, errorString: nil)
                    } else {
                        print("Could not find \(UdacityClient.JSONResponseKeys.Session.Session) in \(results)")
                        completionHandlerForSession(success: false, sessionID: sessionID, userID: nil, errorString: "Login Failed (Couldn't obtain User ID).")
                    }
                    
                } else {
                    print("Could not find \(UdacityClient.JSONResponseKeys.Session.Session) in \(results)")
                    completionHandlerForSession(success: false, sessionID: nil, userID: nil, errorString: "Login Failed (Session ID).")
                }
                

            }
        }
    }
}