//
//  UdacityConvenience.swift
//  TheMovieManager
//
//  Created by Jarrod Parkes on 2/11/15.
//  Copyright (c) 2015 Jarrod Parkes. All rights reserved.
//

import UIKit
import Foundation

// MARK: - UdacityClient (Convenient Resource Methods)

extension UdacityClient {
    
    // MARK: Authentication (GET) Methods
    /*
        Steps for Authentication...
        https://www.themoviedb.org/documentation/api/sessions
    
        Step 1: Create a new request token
        Step 2a: Ask the user for permission via the website
        Step 3: Create a session ID
        Bonus Step: Go ahead and get the user id 😄!
    */
    func authenticateWithViewController(username: String, password : String, hostViewController: UIViewController, completionHandlerForAuth: (success: Bool, errorString: String?) -> Void) {
        
        // chain completion handlers for each request so that they run one after the other
        //getRequestToken() { (success, requestToken, errorString) in
            
        //    if success {
                
                // success! we have the requestToken!
                //self.requestToken = requestToken
                
                //self.loginWithToken(requestToken, hostViewController: hostViewController) { (success, errorString) in
        
                    //if success {
                        self.getSessionID(username, password: password) { (success, sessionID, errorString) in
                            
                            if success {
                                
                                // success! we have the sessionID!
                                self.sessionID = sessionID
                                print("Session ID is: " + (sessionID)!)
//                                self.getUserID() { (success, userID, errorString) in
//                                    
//                                    if success {
//                                        
//                                        if let userID = userID {
//                                            
//                                            // and the userID 😄!
//                                            self.userID = userID
//                                        }
//                                    }
//                                    
                                   completionHandlerForAuth(success: success, errorString: errorString)
//                                }
                            } else {
                                completionHandlerForAuth(success: success, errorString: errorString)
                            }
                        }
                    //} else {
                      //  completionHandlerForAuth(success: success, errorString: errorString)
                    //}
                //}
            //} else {
            //    completionHandlerForAuth(success: success, errorString: errorString)
            //}
     //   }
    }
    
//    private func getRequestToken(completionHandlerForToken: (success: Bool, requestToken: String?, errorString: String?) -> Void) {
//        
//        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
//        let parameters = [String:AnyObject]()
//        
//        /* 2. Make the request */
//        taskForGETMethod(Methods.AuthenticationTokenNew, parameters: parameters) { (results, error) in
//            
//            /* 3. Send the desired value(s) to completion handler */
//            if let error = error {
//                print(error)
//                completionHandlerForToken(success: false, requestToken: nil, errorString: "Login Failed (Request Token).")
//            } else {
//                if let requestToken = results[UdacityClient.JSONResponseKeys.RequestToken] as? String {
//                    completionHandlerForToken(success: true, requestToken: requestToken, errorString: nil)
//                } else {
//                    print("Could not find \(UdacityClient.JSONResponseKeys.RequestToken) in \(results)")
//                    completionHandlerForToken(success: false, requestToken: nil, errorString: "Login Failed (Request Token).")
//                }
//            }
//        }
//    }
//    
//    /* This function opens a UdacityAuthViewController to handle Step 2a of the auth flow */
//    private func loginWithToken(requestToken: String?, hostViewController: UIViewController, completionHandlerForLogin: (success: Bool, errorString: String?) -> Void) {
//        
//        let authorizationURL = NSURL(string: "\(UdacityClient.Constants.AuthorizationURL)\(requestToken!)")
//        let request = NSURLRequest(URL: authorizationURL!)
//        let webAuthViewController = hostViewController.storyboard!.instantiateViewControllerWithIdentifier("UdacityAuthViewController") as! UdacityAuthViewController
//        webAuthViewController.urlRequest = request
//        webAuthViewController.requestToken = requestToken
//        webAuthViewController.completionHandlerForView = completionHandlerForLogin
//        
//        let webAuthNavigationController = UINavigationController()
//        webAuthNavigationController.pushViewController(webAuthViewController, animated: false)
//        
//        performUIUpdatesOnMain {
//            hostViewController.presentViewController(webAuthNavigationController, animated: true, completion: nil)
//        }
//    }
    
