//
//  UdacityAuthViewController.swift
//  TheMovieManager
//
//  Created by Jarrod Parkes on 2/11/15.
//  Copyright (c) 2015 Jarrod Parkes. All rights reserved.
//

import UIKit

// MARK: - UdacityAuthViewController: UIViewController

class UdacityAuthViewController: UIViewController {

    // MARK: Properties
    
    var urlRequest: NSURLRequest? = nil
    var requestToken: String? = nil
    var completionHandlerForView: ((success: Bool, errorString: String?) -> Void)? = nil
    
    // MARK: Outlets
    
    @IBOutlet weak var webView: UIWebView!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.delegate = self
        
        navigationItem.title = "TheMovieDB Auth"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: #selector(cancelAuth))
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let urlRequest = urlRequest {
            webView.loadRequest(urlRequest)
        }
    }
    
    // MARK: Cancel Auth Flow
    
    func cancelAuth() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK: - UdacityAuthViewController: UIWebViewDelegate

extension UdacityAuthViewController: UIWebViewDelegate {
    
    func webViewDidFinishLoad(webView: UIWebView) {
        
        if webView.request!.URL!.absoluteString == "\(UdacityClient.Constants.AuthorizationURL)\(requestToken!)/allow" {
            
            dismissViewControllerAnimated(true) {
                self.completionHandlerForView!(success: true, errorString: nil)
            }
        }
    }
}