//
//  UdacityConstants.swift
//  OnTheMap
//
//  Derrived from work Created by Jarrod Parkes on 2/11/15.
//  Copyright (c) 2015 Jarrod Parkes. All rights reserved.
//
//  Further devlopment by Jacob Foster Davis in August - September 2016

// MARK: - UdacityClient (Constants)

extension UdacityClient {
    
    // MARK: Constants
    struct Constants {
        
        // MARK: API Key
        static let ApiKey : String = Secrets.UdacityAPIKey
                        
        // MARK: URLs
        static let ApiScheme = "https"
        static let ApiHost = "www.udacity.com"
        static let ApiPath = "/api"
        static let AuthorizationURL : String = "https://www.udacity.com/api/session"
    }
    
    // MARK: Methods
    struct Methods {
        
        // MARK: Authentication
        static let AuthenticationSessionNew = "/session"
        
        // User Data
        static let PublicUserData = "/users/{user_id}"
        
        // Log Out
        static let DeleteSession = "/session"
        
    }
    
    // MARK: URL Keys
    struct URLKeys {
        static let UserID = "user_id"
    }
    
    // MARK: JSON Body Keys
    struct JSONBodyKeys {
        struct Udacity {
            static let Udacity = "udacity" //udacity - (Dictionary) a dictionary containing a username/password pair used for authentication
            static let Username = "username" //username - (String) the username (email) for a Udacity student
            static let Password = "password" //password - (String) the password for a Udacity student
        }
    }

    // MARK: JSON Response Keys
    struct JSONResponseKeys {
      
        // MARK: General
        static let StatusMessage = "status_message"
        static let StatusCode = "status_code"
        
        // MARK: Authorization
        //static let SessionID = "session_id"
        
        struct Session {
            static let Session = "session"
            static let ID = "id"
            static let Expiration = "expiration" //a date object
        }
        
        // MARK: Account
        //static let UserID = "id"
        
        struct Account {
            static let Account = "account"
            static let Registered = "registered" //a bool
            static let Key = "key"
        }
        
        // MARK: User Data
        /*
         *  Public user data
         */
        
        struct User {
            static let User = "user"
            static let LastName = "last_name"
            static let FirstName = "first_name"
            static let NickName = "nickname"
            static let Key = "key"
            static let ImageURL = "_image_url"
        }
        
    }
}
