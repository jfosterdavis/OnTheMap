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

class MapViewController: UIViewController, MKMapViewDelegate {
    
    //Set a pointer to the shared data model
    var StudentInformations: [StudentInformation]{
        return (UIApplication.sharedApplication().delegate as! AppDelegate).StudentInformations
    }
    
    @IBOutlet weak var mapView: MKMapView!
    
    var session: NSURLSession!
    var annotations = [MKPointAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //parseTestMessage()
        
        mapView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //make an initial fetch for pins if there are none
        if StudentInformations.isEmpty {
            fetchPinsAndPlotPins(200, skip: 5, order: "-lastName")
        }
        
    }
    
    // MARK: - MKMapViewDelegate
    
    // Here we create a view with a "right callout accessory view". You might choose to look into other
    // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
    // method in TableViewDataSource.
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinColor = .Red
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
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
    
    //MARK: 
    
    //takes data in the shared StudentInformation model and destructively sets the annotations
    func createAnnotationsFromSharedModel () {
        //clear current annotations
        self.annotations = [MKPointAnnotation]()
        for StudentInformation in StudentInformations {
            
            // Notice that the float values are being used to create CLLocationDegree values.
            // This is a version of the Double type.
            let lat = CLLocationDegrees(StudentInformation.latitude!)
            let long = CLLocationDegrees(StudentInformation.longitude!)
            
            // The lat and long are used to create a CLLocationCoordinates2D instance.
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let first = StudentInformation.firstName!
            let last = StudentInformation.lastName!
            let mediaURL = StudentInformation.mediaURL!
            
            // Here we create the annotation and set its coordiate, title, and subtitle properties
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = mediaURL
            
            // Finally we place the annotation in an array of annotations.
            self.annotations.append(annotation)
        }
        print("The Annotations array has " + String(annotations.count) + " members.")
    }
    
    func plotPins(annotations : [MKPointAnnotation]) {
        self.mapView.addAnnotations(annotations)
    }
    
    //MARK: - Convenience functions for fetching and plotting pins
    
    func runFunctionThatUpdatesUI(doThis: () -> Void) -> Void {
        GCDBlackBox.performUIUpdatesOnMain {
            doThis()
        }
    }
    
    func fetchPins(limit: Int?, skip: Int?, order: String?, completionHandlerForFetchPins: () -> Void) {
        GCDBlackBox.dataDownloadInBackground {
            ParseClient.sharedInstance.getStudentLocations(limit, skip: skip, order: order) { (success, errorString) in
                //closure...
                completionHandlerForFetchPins()
            }
        }
    }
    
    func fetchPinsAndPlotPins(limit: Int?, skip: Int?, order: String?) {
        fetchPins(limit, skip: skip, order: order) { () in
            self.runFunctionThatUpdatesUI {
                self.plotPinsFromSharedModel()
            }
        }
    }
    
    //plots all of the pins in the shared model
    //this updates the UI so must be in main queue.
    func plotPinsFromSharedModel() {
        print("plotPins() called")
        createAnnotationsFromSharedModel()
        plotPins(self.annotations)
        
    }
    
    
    func parseTestMessage() {
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