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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //subscribe to keyboard notifications
        self.subscribeToKeyboardNotifications()
        
        //color crazy
        configureBackground()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.unsubscribeFromKeyboardNotifications()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        debugTextLabel.text = ""
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
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
    
    @IBAction func passwordTextFieldPrimaryActionTriggered(_ sender: AnyObject) {
        print("Primary action of password field triggered")
        loginPressed(sender)
    }
    @IBAction func passwordTextFieldEditingDidEnd(_ sender: AnyObject) {
        print("passwordTextFieldEditingDidEnd triggered")
        loginPressed(sender)
    }
    
    @IBAction func loginPressed(_ sender: AnyObject) {
        startActivityIndicator()
        
        GCDBlackBox.runNetworkFunctionInBackground {
            UdacityClient.sharedInstance.authenticateWithViewController(self.usernameTextField.text!, password: self.passwordTextField.text!, hostViewController: self) { (success, error) in
                GCDBlackBox.performUIUpdatesOnMain {
                    self.stopActivityIndicator()
                    if success {
                        //set the userID in the shared UdacityUserInfo object
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.UdacityUserInfo.userID = UdacityClient.sharedInstance.userID!
                        
                        self.completeLogin()
                        //self.displayError("Login was successful!")
                        
                    } else {
                        self.displayError(error)
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
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil { // Handle error...
                print("Parse test failed")
                return
            }
            //print(NSString(data: data!, encoding: String.Encoding.utf8))
        }
        task.resume()
    }
    
    /******************************************************/
    /******************* Log In **************/
    /******************************************************/
    //MARK: - Log In
    fileprivate func completeLogin() {
        debugTextLabel.text = ""
        let controller = storyboard!.instantiateViewController(withIdentifier: "OTMNavigationController") as! UINavigationController
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
            //print("frame origin is 0")
            if let firstResponder = getFirstResponder() {
                print("Got a first responder.  y value is ")
                
                print(firstResponder.frame.origin.y)
                print(getKeyboardHeight(notification))
                
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
    
    fileprivate func displayError(_ error: NSError?) {
        if let error = error {
            var errorPrefix = ""
            switch error.code {
            case 1:
                errorPrefix = "Unable to Connect"
            case 2:
                errorPrefix = "Bad Username/Password"
            case 3:
                errorPrefix = "No Data from Server"
            case 4:
                errorPrefix = "Unexpected Data from Server"
            default:
                errorPrefix = "Unknown Error"
            }
            
            let errorString = error.userInfo[NSLocalizedDescriptionKey] as! String
            ErrorHandler.alertUser(self, alertTitle: errorPrefix, alertMessage: errorString)
        }
    }
    
    fileprivate func configureBackground() {
        
        let backgroundGradient = CAGradientLayer()
//        let colorTop = UIColor(red: 0.345, green: 0.839, blue: 0.988, alpha: 1.0).cgColor
//        let colorBottom = UIColor(red: 0.023, green: 0.569, blue: 0.910, alpha: 1.0).cgColor
        
        let colorTop = loginButton.getRandoColor().cgColor
        let colorBottom = loginButton.getRandoColor().cgColor
        
        backgroundGradient.colors = [colorTop, colorBottom]
        backgroundGradient.locations = [0.0, 1.0]
        backgroundGradient.frame = view.frame
        view.layer.insertSublayer(backgroundGradient, at: 0)
    }
}
