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
    
    var booksSearchResults = [Book]()
    
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
        let cell = tableView.dequeueReusableCellWithIdentifier("BookCell", forIndexPath: indexPath) as! BookCell
        let book = booksSearchResults[indexPath.row] as Book
        cell.bookTitle.text = book.title
        cell.bookAuthor.text = book.author
        return cell
    }
    
    // Do something when search bar search button is clicked
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        booksSearchBar.resignFirstResponder()
        
        let validKeyword = booksSearchBar.text!.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())
        let validURL = "https://www.googleapis.com/books/v1/volumes?q=" + validKeyword! + "&key=AIzaSyCLO9SKNd0GDTtPKpavS0yoFPoBS4FH3HE"
        
        Alamofire.request(.GET, validURL).responseJSON { (responseData) -> Void in
            let data = JSON(responseData.result.value!)
            
            self.booksSearchResults.removeAll(keepCapacity: false)
            
            for (_, subData) in data["items"] {
                if let title = subData["volumeInfo"]["title"].string {
                    let isEqual = (title.lowercaseString == self.booksSearchBar.text?.lowercaseString)
                    if isEqual {
                        self.booksSearchResults.append(Book(title: title, author: "Nikola Tesla"))
                    }
                }
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                self.booksTable.reloadData()
                self.booksSearchBar.resignFirstResponder()
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

class Book: NSObject {
    
    var title: String
    var author: String
    
    init(title: String, author: String) {
        self.title = title
        self.author = author
        super.init()
    }
}