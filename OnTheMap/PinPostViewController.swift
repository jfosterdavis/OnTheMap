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
    

    
    
    /******************************************************/
    /******************* Outlets **************/
    /******************************************************/
    //MARK: - Outlets
    
    @IBOutlet weak var searchButton: UIButton!
    
    @IBOutlet weak var step2PromptContainer: UIView!
    @IBOutlet weak var miniMapContainer: UIView!
    @IBOutlet weak var step1PromptContainer: UIView!
    @IBOutlet weak var pinLocationCreatorContainer: UIView!
    @IBOutlet weak var miniMapView: MKMapView!
    
    @IBOutlet weak var step1View: UIView!
    @IBOutlet weak var step2View: UIView!
    @IBOutlet weak var step1LocationInput: UITextField!
    
    /******************************************************/
    /******************* Life Cycle **************/
    /******************************************************/
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        miniMapView.delegate = self
        
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
            geocodeForward(textToGeoCode)
        } else {
            //TODO: Handle error
        }
    } //end searchAndTransition
    
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
            //pinView!.canShowCallout = true
            pinView!.pinColor = .Red
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
         - `annotation`: A `MKPointAnnotation` object
     */
    func plotPin(annotation : MKPointAnnotation) {
        self.miniMapView.addAnnotation(annotation)
    }
    
    /**
     Takes a placemark and attempts to create a pin
     
     - Parameters:
         - `placemark`: The placemark used to create the pin
     
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
         - `pinToPlot`: The pin to plot
     */
    func pinSetAndPlot(pinToPlot : MKPointAnnotation) -> Void {
        //set the pin
        self.newPin = pinToPlot
        
        //plot the pin
        plotPin(self.newPin!)
        
    } // end of pinSetAndPlot
    
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
    
    /******************************************************/
    /******************* Transitions between Step 1 and Step 2 **************/
    /******************************************************/
    //MARK: - Transitions
    
    /**
     Transitions between step 1 and step 2
     */
    func transitionToOtherStep() {
        print("About to transition...")
        if self.step1View.alpha == 0 { //must be on step 2, go to step 1
            UIView.animateWithDuration(0.5, animations: {
                self.step2View.alpha = 0
                self.step1View.alpha = 1
            })
        } else { // must be on step 1, go to step 2
            UIView.animateWithDuration(0.5, animations: {
                self.step2View.alpha = 1
                self.step1View.alpha = 0
            })
            
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