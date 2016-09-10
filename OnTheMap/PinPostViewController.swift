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
    
    /******************************************************/
    /******************* Life Cycle **************/
    /******************************************************/
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        miniMapView.delegate = self
        
        UIView.animateWithDuration(0.5, animations: {
            self.step2View.alpha = 1
            self.step1View.alpha = 0
        })
    }
    
    /******************************************************/
    /******************* Actions **************/
    /******************************************************/
    //MARK: - Action
    
    
    @IBAction func searchAndTransition(sender: AnyObject) {
        

            UIView.animateWithDuration(0.5, animations: {
                self.miniMapContainer.alpha = 1
                self.pinLocationCreatorContainer.alpha = 0
            })

    }
    
}