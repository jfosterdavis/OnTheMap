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

// MARK: - ParseClient (Convenient Resource Methods)

extension ParseClient {
    
    // MARK: Authentication (GET) Methods
    /*
     Steps for Authentication...
     www.udacity.com/api/session
     
     Step 1: Request a session ID
     Step 2: Set the Session ID
    */
    
    func getStudentLocations(limit : Int? = nil, skip: Int? = nil, order: String? = nil, completionHandlerForGetStudentLocations: (success: Bool, errorString: String?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        var parameters : [String: String] = [String: String]()
        //check for each parameter and add to dictionary
        //limit
        if let limit = limit {
            parameters[ParseClient.ParameterKeys.Limit] = String(limit)
        }
        //skip
        if let skip = skip {
            parameters[ParseClient.ParameterKeys.Skip] = String(skip)
        }
        //order
        if let order = order {
            parameters[ParseClient.ParameterKeys.Order] = order
        }
        
        var passTheseParameters : [String: String]?
        if parameters.isEmpty {
            passTheseParameters = nil
        } else {
            passTheseParameters = parameters
        }
        
        //var mutableMethod: String = ParseClient.Methods.StudentLocationGET
        //mutableMethod = subtituteKeyInMethod(mutableMethod, key: "", value: "")! //There are no keys in this method
        
        //let jsonBody = "" //this request does not require anything in the HTTPBody
        print("\nAttempting to get Student Locations with the following parameters: ")
        print(parameters)
        
        /* 2. Make the request */
        taskForGETMethod(ParseClient.Methods.StudentLocationGET, parameters: passTheseParameters) { (results, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                print(error)
                completionHandlerForGetStudentLocations(success: false, errorString: "Login Failed (Session ID).")
            } else {
                //json should have returned a A dictionary with a key of "results" that contains an array of dictionaries
                //print("JSON response from getStudentLocations:")
                //print(results)
                
                //At the end of the following if pyramid we will try to create a new StudentInformation struct and assign it values from the JSON results
                var tryCount : Int = 0 //track tries
                var successCount : Int = 0 //keep track of successes
                var failCount : Int = 0  //track fails
                
                if let resultsArray = results[ParseClient.JSONResponseKeys.Results.Results] as? NSArray { //dig into the JSON response dictionary to get the array at key "results"
                    
                    //print("Unwrapped JSON response from getStudentLocations:")
                    //print (resultsArray)
                    for locationDictionary in resultsArray { //step through each member of the "results" array
                        if let locationDictionary = locationDictionary as? [String:AnyObject] { //ensure eacy dictionary matches the correct type
                            
                            //this is the beginning of a new try
                            tryCount += 1
                            
                            if let newStudentInformationStruct = StudentInformation(fromDataSet: locationDictionary){ //attempt to initialize a new StudentInformationStruct from the dictionary
                                
                                //We have a new StudentInformation struct, so save it to the shared model
                                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                                appDelegate.StudentInformations.append(newStudentInformationStruct)
                                
                                //this attempt was a success
                                successCount += 1
                            } else { //if the attempt to init a new StudentInformation struct returns nil, it was not successful
                                print("\nDATA ERROR: Failed to initialize a new StudentInformation Struct")
                                
                                //this attempt was a failure
                                failCount += 1
                            }
                            //print("\nHere is one new item from the array of objects:")
                            //print(locationDictionary)
                        } else {
                            print("DATA ERROR: Array within the \"results\" dictionary does not match type [String:AnyObject]")
                        }
                        
                    }
                    print("\nThere are " + String(self.StudentInformations.count) + " Information Records stored.  getStudentLocations data pull Complete.")
                    completionHandlerForGetStudentLocations(success: true, errorString: nil)
                } else {
                    print("\nDATA ERROR: Could not find \(ParseClient.JSONResponseKeys.Results.Results) in \(results)")
                    completionHandlerForGetStudentLocations(success: false, errorString: "\nDATA ERROR: Failed to interpret data returned from Parse server (getStudentLocations).")
                }
                //report the results of this function to the log
                print("\n")
                print(String(tryCount) + " attempts to take data and initialize a new StudentLocation and store in shared model.")
                print(String(successCount) + " of these StudentLocations attempts were successful.")
                print(String(failCount) + " of these StudentLocations attempts failed.  These failures were not added to the shared model.")
            }
        }
    }
}