    private func getSessionID(username : String, password: String, completionHandlerForSession: (success: Bool, sessionID: String?, errorString: String?) -> Void) {
        
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
                completionHandlerForSession(success: false, sessionID: nil, errorString: "Login Failed (Session ID).")
            } else {
                //json should have returned a [[String:AnyObject]]
                if let sessionID = results[UdacityClient.JSONResponseKeys.Session.Session]?![UdacityClient.JSONResponseKeys.Session.ID] as? String {
                    completionHandlerForSession(success: true, sessionID: sessionID, errorString: nil)
                } else {
                    print("Could not find \(UdacityClient.JSONResponseKeys.Session.Session) in \(results)")
                    completionHandlerForSession(success: false, sessionID: nil, errorString: "Login Failed (Session ID).")
                }
            }
        }
    }
    
//    private func getUserID(completionHandlerForUserID: (success: Bool, userID: Int?, errorString: String?) -> Void) {
//        
//        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
//        let parameters = [UdacityClient.ParameterKeys.SessionID: UdacityClient.sharedInstance().sessionID!]
//        
//        /* 2. Make the request */
//        taskForGETMethod(Methods.Account, parameters: parameters) { (results, error) in
//            
//            /* 3. Send the desired value(s) to completion handler */
//            if let error = error {
//                print(error)
//                completionHandlerForUserID(success: false, userID: nil, errorString: "Login Failed (User ID).")
//            } else {
//                if let userID = results[UdacityClient.JSONResponseKeys.UserID] as? Int {
//                    completionHandlerForUserID(success: true, userID: userID, errorString: nil)
//                } else {
//                    print("Could not find \(UdacityClient.JSONResponseKeys.UserID) in \(results)")
//                    completionHandlerForUserID(success: false, userID: nil, errorString: "Login Failed (User ID).")
//                }
//            }
//        }
//    }
    
    // MARK: GET Convenience Methods
    
