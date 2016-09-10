//
//  LoginViewController.swift
//  OnTheMap
//
//  Derrived from work Created by Jarrod Parkes on 2/11/15.
//  Copyright (c) 2015 Jarrod Parkes. All rights reserved.
//
//  Further devlopment by Jacob Foster Davis in August - September 2016

import UIKit

// MARK: - LoginViewController: UIViewController

class LoginViewController: UIViewController {

    /******************************************************/
    /******************* Properties **************/
    /******************************************************/

    @IBOutlet weak var debugTextLabel: UILabel!
    @IBOutlet weak var loginButton: BorderedButton!
    //@IBOutlet weak var parseTestButton: BorderedButton!

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var session: NSURLSession!
    
    /** Spinning wheel to show user that network activity is in progress */
    var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    
    /// Text Field delegate
    let textFieldDelegate = LoginTextFieldDelegate()
    
    /******************************************************/
    /******************* Shared Model **************/
    /******************************************************/
    var StudentInformations: [StudentInformation]{
        return (UIApplication.sharedApplication().delegate as! AppDelegate).StudentInformations
    }

    /******************************************************/
    /******************* Life Cycle **************/
    /******************************************************/
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        
        //http://sourcefreeze.com/uiactivityindicatorview-example-using-swift-in-ios/
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        activityIndicator.center = self.view.center
        view.addSubview(activityIndicator)
        
        super.viewDidLoad()
        
        //set the delegates
        self.usernameTextField.delegate = textFieldDelegate
        self.passwordTextField.delegate = textFieldDelegate
        
        configureBackground()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //subscribe to keyboard notifications
        self.subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.unsubscribeFromKeyboardNotifications()
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
        //A test to check the StudentInformation struct without having to log in
        //        for info in testStudents {
//            if let test = StudentInformation(fromDataSet: info){
//                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//                appDelegate.StudentInformations.append(test)
//            }
//        }
//        print("There are " + String(StudentInformations.count) + " Information Records stored.  Test Complete.")
        
    }
    
    
    /******************************************************/
    /******************* Activity Indicator **************/
    /******************************************************/
    //MARK: - Activity Indicator
    
    func startActivityIndicator() {
        activityIndicator.startAnimating()
    }
    
    func stopActivityIndicator() {
        activityIndicator.stopAnimating()
    }
    
    /******************************************************/
    /******************* Actions **************/
    /******************************************************/
    //MARK: - Actions
    
    @IBAction func loginPressed(sender: AnyObject) {
        startActivityIndicator()
        
        GCDBlackBox.runNetworkFunctionInBackground {
            UdacityClient.sharedInstance.authenticateWithViewController(self.usernameTextField.text!, password: self.passwordTextField.text!, hostViewController: self) { (success, errorString) in
                GCDBlackBox.performUIUpdatesOnMain {
                    self.stopActivityIndicator()
                    if success {
                        self.completeLogin()
                        self.displayError("Login was successful!")
                    } else {
                        self.displayError(errorString)
                    }
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
    
    /******************************************************/
    /******************* Log In **************/
    /******************************************************/
    //MARK: - Log In
    private func completeLogin() {
        debugTextLabel.text = ""
        let controller = storyboard!.instantiateViewControllerWithIdentifier("ManagerNavigationController") as! UINavigationController
        presentViewController(controller, animated: true, completion: nil)
    }
    
    /******************************************************/
    /******************* Keyboard **************/
    /******************************************************/
    //MARK: - Keyboard
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as!NSValue
        return keyboardSize.CGRectValue().height
    }
    
    func keyboardWillShow(notification: NSNotification) {
        //check that the view is not already moved up for the keyboard.  if it isn't, then move the view if the keyboard would cover it.     
        if view.frame.origin.y == 0 {
           // check that the first responder is below the keyboard
            print("frame origin is 0")
            if let firstResponder = getFirstResponder() {
                print("Got a first responder.  y value is ")
                if firstResponder.frame.origin.y >  getKeyboardHeight(notification) {
                    view.frame.origin.y = -(getKeyboardHeight(notification))
                }
            }
        }
    } //end of keyboardWillShow
    
    func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y = 0
    }
    
    func getFirstResponder() -> UIView? {
        //this code adapted from http://stackoverflow.com/questions/12173802/trying-to-find-which-text-field-is-active-ios
        for view in self.view.subviews {
            print ("Checking " + String(view.description))
            
            if view.isFirstResponder() {
                return view
            }
            
        }
        //there is no first responder, return nil
        return nil
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