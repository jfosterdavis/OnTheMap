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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //parseTestMessage()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //make an initial fetch for pins
        GCDBlackBox.dataDownloadInBackground {
            ParseClient.sharedInstance.getStudentLocations(200, skip: 5, order: "-lastName") { (success, errorString) in
                GCDBlackBox.performUIUpdatesOnMain {
                    if success {
                        print("getStudentLocations completed successfully")
                    } else {
                        print("\nERROR: getStudentLocations failed!")
                    }
                }
            }
        }
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