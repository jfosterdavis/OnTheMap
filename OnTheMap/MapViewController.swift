//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Jacob Foster Davis on 9/5/16.
//  Copyright © 2016 Udacity. All rights reserved.
//

import Foundation
import UIKit
import MapKit

// MARK: - MapViewController: UIViewController

class MapViewController: UIViewController, MKMapViewDelegate, OTMTabBarControllerDelegate {
    
    /******************************************************/
    /******************* PROPERTIES **************/
    /******************************************************/
    
    @IBOutlet weak var mapView: MKMapView!
    
    var session: NSURLSession!
    var annotations = [MKPointAnnotation]()
    
    var newStudentInfo : StudentInformation?
    
    /******************************************************/
    /******************* Shared Model **************/
    /******************************************************/
    //Set a pointer to the shared data model
    var StudentInformations: [StudentInformation]{
        return (UIApplication.sharedApplication().delegate as! AppDelegate).StudentInformations
    }
    
//    var UdacityUserInfo: UdacityUserInformation {
//        return (UIApplication.sharedApplication().delegate as! AppDelegate).UdacityUserInfo
//    }
    
    /******************************************************/
    /******************* Life Cycle **************/
    /******************************************************/
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //parseTestMessage()
        
        
        //set delegates
        mapView.delegate = self
        
        let otmTabBarController = self.tabBarController as! OTMTabBarController
        otmTabBarController.otmDelegate = self
        