//    func getFavoriteMovies(completionHandlerForFavMovies: (result: [UdacityMovie]?, error: NSError?) -> Void) {
//        
//        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
//        let parameters = [UdacityClient.ParameterKeys.SessionID: UdacityClient.sharedInstance().sessionID!]
//        var mutableMethod: String = Methods.AccountIDFavoriteMovies
//        mutableMethod = subtituteKeyInMethod(mutableMethod, key: UdacityClient.URLKeys.UserID, value: String(UdacityClient.sharedInstance().userID!))!
//        
//        /* 2. Make the request */
//        taskForGETMethod(mutableMethod, parameters: parameters) { (results, error) in
//            
//            /* 3. Send the desired value(s) to completion handler */
//            if let error = error {
//                completionHandlerForFavMovies(result: nil, error: error)
//            } else {
//                
//                if let results = results[UdacityClient.JSONResponseKeys.MovieResults] as? [[String:AnyObject]] {
//                    
//                    let movies = UdacityMovie.moviesFromResults(results)
//                    completionHandlerForFavMovies(result: movies, error: nil)
//                } else {
//                    completionHandlerForFavMovies(result: nil, error: NSError(domain: "getFavoriteMovies parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getFavoriteMovies"]))
//                }
//            }
//        }
//    }
//
//    func getWatchlistMovies(completionHandlerForWatchlist: (result: [UdacityMovie]?, error: NSError?) -> Void) {
//        
//        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
//        let parameters = [UdacityClient.ParameterKeys.SessionID: UdacityClient.sharedInstance().sessionID!]
//        var mutableMethod: String = Methods.AccountIDWatchlistMovies
//        mutableMethod = subtituteKeyInMethod(mutableMethod, key: UdacityClient.URLKeys.UserID, value: String(UdacityClient.sharedInstance().userID!))!
//        
//        /* 2. Make the request */
//        taskForGETMethod(mutableMethod, parameters: parameters) { (results, error) in
//            
//            /* 3. Send the desired value(s) to completion handler */
//            if let error = error {
//                completionHandlerForWatchlist(result: nil, error: error)
//            } else {
//                
//                if let results = results[UdacityClient.JSONResponseKeys.MovieResults] as? [[String:AnyObject]] {
//                    
//                    let movies = UdacityMovie.moviesFromResults(results)
//                    completionHandlerForWatchlist(result: movies, error: nil)
//                } else {
//                    completionHandlerForWatchlist(result: nil, error: NSError(domain: "getWatchlistMovies parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getWatchlistMovies"]))
//                }
//            }
//        }
//    }
//    
//    func getMoviesForSearchString(searchString: String, completionHandlerForMovies: (result: [UdacityMovie]?, error: NSError?) -> Void) -> NSURLSessionDataTask? {
//        
//        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
//        let parameters = [UdacityClient.ParameterKeys.Query: searchString]
//        
//        /* 2. Make the request */
//        let task = taskForGETMethod(Methods.SearchMovie, parameters: parameters) { (results, error) in
//            
//            /* 3. Send the desired value(s) to completion handler */
//            if let error = error {
//                completionHandlerForMovies(result: nil, error: error)
//            } else {
//                
//                if let results = results[UdacityClient.JSONResponseKeys.MovieResults] as? [[String:AnyObject]] {
//                    
//                    let movies = UdacityMovie.moviesFromResults(results)
//                    completionHandlerForMovies(result: movies, error: nil)
//                } else {
//                    completionHandlerForMovies(result: nil, error: NSError(domain: "getMoviesForSearchString parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getMoviesForSearchString"]))
//                }
//            }
//        }
//        
//        return task
//    }
//    
//    func getConfig(completionHandlerForConfig: (didSucceed: Bool, error: NSError?) -> Void) {
//        
//        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
//        let parameters = [String:AnyObject]()
//        
//        /* 2. Make the request */
//        taskForGETMethod(Methods.Config, parameters: parameters) { (results, error) in
//            
//            /* 3. Send the desired value(s) to completion handler */
//            if let error = error {
//                completionHandlerForConfig(didSucceed: false, error: error)
//            } else if let newConfig = UdacityConfig(dictionary: results as! [String:AnyObject]) {
//                self.config = newConfig
//                completionHandlerForConfig(didSucceed: true, error: nil)
//            } else {
//                completionHandlerForConfig(didSucceed: false, error: NSError(domain: "getConfig parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getConfig"]))
//            }
//        }
//    }
//
//    // MARK: POST Convenience Methods
//    
//    func postToFavorites(movie: UdacityMovie, favorite: Bool, completionHandlerForFavorite: (result: Int?, error: NSError?) -> Void)  {
//        
//        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
//        let parameters = [UdacityClient.ParameterKeys.SessionID : UdacityClient.sharedInstance().sessionID!]
//        var mutableMethod: String = Methods.AccountIDFavorite
//        mutableMethod = subtituteKeyInMethod(mutableMethod, key: UdacityClient.URLKeys.UserID, value: String(UdacityClient.sharedInstance().userID!))!
//        let jsonBody = "{\"\(UdacityClient.JSONBodyKeys.MediaType)\": \"movie\",\"\(UdacityClient.JSONBodyKeys.MediaID)\": \"\(movie.id)\",\"\(UdacityClient.JSONBodyKeys.Favorite)\": \(favorite)}"
//    
//        /* 2. Make the request */
//        taskForPOSTMethod(mutableMethod, parameters: parameters, jsonBody: jsonBody) { (results, error) in
//            
//            /* 3. Send the desired value(s) to completion handler */
//            if let error = error {
//                completionHandlerForFavorite(result: nil, error: error)
//            } else {
//                if let results = results[UdacityClient.JSONResponseKeys.StatusCode] as? Int {
//                    completionHandlerForFavorite(result: results, error: nil)
//                } else {
//                    completionHandlerForFavorite(result: nil, error: NSError(domain: "postToFavoritesList parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse postToFavoritesList"]))
//                }
//            }
//        }
//    }
//    
//    func postToWatchlist(movie: UdacityMovie, watchlist: Bool, completionHandlerForWatchlist: (result: Int?, error: NSError?) -> Void) {
//        
//        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
//        let parameters = [UdacityClient.ParameterKeys.SessionID : UdacityClient.sharedInstance().sessionID!]
//        var mutableMethod: String = Methods.AccountIDWatchlist
//        mutableMethod = subtituteKeyInMethod(mutableMethod, key: UdacityClient.URLKeys.UserID, value: String(UdacityClient.sharedInstance().userID!))!
//        let jsonBody = "{\"\(UdacityClient.JSONBodyKeys.MediaType)\": \"movie\",\"\(UdacityClient.JSONBodyKeys.MediaID)\": \"\(movie.id)\",\"\(UdacityClient.JSONBodyKeys.Watchlist)\": \(watchlist)}"
//        
//        /* 2. Make the request */
//        taskForPOSTMethod(mutableMethod, parameters: parameters, jsonBody: jsonBody) { (results, error) in
//            
//            /* 3. Send the desired value(s) to completion handler */
//            if let error = error {
//                completionHandlerForWatchlist(result: nil, error: error)
//            } else {
//                if let results = results[UdacityClient.JSONResponseKeys.StatusCode] as? Int {
//                    completionHandlerForWatchlist(result: results, error: nil)
//                } else {
//                    completionHandlerForWatchlist(result: nil, error: NSError(domain: "postToWatchlist parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse postToWatchlist"]))
//                }
//            }
//        }
//    }
}