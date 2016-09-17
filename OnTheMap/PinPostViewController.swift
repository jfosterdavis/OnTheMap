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

//adapted from http://stackoverflow.com/questions/19343519/pass-data-back-to-previous-viewcontroller
/// Used to send information back to the presenting view controller
protocol PinPostViewControllerDelegate: class {
    func newStudentInformationDataReady(_ newStudentInfo : StudentInformation)
}

class PinPostViewController: UIViewController, MKMapViewDelegate {
    
    /******************************************************/
    /******************* Properties **************/
    /******************************************************/
    //MARK: - Properties
    var newPin : MKPointAnnotation?
    var newStudentInfo : StudentInformation?
    /// Delegate for passing data back to presenting viewcontroller
    weak var delegate : PinPostViewControllerDelegate? = nil
    
    /** Spinning wheel to show user that network activity is in progress */
    var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)

    
    
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
    
    enum StudentInfoCreationError: Error {
        case missingObject() //Missing an object needed to create
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
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        activityIndicator.center = self.view.center
        view.addSubview(activityIndicator)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.unsubscribeFromKeyboardNotifications()
    }
    
    /******************************************************/
    /******************* Actions **************/
    /******************************************************/
    //MARK: - Action
    
    
    @IBAction func searchAndTransition(_ sender: AnyObject){
        if let textToGeoCode = step1LocationInput.text {
            if !textToGeoCode.isEmpty {
                geocodeForward(textToGeoCode)
            } else {
                //text field was empty
                displayError(NSError(domain: "searchAndTransition", code: 6, userInfo: [NSLocalizedDescriptionKey: "Please enter the name of your location in the text box."]))
            }
        } else {
            displayError(NSError(domain: "searchAndTransition", code: 5, userInfo: [NSLocalizedDescriptionKey: "Text box appears to not exist!"]))
        }
    } //end searchAndTransition
    
    @IBAction func searchNavButtonPressed(_ sender: AnyObject) {
        transitionToOtherStep()
    }
    
    @IBAction func cancelNavButtonPressed(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func pinItButtonPressed(_ sender: BorderedButton!) {
        print("Pin It button pressed")
        //make sure text view is done editing
        step2URLInput.endEditing(true)
        
        //check that all data is input
        //set the mediaURL
        if !setNewStudentInfoURL(self.step2URLInput.text!){
            print("Failed to set URL")
        }
        //set the coordinates
        if self.newPin !=  nil {
            print("About to try to set coordinates")
            setNewStudentInfoCoordinates(self.newPin!)
        } else {
            //TODO: handle case
            print("Failed to set coordinates")
        }
        
        print("StudentIformation Object ready: ")
        print(self.newStudentInfo)
        //Send data back
        
        self.delegate?.newStudentInformationDataReady(self.newStudentInfo!)
        
        self.dismiss(animated: true, completion: nil)
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
    func geocodeForward(_ locationString: String) {
        startActivityIndicator()
        
        let textToGeoCode = locationString
        let Geocoder = CLGeocoder()
        Geocoder.geocodeAddressString(textToGeoCode) { (placemarks, error) in
            self.stopActivityIndicator()
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
                self.displayError(NSError(domain: "geocodeForward", code: -1, userInfo: [NSLocalizedDescriptionKey: "Geocoding Failed."]))
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
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "newPin"
        
        var pinView = miniMapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.blue
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
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle! {
                app.openURL(URL(string: toOpen)!)
            } else {
                print("Failed to open view annotation")
            }
        }
    }
    
    /******************************************************/
    /******************* StudentInformationDataDelegate **************/
    /******************************************************/
    //MARK: - StudentInformationDataDelegate
    
    
    /******************************************************/
    /******************* Pins **************/
    /******************************************************/
    //MARK: - Pins
    
    /**
     Plots the given Pin
     
     - Parameters:
         - annotation: A `MKPointAnnotation` object
     */
    func plotPin(_ annotation : MKPointAnnotation) {
        self.miniMapView.addAnnotation(annotation)
    }
    
    /**
     Takes a placemark and attempts to create a pin
     
     - Parameters:
         - placemark: The placemark used to create the pin
     
     - Returns: `MKAnnotation` (a pin)
     */
    func pinFromPlacemark(_ placemark : CLPlacemark) -> MKPointAnnotation {
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
    func pinSetAndPlot(_ pinToPlot : MKPointAnnotation) -> Void {
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
    
    func setNewStudentInfoURL(_ inputURL : String!) -> Bool {
        //print("setNewStudentInfoURL called")
        if self.newStudentInfo == nil {
            //the newStudentInfo is not initialized
            print("the newStudentInfo is not initialized")
            return false
        } else {
            //the newStudentInfo exists, set the value
            self.newStudentInfo!.mediaURL = inputURL!
            
            //check for success because the struct has input validation
            if self.newStudentInfo!.mediaURL == inputURL! {
                print("mediaURL set to: " + String(describing: self.newStudentInfo!.mediaURL))
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
    func setNewStudentInfoCoordinates(_ inputPin : MKPointAnnotation) -> Bool {
        if self.newStudentInfo == nil {
            print("Failed to set coordinates. self.newstudentinfo returned nil")
            //the newStudentInfo is not initialized
            return false
        } else {
            //the newStudentInfo exists, set the value
            self.newStudentInfo!.latitude = inputPin.coordinate.latitude
            self.newStudentInfo!.longitude = inputPin.coordinate.longitude
            
            //check for success because the struct has input validation
            if self.newStudentInfo!.latitude == inputPin.coordinate.latitude &&
            self.newStudentInfo!.longitude == inputPin.coordinate.longitude {
                print("Latitude set to: " + String(describing: self.newStudentInfo!.latitude))
                print("Longitude set to: " + String(describing: self.newStudentInfo!.longitude))
                return true
            } else {
                print("Failed to set coordinates")
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
    func setNewStudentInfoMapString(_ inputMapString : String!) -> Bool {
        if self.newStudentInfo == nil {
            //the newStudentInfo is not initialized
            print("Failed to set MapString")
            return false
        } else {
            //the newStudentInfo exists, set the value
            self.newStudentInfo!.mapString = inputMapString
            
            //check for success because the struct has input validation
            if self.newStudentInfo!.mapString == inputMapString  {
                print("Mapstring set to: " + String(describing: self.newStudentInfo!.mapString))
                return true
            } else {
                print("Failed to set MapString")
                return false
            }
        }
    } // end of setNewStudentInfoMapString
    
    /******************************************************/
    /******************* Housekeeping functions **************/
    /******************************************************/
    //MARK: - Housekeeping
    
    fileprivate func displayError(_ error: NSError?) {
        if let error = error {
            var errorPrefix = ""
            switch error.code {
            case 1:
                errorPrefix = "Unable to Connect"
            case 2:
                errorPrefix = "Bad Credentials"
            case 3:
                errorPrefix = "No Data from Server"
            case 4:
                errorPrefix = "Unexpected Data from Server"
            case 5:
                errorPrefix = "Application Error"
            case 6:
                errorPrefix = "User Error"
            default:
                errorPrefix = "Unknown Error"
            }
            
            let errorString = error.userInfo[NSLocalizedDescriptionKey] as! String
            ErrorHandler.alertUser(self, alertTitle: errorPrefix, alertMessage: errorString)
        }
    }
    
    
    /**
     Recreates a fresh annotation for the `self.newPin` and sets it.
     
     - Returns: `self.newPin`, freshly instantiated
     */
    func cleanNewPin() -> MKPointAnnotation {
        self.newPin = MKPointAnnotation()
        return self.newPin!
    } // end of cleanNewPin

    
    /**
     makes the search barbutton visible or invisible
     
     - Parameters:
        - state: True is visible. False is invisible
     */
    func makeSearchNavBarButtonVisible(_ state : Bool) -> Void {
        if state {
            //make it visible
            searchNavButton.tintColor = nil
            
            //enable it
            searchNavButton.isEnabled = true
        } else {
            //make it invisible
            print("About to hide the searchNavButton")
            //self.navigationController?.navigationItem.leftBarButtonItem = nil
            searchNavButton.tintColor = UIColor.clear
            //disable
            searchNavButton.isEnabled = false
            
        }
    } // end of makeSearchNavBarButtonVisible
    
    /**
     sets the PinIt button as enabled or disabled
     
     - Parameters:
         - state: True is enabled. False is disabled
     */
    func makePinItButtonEnabled(_ state: Bool) -> Void {
        print("Pin It button is being set to " + String(state))
        self.pinItButton.isEnabled = state
    } // end of makePinItButtonEnabled
    
    ///Allows touches outside of text fields to end editing
    //adapted from http://www.codingexplorer.com/how-to-dismiss-uitextfields-keyboard-in-your-swift-app/
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    func setupNewStudentInfo() {
        self.newStudentInfo = StudentInformation()
    }
    
    /******************************************************/
    /******************* Text Actions **************/
    /******************************************************/
    //MARK: - Text Actions
    
    func textViewDidChangeAction(_ textView: UITextView) -> Void {
        //if the textview is not empty, then enable the Pin It button
        //also check for strings with only whitespace
        let stringWithNoWhitespace = textView.text.trimmingCharacters(in: CharacterSet.whitespaces)
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
            UIView.animate(withDuration: 0.5, animations: {
                self.step2View.alpha = 0
                self.step1View.alpha = 1
            })
            
            //disable search button
            makeSearchNavBarButtonVisible(false)
            
            //set up a new StudentInformation object
            setupNewStudentInfo()
        } else { // must be on step 1, go to step 2
            UIView.animate(withDuration: 0.5, animations: {
                self.step2View.alpha = 1
                self.step1View.alpha = 0
            })
            
            //enable search button
            makeSearchNavBarButtonVisible(true)
            
            
            
            //zoom to pin
            //adapted from http://stackoverflow.com/questions/34061162/how-to-zoom-into-pin-in-mkmapview-swift
            if let pinToZoomOn = self.newPin {
                //display callout
                miniMapView.selectAnnotation(pinToZoomOn, animated: true)
                
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
        NotificationCenter.default.addObserver(self, selector: #selector(PinPostViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PinPostViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
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
            //for this, we are assuming that the only text field is the first responder
            view.frame.origin.y = -(getKeyboardHeight(notification))

        }
    } //end of keyboardWillShow
    
    func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0
    }
    
}
