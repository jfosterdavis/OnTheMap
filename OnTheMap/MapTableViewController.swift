//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Jacob Foster Davis on 9/6/16.
//  Copyright © 2016 Udacity. All rights reserved.
//

import Foundation
import UIKit
class MapTableViewController: UITableViewController {
    
    /******************************************************/
    /******************* Shared Model **************/
    /******************************************************/
    //Set a pointer to the shared data model
    var StudentInformations: [StudentInformation]{
        return (UIApplication.shared.delegate as! AppDelegate).StudentInformations
    }
    
    /******************************************************/
    /******************* Life Cycle **************/
    /******************************************************/
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //refresh the data
        //realized I had to do this from forums and from Olivia Murphy code
        //https://github.com/onmurphy/MemeMe/blob/master/MemeMe/TableViewController.swift
        self.tableView.reloadData()
    }
    
    /******************************************************/
    /******************* Table Delegate Functions **************/
    /******************************************************/
    // MARK: - Table Delegate Functions
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.StudentInformations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //print("From cellForRowAtIndexPath.  There are ", String(self.sharedMemes.count), " shared Memes")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentInformationCell")!
        let StudentInformation = self.StudentInformations[(indexPath as NSIndexPath).row]
        
        // Set the name and image
        cell.textLabel?.text = (StudentInformation.firstName! as String) + " " + (StudentInformation.lastName! as String)
        cell.detailTextLabel?.text = (StudentInformation.mediaURL! as String)
        //cell.imageView?.image = meme.memedImage
        
        // If the cell has a detail label, we will put the evil scheme in.
        //if let detailTextLabel = cell.detailTextLabel {
        //    detailTextLabel.text = "Scheme: \(villain.evilScheme)"
        //}
        
        return cell
    }
    
    //When a user selects an item from the table
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Row from table was selected")
        let app = UIApplication.shared
        let StudentInformation = self.StudentInformations[(indexPath as NSIndexPath).row]
        if let toOpen = StudentInformation.mediaURL {
            print("tring to open browser from table to go to " + toOpen)
            app.openURL(URL(string: toOpen)!)
        } else {
            print("Failed to open view annotation")
        }
    }

}
