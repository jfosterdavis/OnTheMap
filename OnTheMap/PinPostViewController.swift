//
//  PinPostViewController.swift
//  OnTheMap
//
//  Created by Jacob Foster Davis on 9/10/16.
//  Copyright © 2016 Udacity. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class PinPostViewController: UIViewController, MKMapViewDelegate {
    
    /******************************************************/
    /******************* Properties **************/
    /******************************************************/
    //MARK: - Properties
    var newPin : MKPointAnnotation?
    var newStudentInfo : StudentInformation?

    
    
    /******************************************************/
    /******************* Outlets **************/
    /******************************************************/
    //MARK: - Outlets
    
    //container views
    @IBOutlet weak var step1View: UIView!
    @IBOutlet weak var step2View: UIView!
    @IBOutlet weak var step2PromptContainer: UIView!
    @IBOutlet weak var miniMapContainer: UIView!
    @IBOutlet weak var step1PromptContainer: UIView!
    @IBOutlet weak var pinLocationCreatorContainer: UIView!
    
    //mapView
    @IBOutlet weak var miniMapView: MKMapView!
    
    //User Input
    @IBOutlet weak var step1LocationInput: UITextField!
    @IBOutlet weak var step2URLInput: UITextView!
    
    //buttons
    @IBOutlet var searchNavButton: UIBarButtonItem!
    @IBOutlet weak var cancelNavButton: UIBarButtonItem!
    @IBOutlet weak var pinItButton: BorderedButton!
    @IBOutlet weak var findAndMapButton: BorderedButton!
    
    
    /******************************************************/
    /******************* Error Checking **************/
    /******************************************************/
    //MARK: - Error Checking
    
    enum StudentInfoCreationError: ErrorType {
        case MissingObject() //Missing an object needed to create
    }
    
    /******************************************************/
    /******************* Life Cycle **************/
    /******************************************************/
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        miniMapView.delegate = self
        
        //initialize button states
        makeSearchNavBarButtonVisible(false)
        makePinItButtonEnabled(false)
        
        //set delegates
        step2URLInput.delegate = self
        
        //set up a new StudentInformation object
        setupNewStudentInfo()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.unsubscribeFromKeyboardNotifications()
    }
    
    /******************************************************/
    /******************* Actions **************/
    /******************************************************/
    //MARK: - Action
    
    
    @IBAction func searchAndTransition(sender: AnyObject){
        if let textToGeoCode = step1LocationInput.text {
            if !textToGeoCode.isEmpty {
                geocodeForward(textToGeoCode)
            } else {
                //text field was empty
                alertUser("Nothing to Search For", alertMessage: "Please enter the name of your location in the text box.")
            }
        } else {
            alertUser("Unknown Error", alertMessage: "Text box appears to not exist!")
        }
    } //end searchAndTransition
    
    @IBAction func searchNavButtonPressed(sender: AnyObject) {
        transitionToOtherStep()
    }
    
    @IBAction func cancelNavButtonPressed(sender: AnyObject) {
    }
    
    @IBAction func pinItButtonPressed(sender: BorderedButton!) {
        print("Pin It button pressed")
        //make sure text view is done editing
        step2URLInput.endEditing(true)
        
        //check that all data is input
        //set the mediaURL
        if !setNewStudentInfoURL(self.step2URLInput.text!){
            print("failed to set URL")
        }
        //set the coordinates
        if self.newPin !=  nil {
            print("About to try to set coordinates")
            setNewStudentInfoCoordinates(self.newPin!)
        } else {
            //TODO: handle case
            print("failed to set coordinates")
        }
        
        print("StudentIformation Object is ready to take: ")
        print(self.newStudentInfo)
        //Send this Pen to Parse
        //add it to the map
        //dismiss this view controller and zoom to user's pin
    }
    
    
    /******************************************************/
    /******************* Geocode Functions **************/
    /******************************************************/
    //MARK: - Geocoding
    
    /**
     Performs forward geocode with a given string
     
     - Parameters:
         - locationString: String that will attempt to geocode
     
     - Returns:
         - CLPlacemark: if the geocode attempt returned a result
         - nil: if error or no geocode was found
     */
    func geocodeForward(locationString: String) {
        let textToGeoCode = locationString
        let Geocoder = CLGeocoder()
        Geocoder.geocodeAddressString(textToGeoCode) { (placemarks, error) in
            if let placemarks = placemarks {
                print("Got the following placemarks")
                for placemark in placemarks {
                    print(placemark.location)
                }
                //set the newPin and plot it
                self.pinSetAndPlot(self.pinFromPlacemark(placemarks[0]))
                
                //set the new mapString
                self.setNewStudentInfoMapString(placemarks[0].name!)
                
                //transition
                self.transitionToOtherStep()
                
            } else {
                //didn't get any placemarks
                print("Error obtaining Placemark")
                print(error)
                //TODO: handle error
            }
        }
    } // end geocodeForward
    
    /******************************************************/
    /******************* Map Delegate **************/
    /******************************************************/
    //MARK: - Map Delegate
    
    // Here we create a view with a "right callout accessory view". You might choose to look into other
    // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
    // method in TableViewDataSource.
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "newPin"
        
        var pinView = miniMapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.redColor()
            //pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    /**
     This delegate method is implemented to respond to taps. It opens the system browser
     to the URL specified in the annotationViews subtitle property.
     */
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            if let toOpen = view.annotation?.subtitle! {
                app.openURL(NSURL(string: toOpen)!)
            } else {
                print("Failed to open view annotation")
            }
        }
    }
    
    /******************************************************/
    /******************* Pins **************/
    /******************************************************/
    //MARK: - Pins
    
    /**
     Plots the given Pin
     
     - Parameters:
         - annotation: A `MKPointAnnotation` object
     */
    func plotPin(annotation : MKPointAnnotation) {
        self.miniMapView.addAnnotation(annotation)
    }
    
    /**
     Takes a placemark and attempts to create a pin
     
     - Parameters:
         - placemark: The placemark used to create the pin
     
     - Returns: `MKAnnotation` (a pin)
     */
    func pinFromPlacemark(placemark : CLPlacemark) -> MKPointAnnotation {
        let aPin = MKPointAnnotation()
        
        //set lat and long
        aPin.coordinate.latitude = placemark.location!.coordinate.latitude
        aPin.coordinate.longitude = placemark.location!.coordinate.longitude
        
        //set title
        aPin.title = placemark.name
        
        return aPin
    } // end of pinFromPlacemark
    
    /**
     Takes a Pin and plots it on the miniMap
     
     - Parameters:
         - pinToPlot: The pin to plot
     */
    func pinSetAndPlot(pinToPlot : MKPointAnnotation) -> Void {
        //set the pin
        self.newPin = pinToPlot
        
        //plot the pin
        plotPin(self.newPin!)
        
    } // end of pinSetAndPlot
    
    /**
     Attempts to give the current newStudentInfo the given text as a URL
     
     - Parameters:
         - inputURL: the URL to give the newStudentInfo
     
     - Returns:
         - `true`: if successful
         - `false`: otherwise
     */
    
    /******************************************************/
    /******************* StudentInformation Object **************/
    /******************************************************/
    //MARK: - StudentInformation Object
    
    func setNewStudentInfoURL(inputURL : String!) -> Bool {
        print("setNewStudentInfoURL called")
        if self.newStudentInfo == nil {
            //the newStudentInfo is not initialized
            print("the newStudentInfo is not initialized")
            return false
        } else {
            //the newStudentInfo exists, set the value
            self.newStudentInfo!.mediaURL = inputURL!
            
            //check for success because the struct has input validation
            if self.newStudentInfo!.mediaURL == inputURL! {
                print("mediaURL set to: " + String(self.newStudentInfo!.mediaURL))
                return true
            } else {
                print("failed to set URL")
                return false
            }
        }
    } // end of setNewStudentInfoURL
    
    /**
     Attempts to give the current newStudentInfo the given Coordinates from the pin
     
     - Parameters:
         - inputPin: a MKPointAnnotation
     
     - Returns:
         - `true`: if successful
         - `false`: otherwise
     */
    func setNewStudentInfoCoordinates(inputPin : MKPointAnnotation) -> Bool {
        if self.newStudentInfo == nil {
            print("failed to set coordinates. self.newstudentinfo returned nil")
            //the newStudentInfo is not initialized
            return false
        } else {
            //the newStudentInfo exists, set the value
            self.newStudentInfo!.latitude = inputPin.coordinate.latitude
            self.newStudentInfo!.longitude = inputPin.coordinate.longitude
            
            //check for success because the struct has input validation
            if self.newStudentInfo!.latitude == inputPin.coordinate.latitude &&
            self.newStudentInfo!.longitude == inputPin.coordinate.longitude {
                print("latitude set to: " + String(self.newStudentInfo!.latitude))
                print("longitude set to: " + String(self.newStudentInfo!.longitude))
                return true
            } else {
                print("failed to set coordinates")
                print(inputPin)
                return false
            }
        }
    } // end of setNewStudentInfoCoordinates
    
    
    /**
     Attempts to give the current newStudentInfo the given mapString
     
     - Parameters:
         - inputMapString: a string from the user's search
     
     - Returns:
         - `true`: if successful
         - `false`: otherwise
     */
    func setNewStudentInfoMapString(inputMapString : String!) -> Bool {
        if self.newStudentInfo == nil {
            //the newStudentInfo is not initialized
            return false
        } else {
            //the newStudentInfo exists, set the value
            self.newStudentInfo!.mapString = inputMapString
            
            //check for success because the struct has input validation
            if self.newStudentInfo!.mapString == inputMapString  {
                print("Mapstring set to: " + String(self.newStudentInfo!.mapString))
                return true
            } else {
                print("failed to set MapString")
                return false
            }
        }
    } // end of setNewStudentInfoMapString
    
    /******************************************************/
    /******************* Housekeeping functions **************/
    /******************************************************/
    //MARK: - Housekeeping
    
    /**
     Recreates a fresh annotation for the `self.newPin` and sets it.
     
     - Returns: `self.newPin`, freshly instantiated
     */
    func cleanNewPin() -> MKPointAnnotation {
        self.newPin = MKPointAnnotation()
        return self.newPin!
    } // end of cleanNewPin
    
    /**
     gives the user an alert. adapted from http://www.ioscreator.com/tutorials/display-an-alert-view-in-ios8-with-swift
     
     - Parameters:
        - alertTitle: Title of the alert
        - alertMessage: Message of the alert
     */
    func alertUser(alertTitle: String, alertMessage: String) -> Void {
        //create an alert controller
        let alertController = UIAlertController(title: alertTitle, message:
            alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
        
        //add dismiss button
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
        
        //present the alert
        self.presentViewController(alertController, animated: true, completion: nil)
    } // end of alertUser
    
    /**
     makes the search barbutton visible or invisible
     
     - Parameters:
        - state: True is visible. False is invisible
     */
    func makeSearchNavBarButtonVisible(state : Bool) -> Void {
        if state {
            //make it visible
            self.navigationController?.navigationItem.leftBarButtonItem = searchNavButton
            
            //enable it
            searchNavButton.enabled = true
        } else {
            //make it invisible
            print("About to delete the searchNavButton")
            self.navigationController?.navigationItem.leftBarButtonItem = nil
            //disable
            searchNavButton.enabled = false
            
        }
    } // end of makeSearchNavBarButtonVisible
    
    /**
     sets the PinIt button as enabled or disabled
     
     - Parameters:
         - state: True is enabled. False is disabled
     */
    func makePinItButtonEnabled(state: Bool) -> Void {
        print("Pin It button is being set to " + String(state))
        self.pinItButton.enabled = state
    } // end of makePinItButtonEnabled
    
    ///Allows touches outside of text fields to end editing
    //adapted from http://www.codingexplorer.com/how-to-dismiss-uitextfields-keyboard-in-your-swift-app/
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    func setupNewStudentInfo() {
        self.newStudentInfo = StudentInformation()
    }
    
    /******************************************************/
    /******************* Text Actions **************/
    /******************************************************/
    //MARK: - Text Actions
    
    func textViewDidChangeAction(textView: UITextView) -> Void {
        //if the textview is not empty, then enable the Pin It button
        //also check for strings with only whitespace
        let stringWithNoWhitespace = textView.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        if !textView.text.isEmpty && !stringWithNoWhitespace.isEmpty{
            makePinItButtonEnabled(true)
        } else {
            makePinItButtonEnabled(false)
        }
    }
    
    /******************************************************/
    /******************* Transitions between Step 1 and Step 2 **************/
    /******************************************************/
    //MARK: - Transitions
    
    /**
     Transitions between step 1 and step 2
     */
    func transitionToOtherStep() {
        print("About to transition...")
        if self.step1View.alpha == 0 { //must be on step 2,
            //go to step 1
            UIView.animateWithDuration(0.5, animations: {
                self.step2View.alpha = 0
                self.step1View.alpha = 1
            })
            
            //disable search button
            makeSearchNavBarButtonVisible(false)
            
            //set up a new StudentInformation object
            setupNewStudentInfo()
        } else { // must be on step 1, go to step 2
            UIView.animateWithDuration(0.5, animations: {
                self.step2View.alpha = 1
                self.step1View.alpha = 0
            })
            
            //enable search button
            makeSearchNavBarButtonVisible(true)
            
            //zoom to pin
            //adapted from http://stackoverflow.com/questions/34061162/how-to-zoom-into-pin-in-mkmapview-swift
            if let pinToZoomOn = self.newPin {
                let span = MKCoordinateSpanMake(0.5, 0.5)
                let region = MKCoordinateRegion(center: pinToZoomOn.coordinate, span: span)
                miniMapView.setRegion(region, animated: true)
            }
        }
    }
    
    /******************************************************/
    /******************* Keyboard **************/
    /******************************************************/
    //MARK: - Keyboard
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PinPostViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PinPostViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
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