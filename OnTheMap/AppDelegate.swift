//
//  AppDelegate.swift
//  OnTheMap
//
//  Derrived from work Created by Jarrod Parkes on 2/11/15.
//  Copyright (c) 2015 Jarrod Parkes. All rights reserved.
//
//  Further devlopment by Jacob Foster Davis in August - September 2016

import UIKit

// MARK: - AppDelegate: UIResponder, UIApplicationDelegate

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK: Properties
    var window: UIWindow?
    
    /******************************************************/
    /******************* The Shared Model **************/
    /******************************************************/
    //MARK: - The Shared Model
    var StudentInformations = [StudentInformation]()
    var UdacityUserInfo = UdacityUserInformation()
    var NewStudentInfo = StudentInformation()
    
    // MARK: UIApplicationDelegate
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        return true
    }
    
    func resetStudentInformations() {
        self.StudentInformations = [StudentInformation]()
    }
    
    func resetUdacityUserInfo() {
        self.UdacityUserInfo = UdacityUserInformation()
    }
    
    func resetNewStudentInfo() {
        self.NewStudentInfo = StudentInformation()
    }
    
    func resetAllSharedModels() {
        resetStudentInformations()
        resetUdacityUserInfo()
        resetNewStudentInfo()
    }
}
