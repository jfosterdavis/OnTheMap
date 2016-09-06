//
//  GCDBlackBox.swift
//  FlickFinder
//
//  Created by Jarrod Parkes on 11/5/15.
//  Copyright © 2015 Udacity. All rights reserved.
//

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