//
//  LoginViewController.swift
//  TheMovieManager
//
//  Created by Jarrod Parkes on 2/26/15.
//  Copyright (c) 2015 Jarrod Parkes. All rights reserved.
//

import UIKit

// MARK: - LoginViewController: UIViewController

class LoginViewController: UIViewController {

    // MARK: Properties
    
    @IBOutlet weak var debugTextLabel: UILabel!
    @IBOutlet weak var loginButton: BorderedButton!
    @IBOutlet weak var parseTestButton: BorderedButton!

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var session: NSURLSession!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackground()
    }
    
    //Set a pointer to the sharedMemes
    var StudentInformations: [StudentInformation]{
        return (UIApplication.sharedApplication().delegate as! AppDelegate).StudentInformations
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewWillAppear(animated)
        debugTextLabel.text = ""
        
        //test struct
        let testStudents = [
            [
                "createdAt" : "2015-02-24T22:27:14.456Z",
                "firstName" : "Jessica",
                "lastName" : "Uelmen",
                "latitude" : 28.1461248,
                "longitude" : -82.75676799999999,
                "mapString" : "Tarpon Springs, FL",
                "mediaURL" : "www.linkedin.com/in/jessicauelmen/en",
                "objectId" : "kj18GEaWD8",
                "uniqueKey" : "872458750",
                "updatedAt" : "2015-03-09T22:07:09.593Z"
            ], [
                "createdAt" : "2015-02-24T22:35:30.639Z",
                "firstName" : "Gabrielle",
                "lastName" : "Miller-Messner",
                "latitude" : "35.1740471",
                "longitude" : -79.3922539,
                "mapString" : 5,
                "mediaURL" : "http://www.linkedin.com/pub/gabrielle-miller-messner/11/557/60/en",
                "objectId" : "8ZEuHF5uX8",
                "uniqueKey" : "2256298598",
                "updatedAt" : "2015-03-11T03:23:49.582Z"
            ], [
                "createdAt" : "2015-02-24T22:30:54.442Z",
                "firstName" : "Jason",
                "lastName" : "Schatz",
                "latitude" : 37.7617,
                "longitude" : -122.4216,
                "mapString" : "18th and Valencia, San Francisco, CA",
                "mediaURL" : "http://en.wikipedia.org/wiki/Swift_%28programming_language%29",
                "objectId" : "hiz0vOTmrL",
                "uniqueKey" : "2362758535",
                "updatedAt" : "2015-03-10T17:20:31.828Z"
            ], [
                "createdAt" : "2015-03-11T02:48:18.321Z",
                "firstName" : "Jarrod",
                "lastName" : "Parkes",
                "latitude" : 34.73037,
                "longitude" : -86.58611000000001,
                "mapString" : "Huntsville, Alabama",
                "mediaURL" : "https://linkedin.com/in/jarrodparkes",
                "objectId" : "CDHfAy8sdp",
                "uniqueKey" : "996618664",
                "updatedAt" : "2015-03-13T03:37:58.389Z"
            ]
        ]
        for info in testStudents {
            if let test = StudentInformation(fromDataSet: info){
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                appDelegate.StudentInformations.append(test)
            }
        }
        print("There are " + String(StudentInformations.count) + " Information Records stored.  Test Complete.")
        
    }
    
    // MARK: Actions
    
    @IBAction func loginPressed(sender: AnyObject) {
        UdacityClient.sharedInstance.authenticateWithViewController(usernameTextField.text!, password: passwordTextField.text!, hostViewController: self) { (success, errorString) in
            performUIUpdatesOnMain {
                if success {
                    self.completeLogin()
                    self.displayError("Login was successful!")
                } else {
                    self.displayError(errorString)
                }
            }
        }
    }
    @IBAction func parseTestMessage(sender: AnyObject) {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
        request.addValue(Secrets.ParseAPIKey, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Secrets.ParseRESTAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error...
                print("Parse test failed")
                return
            }
            print(NSString(data: data!, encoding: NSUTF8StringEncoding))
        }
        task.resume()
    }
    
    // MARK: Login
    
    private func completeLogin() {
        debugTextLabel.text = ""
        let controller = storyboard!.instantiateViewControllerWithIdentifier("ManagerNavigationController") as! UINavigationController
        presentViewController(controller, animated: true, completion: nil)
    }
}

// MARK: - LoginViewController (Configure UI)

extension LoginViewController {
    
    private func setUIEnabled(enabled: Bool) {
        loginButton.enabled = enabled
        debugTextLabel.enabled = enabled
        
        // adjust login button alpha
        if enabled {
            loginButton.alpha = 1.0
        } else {
            loginButton.alpha = 0.5
        }
    }
    
    private func displayError(errorString: String?) {
        if let errorString = errorString {
            debugTextLabel.text = errorString
        }
    }
    
    private func configureBackground() {
        let backgroundGradient = CAGradientLayer()
        let colorTop = UIColor(red: 0.345, green: 0.839, blue: 0.988, alpha: 1.0).CGColor
        let colorBottom = UIColor(red: 0.023, green: 0.569, blue: 0.910, alpha: 1.0).CGColor
        backgroundGradient.colors = [colorTop, colorBottom]
        backgroundGradient.locations = [0.0, 1.0]
        backgroundGradient.frame = view.frame
        view.layer.insertSublayer(backgroundGradient, atIndex: 0)
    }
}