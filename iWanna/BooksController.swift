//
//  BooksController.swift
//  iWanna
//
//  Created by John Claro on 18/03/2016.
//  Copyright © 2016 jkrclaro. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class BooksController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var booksTable: UITableView!
    @IBOutlet weak var booksSearchBar: UISearchBar!
    
    var booksSearchResults = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return booksSearchResults.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("bookCell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.text = booksSearchResults[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    // Do something when search bar search button is clicked
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        booksSearchBar.resignFirstResponder()
        
        // https://www.googleapis.com/books/v1/volumes?q=the%20hobbit&key=AIzaSyCLO9SKNd0GDTtPKpavS0yoFPoBS4FH3HE

        let validKeyword = booksSearchBar.text!.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())
        let validURL = "https://www.googleapis.com/books/v1/volumes?q=" + validKeyword! + "&key=AIzaSyCLO9SKNd0GDTtPKpavS0yoFPoBS4FH3HE"
        
        Alamofire.request(.GET, validURL).responseJSON { (responseData) -> Void in
            let data = JSON(responseData.result.value!)
            
            if let title = data["items"][0]["volumeInfo"]["title"].string {
                print(title)
            }
        }
    }
    
    // Do something when search bar cancel button is clicked
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        booksSearchBar.resignFirstResponder()
        booksSearchBar.text = ""
    }
    
    // Do something when refresh button is tapped
    @IBAction func refreshButtonTapped(sender: AnyObject) {
        booksSearchBar.resignFirstResponder()
        booksSearchBar.text = ""
        booksSearchResults.removeAll(keepCapacity: false)
        booksTable.reloadData()
    }
    
}