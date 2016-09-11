//
//  URLInputTextViewDelegate.swift
//  OnTheMap
//
//  Created by Jacob Foster Davis on 9/11/16.
//  Copyright © 2016 Udacity. All rights reserved.
//

import Foundation
import UIKit

extension PinPostViewController: UITextViewDelegate {
    
    //adapted from http://stackoverflow.com/questions/7372484/how-to-clear-previous-text-in-uitextview-before-writing-text
    func textViewDidBeginEditing(textView: UITextView) {
        textView.text = ""
    }
    
    func textViewDidChange(textView: UITextView) {
        //
        textViewDidChangeAction(textView)
        
    }
    
    func textViewShouldEndEditing(textView: UITextView) -> Bool {
        return true
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        //if the text is not empty even when whitespace is taken away
        
        var resultText = textView.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        if !resultText.isEmpty {
            //check length
            // if less than 7 characters then add http://
            if resultText.characters.count < 7 {
                resultText = "http://" + resultText
                textView.text = resultText
            } else {
                //string is more than 7 characters so check for protocol
                //check for http:// and https:// in the front
                print("Checking user input for http:// : " + resultText)
                let httpString = "http://"
                //let httpsString = "https://"
                //get the first 7 characters
                let httpCheck = resultText.substringWithRange(Range<String.Index>(start: resultText.startIndex, end: resultText.startIndex.advancedBy(7)))
                //get the first 8 characters
                //let httpsCheck = resultText.substringWithRange(Range<String.Index>(start: resultText.startIndex, end: resultText.startIndex.advancedBy(8)))
                //if httpsString != httpsCheck || httpString != httpCheck {
                if httpString != httpCheck {
                    //the first part of the user input doesn't contain http://, so add it
                    //check for https if the string is larger
                    if resultText.characters.count > 7 {
                        let httpsString = "https://"
                        //get the first 8 characters
                        let httpsCheck = resultText.substringWithRange(Range<String.Index>(start: resultText.startIndex, end: resultText.startIndex.advancedBy(8)))
                        if httpsString != httpsCheck {
                            //https:// was not foundin the string, so give it http://
                            //text doesn't have http:// and is 7 characters long
                            resultText = "http://" + resultText
                            //set the text
                            textView.text = resultText
                            
                        } else {
                            //string contains https://
                            textView.text = resultText
                        }
                    } else {
                        //text doesn't have http:// and is 7 characters long
                        resultText = "http://" + resultText
                        //set the text
                        textView.text = resultText
                    }
                } else {
                    //https:// or http:// is already there.  don't do anything, but set the text since it doesn't contain whitespace now
                    textView.text = resultText
                }
            }
        } else {
            //string was empty or <6
            textView.text = resultText
        }
    
        textView.resignFirstResponder()
    }
    
    
    
}