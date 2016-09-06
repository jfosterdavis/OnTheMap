//
//  UdacityConstants.swift
//  TheMovieManager
//
//  Created by Jarrod Parkes on 2/11/15.
//  Copyright (c) 2015 Jarrod Parkes. All rights reserved.
//

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
        
    }

    // MARK: URL Keys
    // none for this API
    
    // MARK: Parameter Keys
    // none for this API
    
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
        
        
    }
}