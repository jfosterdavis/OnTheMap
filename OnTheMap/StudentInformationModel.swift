//
//  StudentInformationModel.swift
//  OnTheMap
//
//  Created by Jacob Foster Davis on 9/5/16.
//  Copyright © 2016 Udacity. All rights reserved.
//

import Foundation

/**
 Designed to hold Student Information from the Udacity Parse Server for On the Map.  Called StudentLocation in API documentation
 
 - Parameters:
     - fromDataSet: (optional) a`[String:AnyObject]` containing key-value pairs that match `expectedKeys`
 
 - Returns: 
    - If provided `fromDataSet`
        - Nil: if instantiation was unsuccessful
        - A `StudentInformation` Object: if instantiation was successful
    - Otherwise: Void
 */
struct StudentInformation {
    
    /******************************************************/
    /******************* Properties **************/
    /******************************************************/
    //MARK: - Properties
    var objectID : String? /// an auto-generated id/key generated by Parse which uniquely identifies a StudentLocation */
    var uniqueKey : String? //Description: an extra (optional) key used to uniquely identify a StudentLocation; you should populate this value using your Udacity account id
    var firstName : String? //Description: the first name of the student which matches their Udacity profile first name
    var lastName : String? //Description: the last name of the student which matches their Udacity profile last name
    var mapString : String? //Description: the location string used for geocoding the student location
    var mediaURL : String? //Description: the URL provided by the student
    fileprivate var _latitude : Double? //the actual stored value
    var createdAt : Date? //Description: the date when the student location was created
    var updatedAt : Date? //Description: the date when the student location was last updated
    var latitude : Double? { //Description: the latitude of the student location (ranges from -90 to 90)
        get {
            return _latitude
        }
        set(input) { //check for proper range
            //got a float, now check that value is within expected range:
            if input >= -90 && input <= 90 { //lattitude should be between -90 and 90, inclusive
                //print("Processing object with latitude: " + String(inboundObject))
                _latitude = input
            } else {//lattitude was out of bounds for Earthly comprehension
                //not many choices here, so will silently accept, and send the pin to the north pole! (This likely clearly indicates a problem to the user)
                _latitude = 90
                print("WARNING: Attempted to set Latitude to a value out of range.  Longitude has been set to: " + String(describing: self.latitude))
            }
        }
    }
    fileprivate var _longitude : Double? //actual value of longitude
    var longitude : Double? {//Description: the longitude of the student location (ranges from -180 to 180)
        get {
            return _longitude
        }
        set(input) { //check for proper range
            //got a float, now check that value is within expected range:
            if input >= -180 && input <= 180 { //lattitude should be between -180 and 180, inclusive
                //print("Processing object with latitude: " + String(inboundObject))
                _longitude = input
            } else {//lattitude was out of bounds for Earthly comprehension
                //not many choices here, so will silently accept, and send the pin to the Pacifc Ocean! (This could indicate a problem to the user)
                _longitude = 180
                print("WARNING: Attempted to set Longitude to a value out of range.  Longitude has been set to: " + String(describing: self.longitude))
            }
        }
    }
    
    //http://userguide.icu-project.org/formatparse/datetime
    let dateFormatter = DateFormatter()
    let dateFormat = "y-MM-dd'T'HH:mm:ss.SSS'Z'"
    //http://stackoverflow.com/questions/35539929/time-zone-in-swift-nsdate
    let timeZone = TimeZone(abbreviation: "GMT")
    
    /********************************************/
    /******************* Error Checking Properties **************/
    /********************************************/
    // MARK: Error Checking Properties
    /// A Set that contains the JSON keys expected from the server.  Used to check input and check for errors or unexpected input
    let expectedKeys : Set<String> = ["objectId", "uniqueKey", "firstName", "lastName", "mapString", "mediaURL", "latitude", "longitude", "createdAt", "updatedAt"]
    
    // Error Cases
    /*
     *  Used to throw errors
     */
    enum StudentInformationKeyError: Error {
        case badInputKeys(keys: [String]) //couldn't convert incoming dictionary keys to a set of Strings
        case inputMismatchKeys(keys: Set<String>) //incoming keys don't match expected keys
    }
    enum StudentInformationAssignmentError: Error {
        case badInputValues(property: String)
        case inputValueOutOfExpectedRange(expected: String, actual: Double)
    }
  
