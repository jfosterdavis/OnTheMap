//
//  UdacityConvenience.swift
//  TheMovieManager
//
//  Created by Jarrod Parkes on 2/11/15.
//  Copyright (c) 2015 Jarrod Parkes. All rights reserved.
//

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
                print("JSON response from getStudentLocations:")
                print(results)
                if let resultsArray = results[ParseClient.JSONResponseKeys.Results.Results] as? NSArray { //dig into the JSON response dictionary to get the array at key "results"
                    print("Unwrapped JSON response from getStudentLocations:")
                    print (resultsArray)
                    for locationDictionary in resultsArray { //step through each member of the "resulst" array
                        if let locationDictionary = locationDictionary as? [String:AnyObject] { //ensure eacy dictionary matches the correct type
                            if let newStudentInformationStruct = StudentInformation(fromDataSet: locationDictionary){ //attempt to initialize a new StudentInformationStruct from the dictionary
                                //We have a new StudentInformation struct, so save it to the shared model
                                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                                appDelegate.StudentInformations.append(newStudentInformationStruct)
                            } else {
                                print("ERROR: Failed to initialize a new StudentInformation Struct")
                            }
                            //print("\nHere is one new item from the array of objects:")
                            //print(locationDictionary)
                        } else {
                            print("ERROR: Array within the \"results\" dictionary does not match type [String:AnyObject]")
                        }
                        
                    }
                    print("There are " + String(self.StudentInformations.count) + " Information Records stored.  getStudentLocations data pull Complete.")
                } else {
                    print("Could not find \(ParseClient.JSONResponseKeys.Results.Results) in \(results)")
                    completionHandlerForGetStudentLocations(success: false, errorString: "Failed to pull StudentLocations from Udacity Parse Server (getStudentLocations).")
                }
            }
        }
    }
}