        setupNewStudentInfo()
        
        
        //way to add this button adapted from http://stackoverflow.com/questions/31747470/button-in-navigation-bar-in-tab-bar-uiviewcontroller-not-showing
       // self.tabBarController?.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(addPinButtonPressed))
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //make an initial fetch for pins if there are none
        if StudentInformations.isEmpty {
            fetchPinsAndPlotPins(100, skip: 5, order: "-lastName")
        }
        
    }
    
    /******************************************************/
    /******************* Actions **************/
    /******************************************************/
    //MARK: - Actions

    
    /******************************************************/
    /******************* Map Delegate **************/
    /******************************************************/
    //MARK: - Map Delegate
    
    // Here we create a view with a "right callout accessory view". You might choose to look into other
    // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
    // method in TableViewDataSource.
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.redColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
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
    /******************* Housekeeping **************/
    /******************************************************/
    //MARK: - Housekeeping
    
    func setupNewStudentInfo() {
        self.newStudentInfo = StudentInformation()
    }
    
    /******************************************************/
    /******************* Convenience Functions **************/
    /******************************************************/
    //MARK: - Convenience Functions
    
    /**
     Takes data in the shared model and desctructively sets the annotations
     */
    func createAnnotationsFromSharedModel () {
        //clear current annotations
        self.annotations = [MKPointAnnotation]()
        for StudentInformation in StudentInformations {
            let annotation = self.studentInformationToAnnotation(StudentInformation)
            self.annotations.append(annotation)
        }
        print("The Annotations array has " + String(annotations.count) + " members.")
    }
    
    func studentInformationToAnnotation (studentInfo : StudentInformation) -> MKPointAnnotation {
        
        // Notice that the float values are being used to create CLLocationDegree values.
        // This is a version of the Double type.
        let lat = CLLocationDegrees(studentInfo.latitude!)
        let long = CLLocationDegrees(studentInfo.longitude!)
        
        // The lat and long are used to create a CLLocationCoordinates2D instance.
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
        let first = studentInfo.firstName!
        let last = studentInfo.lastName!
        let mediaURL = studentInfo.mediaURL!
        
        // Here we create the annotation and set its coordiate, title, and subtitle properties
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "\(first) \(last)"
        annotation.subtitle = mediaURL
        
        // Finally we place the annotation in an array of annotations.
        return annotation
    }
    
    /**
     Takes a given UI function and runs it in the main queue
     
     - Parameters:
         - doThis: A function, usually given as a closure
     */
    func runFunctionThatUpdatesUI(doThis: () -> Void) -> Void {
        GCDBlackBox.performUIUpdatesOnMain {
            doThis()
        }
    }
    
    /**
     Fetches Pins from the Udacity ParseClient shared instance and plots them
     
     - Parameters:
        - limit: how many pins to return
        - skip: how many pins to skip when fetching
        - order: which data field to order the results
     */
    func fetchPinsAndPlotPins(limit: Int?, skip: Int?, order: String?) {
        //TODO: Add overwrite option
        /*
         *  Should this overwrite or not?
         */
        
        fetchPins(limit, skip: skip, order: order) { () in
            self.runFunctionThatUpdatesUI {
                self.plotPinsFromSharedModel()
            }
        }
    }
    
    /**
     Plots pins from the shared model
     */
    func plotPinsFromSharedModel() {
        print("plotPins() called")
        createAnnotationsFromSharedModel()
        plotPins(self.annotations)
        
    }
    
    /******************************************************/
    /******************* Fetching Pins **************/
    /******************************************************/
    //MARK: - Fetching Pins
     
    /**
     Fetches Pins from the Udacity ParseClient shared instance
     
     - Parameters:
         - limit: how many pins to return
         - skip: how many pins to skip when fetching
         - order: which data field to order the results
     */
    func fetchPins(limit: Int?, skip: Int?, order: String?, completionHandlerForFetchPins: () -> Void) {
        GCDBlackBox.dataDownloadInBackground {
            ParseClient.sharedInstance.getStudentLocations(limit, skip: skip, order: order) { (success, errorString) in
                //closure...
                completionHandlerForFetchPins()
            }
        }
    }
    
    /******************************************************/
    /******************* Plotting Pins **************/
    /******************************************************/
    //MARK: - Plotting Pins
    
    /**
     Plots the given array of Pins
     
     - Parameters:
         - `annotations`: An array of `MKPointAnnotation` objects
     
     */
    func plotPins(annotations : [MKPointAnnotation]) {
        self.mapView.addAnnotations(annotations)
    }
    
    func plotPin(annotation : MKPointAnnotation) {
        self.mapView.addAnnotation(annotation)
    }
    
    func plotNewPinFromStudentInformation(newStudentInfo : StudentInformation) {
        let annotation = self.studentInformationToAnnotation(newStudentInfo)
        plotPin(annotation)
        
        //Zoom to pin
        let pinToZoomOn = annotation
        let span = MKCoordinateSpanMake(0.5, 0.5)
        let region = MKCoordinateRegion(center: pinToZoomOn.coordinate, span: span)
        mapView.setRegion(region, animated: true)
        //annotation selection adapted from http://stackoverflow.com/questions/978897/how-to-trigger-mkannotationviews-callout-view-without-touching-the-pin
        mapView.selectAnnotation(annotation, animated: true)
        
        
    }
    
    /******************************************************/
    /******************* Testing **************/
    /******************************************************/
    //MARK: - Testing  
    
    private func parseTestMessage() {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
        request.addValue(Secrets.ParseAPIKey, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Secrets.ParseRESTAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error...
                print("Parse test failed")
                return
            }
            //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            var testData: AnyObject!
            do {
                testData = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
            } catch {
                print("Failed to test Parse from MapView")
            }
            print(testData)
            if let resultsArray = testData["results"] as? NSArray {
                print("Unwrapped")
                
                print (resultsArray)
                for info in resultsArray {
                    if let newInfo = info as? [String:AnyObject] {
                        if let test = StudentInformation(fromDataSet: newInfo){
                            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                            appDelegate.StudentInformations.append(test)
                            
                        }
                        print("\nHere is one new item from the array of objects:")
                        print(newInfo)
                    }
                    
                }
                print("There are " + String(self.StudentInformations.count) + " Information Records stored.  MapView Test Complete.")
            }
        }
        task.resume()
    }
}