    /********************************************/
    /******************* Initialization **************/
    /********************************************/
    // MARK: - Initialization Options
    /*
     *  Can init with fromDataSet (recommended) or without any parameters
     */
    // mechanism to return as nil: http://stackoverflow.com/questions/26495586/best-practice-to-implement-a-failable-initializer-in-swift
    init?(fromDataSet data: [String:AnyObject]) {
        //print("\nAttempting to initialize StudentInformation Object from data set")
        
        //try to stuff the data into the properties of this instance, or return nil if it doesn't work
        //check the keys first
        do {
            try checkInputKeys(data)
        } catch StudentInformationKeyError.badInputKeys (let keys){
            print("\nSTUDENT INFORMATION ERROR: Data appears to be malformed. BadInputKeys:")
            print(keys)
            return nil
        } catch StudentInformationKeyError.inputMismatchKeys(let keys) {
            print("\nSTUDENT INFORMATION ERROR: InputMismatchKeys. Data appears to be malformed. These keys: ")
            print(keys)
            print("Do not match the expected keys: ")
            print(expectedKeys)
            return nil
        } catch {
            print("\nSTUDENT INFORMATION ERROR: Unknown error when calling checkInputKeys")
            return nil
        }
        
        //keys look good, now try to assign the values to the struct
        do {
            try attemptToAssignValues(data)
            //print("Successfully initialized a StudentInformation object\n")
        } catch StudentInformationAssignmentError.badInputValues(let propertyName) {
            print("\nSTUDENT INFORMATION ERROR: StudentInformationAssignmentError:")
            print(propertyName)
            return nil
        } catch StudentInformationAssignmentError.inputValueOutOfExpectedRange(let expected, let actual) {
            print("\nSTUDENT INFORMATION ERROR: A value was out of the expected range when calling attemptToAssignValues.  Expected: \"" + expected + "\" Actual: " + String(actual))
            return nil
        }catch {
            print("\nSTUDENT INFORMATION ERROR: Unknown error when calling attemptToAssignValues")
            return nil
        }
    }
    
    //init withiout a data set
    init() {
        //placeholder to allow struct to be initialized without input parameters
    }
    
    /********************************************/
    /******************* Input Checking **************/
    /********************************************/
    // MARK: - Input Checking
    /*
     *  Called during init to ensure data meets all validation requirements
     */
    
    /**
     Verifies that the keys input match the expected keys
     
     - Parameters:
         - data: a `[String:AnyObject]` containing key-value pairs that match `expectedKeys`
     
     - Returns:
         - True: if keys match
     
     - Throws: 
        - `StudentInformationKeyError.BadInputKeys` if input keys can't be made into a set
        - `StudentInformationKeyError.InputMismatchKeys` if input keys don't match `expectedKeys`
     */
    func checkInputKeys(_ data: [String:AnyObject]) throws -> Bool {
        //guard check one: Put the incoming keys into a set
        
        let keysToCheck = [String](data.keys) as? [String]
        //print("About to check these keys against expected: " + String(keysToCheck))
        //check to see if incoming keys can be placed into a set of strings
        guard let incomingKeys : Set<String> = keysToCheck.map(Set.init) else {
            throw StudentInformationKeyError.badInputKeys(keys: [String](data.keys))
        }
        
        //compare the new set with the expectedKeys
        guard incomingKeys == self.expectedKeys else {
            throw StudentInformationKeyError.inputMismatchKeys(keys: incomingKeys)
        }
        
        //print("The following sets appear to match: ")
        //print(self.expectedKeys)
        //print(keysToCheck!)
        
        //Keys match
        return true
    }
    
