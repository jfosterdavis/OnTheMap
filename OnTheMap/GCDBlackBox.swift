//
//  GCDBlackBox.swift
//  OnTheMap
//
//  Derrived from work Created by Jarrod Parkes on 2/11/15.
//  Copyright (c) 2015 Jarrod Parkes. All rights reserved.
//
//  Further devlopment by Jacob Foster Davis in August - September 2016

import Foundation

struct GCDBlackBox {

    static func performUIUpdatesOnMain(updates: () -> Void) {
        dispatch_async(dispatch_get_main_queue()) {
            updates()
        }
        
        
    }

    static let dataDownload = dispatch_queue_create("dataDownload", nil)

   static func dataDownloadInBackground(function: () -> Void) {
        dispatch_async(dataDownload) {
            function()
        }
    }

    static let genericNetworkQueue = dispatch_queue_create("genericNetworkQueue", nil)

    static func runNetworkFunctionInBackground(function: () -> Void) {
        dispatch_async(genericNetworkQueue) {
            function()
        }
    }

}