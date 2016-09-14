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
    
    var session: URLSession!
    
    /** Spinning wheel to show user that network activity is in progress */
    var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    
    /// Text Field delegate
    let textFieldDelegate = LoginTextFieldDelegate()
    
    /******************************************************/
    /******************* Shared Model **************/
    /******************************************************/
    var StudentInformations: [StudentInformation]{
        return (UIApplication.shared.delegate as! AppDelegate).StudentInformations
    }
    
    var UdacityUserInfo: UdacityUserInformation {
        return (UIApplication.shared.delegate as! AppDelegate).UdacityUserInfo
    }

    /******************************************************/
    /******************* Life Cycle **************/
    /******************************************************/
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        
        //http://sourcefreeze.com/uiactivityindicatorview-example-using-swift-in-ios/
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        activityIndicator.center = self.view.center
        view.addSubview(activityIndicator)
        
        super.viewDidLoad()
        
        //set the delegates
        self.usernameTextField.delegate = textFieldDelegate
        self.passwordTextField.delegate = textFieldDelegate
        
        configureBackground()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //subscribe to keyboard notifications
        self.subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.unsubscribeFromKeyboardNotifications()
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
    
    @IBAction func loginPressed(_ sender: AnyObject) {
        startActivityIndicator()
        
        GCDBlackBox.runNetworkFunctionInBackground {
            UdacityClient.sharedInstance.authenticateWithViewController(self.usernameTextField.text!, password: self.passwordTextField.text!, hostViewController: self) { (success, errorString) in
                GCDBlackBox.performUIUpdatesOnMain {
                    self.stopActivityIndicator()
                    if success {
                        //set the userID in the shared UdacityUserInfo object
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.UdacityUserInfo.userID = UdacityClient.sharedInstance.userID!
                        
                        self.completeLogin()
                        self.displayError("Login was successful!")
                        
                    } else {
                        self.displayError(errorString)
                    }
                }
            }
        }
    }
    @IBAction func parseTestMessage(_ sender: AnyObject) {
        let request = NSMutableURLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
        request.addValue(Secrets.ParseAPIKey, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Secrets.ParseRESTAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            if error != nil { // Handle error...
                print("Parse test failed")
                return
            }
            print(NSString(data: data!, encoding: String.Encoding.utf8))
        }) 
        task.resume()
    }
    
    /******************************************************/
    /******************* Log In **************/
    /******************************************************/
    //MARK: - Log In
    fileprivate func completeLogin() {
        debugTextLabel.text = ""
        let controller = storyboard!.instantiateViewController(withIdentifier: "ManagerNavigationController") as! UINavigationController
        present(controller, animated: true, completion: nil)
    }
    
    /**
     fetches the userinfo from the Udacity Parse Server
     */
    fileprivate func getUserInfo() {
        
    }
    
    /******************************************************/
    /******************* Keyboard **************/
    /******************************************************/
    //MARK: - Keyboard
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = (notification as NSNotification).userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as!NSValue
        return keyboardSize.cgRectValue.height
    }
    
    func keyboardWillShow(_ notification: Notification) {
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
    
    func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0
    }
    
    func getFirstResponder() -> UIView? {
        //this code adapted from http://stackoverflow.com/questions/12173802/trying-to-find-which-text-field-is-active-ios
        for view in self.view.subviews {
            print ("Checking " + String(view.description))
            
            if view.isFirstResponder {
                return view
            }
            
        }
        //there is no first responder, return nil
        return nil
    }
    
}

// MARK: - LoginViewController (Configure UI)

extension LoginViewController {
    
    fileprivate func setUIEnabled(_ enabled: Bool) {
        loginButton.isEnabled = enabled
        debugTextLabel.isEnabled = enabled
        
        // adjust login button alpha
        if enabled {
            loginButton.alpha = 1.0
        } else {
            loginButton.alpha = 0.5
        }
    }
    
    fileprivate func displayError(_ errorString: String?) {
        if let errorString = errorString {
            debugTextLabel.text = errorString
        }
    }
    
    fileprivate func configureBackground() {
        let backgroundGradient = CAGradientLayer()
        let colorTop = UIColor(red: 0.345, green: 0.839, blue: 0.988, alpha: 1.0).cgColor
        let colorBottom = UIColor(red: 0.023, green: 0.569, blue: 0.910, alpha: 1.0).cgColor
        backgroundGradient.colors = [colorTop, colorBottom]
        backgroundGradient.locations = [0.0, 1.0]
        backgroundGradient.frame = view.frame
        view.layer.insertSublayer(backgroundGradient, at: 0)
    }
}