    /**
     Attempts to take a `[String:AnyObject]` and assign it to all of the properties of this struct
     
     - Parameters:
         - data: a `[String:AnyObject]` containing key-value pairs that match `expectedKeys`
     
     - Returns:
         - True: if all values are assigned successfully
     
     - Throws:
         - `StudentInformationAssignmentError.BadInputValues` if input doesn't have a key in the `expectedKeys` Set
         - `StudentInformationAssignmentError.inputValueOutOfExpectedRange` if input value at a key that has an expected range is out of range
     */
    mutating func attemptToAssignValues(_ data: [String:AnyObject]) throws -> Bool {
        
        //go through each item and attempt to assign it to the struct
        //print("\nAbout to assign values from the following object: ")
        //print(data)
        // ObjectID
        if let inboundObject = data["objectId"] as? String {
            //print("Processing object with id: " + inboundObject)
            self.objectID = inboundObject
        } else {
            throw StudentInformationAssignmentError.badInputValues(property: "objectId")
        }
        
        // uniqueKey
        if let inboundObject = data["uniqueKey"] as? String {
            //print("Processing object with uniquekey: " + inboundObject)
            self.uniqueKey = inboundObject
        } else {
            throw StudentInformationAssignmentError.badInputValues(property: "uniqueKey")
        }
        
        // firstName
        if let inboundObject = data["firstName"] as? String {
            //print("Processing object with firstname: " + inboundObject)
            self.firstName = inboundObject
        } else {
            throw StudentInformationAssignmentError.badInputValues(property: "firstName")
        }
        
        // lastName
        if let inboundObject = data["lastName"] as? String {
            //print("Processing object with lastName: " + inboundObject)
            self.lastName = inboundObject
        } else {
            throw StudentInformationAssignmentError.badInputValues(property: "lastName")
        }
        
        // mapString
        if let inboundObject = data["mapString"] as? String {
            //print("Processing object with mapString: " + inboundObject)
            self.mapString = inboundObject
        } else {
            throw StudentInformationAssignmentError.badInputValues(property: "mapString")
        }
        
        // mediaURL
        if let inboundObject = data["mediaURL"] as? String {
            //print("Processing object with mediaURL: " + inboundObject)
            self.mediaURL = inboundObject
        } else {
            throw StudentInformationAssignmentError.badInputValues(property: "mediaURL")
        }
        
        // latitude
        if let inboundObject = data["latitude"] as? Double {
            //print("Processing object with latitude: " + String(inboundObject))
            self.latitude = inboundObject
            //check that value was accepted
            if self.latitude != inboundObject {
                //value was not set properly
                throw StudentInformationAssignmentError.inputValueOutOfExpectedRange(expected: "Between -90 and 90, inclusive", actual: inboundObject)
            }
        } else {
            throw StudentInformationAssignmentError.badInputValues(property: "latitude")
        }
        
        // longitude
        if let inboundObject = data["longitude"] as? Double {
            //print("Processing object with latitude: " + String(inboundObject))
            self.longitude = inboundObject
            //check that value was accepted
            if self.longitude != inboundObject {
                //value was not set properly
                throw StudentInformationAssignmentError.inputValueOutOfExpectedRange(expected: "Between -180 and 180, inclusive", actual: inboundObject)
            }
        } else {
            throw StudentInformationAssignmentError.badInputValues(property: "longitude")
        }
        
        
        // createdAt
        if let inboundObject = self.stringToDate(inboundString: (data["createdAt"] as? String)!) {
            //print("Processing object with createdAt: " + String(inboundObject))
            self.createdAt = inboundObject
        } else {
            throw StudentInformationAssignmentError.badInputValues(property: "createdAt")
        }
        
        // updatedAt
        if let inboundObject = self.stringToDate(inboundString: (data["updatedAt"] as? String)!){
            //print("Processing object with updatedAt: " + String(inboundObject))
            self.updatedAt = inboundObject
        } else {
            throw StudentInformationAssignmentError.badInputValues(property: "updatedAt")
        }
        
        //all values assigned successfully
        return true
    } //end of attemptToAssignValues
    
    func stringToDate(inboundString:String) -> Date? {
        //date formating from http://stackoverflow.com/questions/24777496/how-can-i-convert-string-date-to-nsdate
        self.dateFormatter.dateFormat = self.dateFormat
        self.dateFormatter.timeZone = self.timeZone
        
        // createdAt
        if let dateObject = self.dateFormatter.date(from: (inboundString)) {
            //print("Processing object with createdAt: " + String(inboundObject))
            return dateObject
        } else {
            return nil
        }
    }

} //end of struct StudentInformation


//A gift from Xcode upgrade to swift 3
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l >= r
    default:
        return !(lhs < rhs)
    }
}

fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l <= r
    default:
        return !(rhs < lhs)
    }
}
