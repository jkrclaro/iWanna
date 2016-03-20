//
//  BooksController.swift
//  iWanna
//
//  Created by John Claro on 18/03/2016.
//  Copyright © 2016 jkrclaro. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
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
        let book = self.booksSearchResults[indexPath.row] as Book
        cell.bookTitle.text = book.title
        cell.bookAuthor.text = book.author
        cell.bookImage.image = book.image
        return cell
    }
    
    // Do something when search bar search button is clicked
    func searchBarSearchButtonClicked(searchBar: UISearchBar, completionHandler: ((UIBackgroundFetchResult) -> Void)!) {
        booksSearchBar.resignFirstResponder()
        let validKeyword = booksSearchBar.text!.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())
        let validBookURL = "https://www.googleapis.com/books/v1/volumes?q=" + validKeyword! + "&key=AIzaSyCLO9SKNd0GDTtPKpavS0yoFPoBS4FH3HE"
        print("Clicked search")
        
        Alamofire.request(.GET, validBookURL).responseJSON { (responseData) -> Void in
            let data = JSON(responseData.result.value!)
            
            self.booksSearchResults.removeAll(keepCapacity: false)
            
            for (_, bookDetails) in data["items"] {
                if let title = bookDetails["volumeInfo"]["title"].string {
                    if title.lowercaseString.containsString(self.booksSearchBar.text!.lowercaseString) {
                        var authors = ""
                        for (key, bookAuthors) in bookDetails["volumeInfo"]["authors"] {
                            if(key == "0") { // Don't include the & at first
                                authors += bookAuthors.string!
                            } else {
                                authors += " & " + bookAuthors.string!
                            }
                        }
                        var imageURL = bookDetails["volumeInfo"]["imageLinks"]["smallThumbnail"].string!
                        imageURL = imageURL.stringByReplacingOccurrencesOfString("http:", withString: "https:")
                        Alamofire.request(.GET, imageURL).responseImage { response in
                            if let image = response.result.value {
                                print("Adding image")
                                self.booksSearchResults.append(Book(title: title, author: authors, image: image))
                            }
                        }
                    }
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), {
            self.booksSearchResults.sortInPlace({$0.title < $1.title}) // Sort the results alphabetically
            self.booksTable.reloadData()
            self.booksSearchBar.resignFirstResponder()
        })
    }
    
    // Do something when search bar cancel button is clicked
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        booksSearchBar.resignFirstResponder()
        booksSearchBar.text = ""
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        booksSearchBar.resignFirstResponder()
        booksSearchBar.text = ""
        booksSearchResults.removeAll(keepCapacity: false)
        booksTable.reloadData()
    }
    
    @IBAction func cancelToBooksController(segue: UIStoryboardSegue) {
        
    }
}

class Book: NSObject {
    
    var title: String
    var author: String
    var image: UIImage
    
    init(title: String, author: String, image: UIImage) {
        self.title = title
        self.author = author
        self.image = image
        super.init()
    }
}