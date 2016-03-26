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
    
    // Do something when search bar search button is clicked
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        booksSearchBar.resignFirstResponder()
        let validKeyword = booksSearchBar.text!.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())
        let validBookURL = "https://www.googleapis.com/books/v1/volumes?q=" + validKeyword! + "&key=AIzaSyCLO9SKNd0GDTtPKpavS0yoFPoBS4FH3HE"
        
        Alamofire.request(.GET, validBookURL).responseJSON { (responseData) -> Void in
            let data = JSON(responseData.result.value!)
            self.booksSearchResults.removeAll(keepCapacity: false)
            
            dispatch_async(dispatch_get_main_queue(), {
                self.booksSearchResults.sortInPlace({$0.title < $1.title}) // Sort the results alphabetically
                self.booksTable.reloadData()
                self.booksSearchBar.resignFirstResponder()
            })

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
                        var imageURL = bookDetails["volumeInfo"]["imageLinks"]["smallThumbnail"].string
                        
                        if imageURL != nil {
                            imageURL = imageURL!.stringByReplacingOccurrencesOfString("http:", withString: "https:")
                        } else {
                            imageURL = "http://books.google.ie/books/content?id=&printsec=frontcover&img=1&zoom=5&source=gbs_api"
                        }
                        
                        Alamofire.request(.GET, imageURL!).responseImage { response in
                            if let image = response.result.value {
                                self.booksSearchResults.append(Book(title: title, author: authors, image: image, summary: "Nulla varius pharetra nisl vitae placerat. Aenean luctus molestie libero id hendrerit. Integer vel tristique elit. Suspendisse id ullamcorper libero, eget ultricies velit. Ut vel dapibus ipsum. Vivamus et nulla dui. Mauris sem massa, tempus in velit vitae, pellentesque tempus nunc. Fusce ac suscipit risus, eu dictum ipsum. Fusce sagittis est congue est accumsan ultrices. Mauris sollicitudin vestibulum magna a vestibulum. Donec cursus eu est in venenatis. Donec porta diam ut sem consectetur, et eleifend ligula congue. Vestibulum eros dui, viverra nec felis vitae, vulputate sagittis risus. Nulla varius pharetra nisl vitae placerat. Aenean luctus molestie libero id hendrerit. Integer vel tristique elit. Suspendisse id ullamcorper libero, eget ultricies velit. Ut vel dapibus ipsum. Vivamus et nulla dui. Mauris sem massa, tempus in velit vitae, pellentesque tempus nunc. Fusce ac suscipit risus, eu dictum ipsum. Fusce sagittis est congue est accumsan ultrices. Mauris sollicitudin vestibulum magna a vestibulum. Donec cursus eu est in venenatis. Donec porta diam ut sem consectetur, et eleifend ligula congue. Vestibulum eros dui, viverra nec felis vitae, vulputate sagittis risus. Nulla varius pharetra nisl vitae placerat. Aenean luctus molestie libero id hendrerit. Integer vel tristique elit. Suspendisse id ullamcorper libero, eget ultricies velit. Ut vel dapibus ipsum. Vivamus et nulla dui. Mauris sem massa, tempus in velit vitae, pellentesque tempus nunc. Fusce ac suscipit risus, eu dictum ipsum. Fusce sagittis est congue est accumsan ultrices. Mauris sollicitudin vestibulum magna a vestibulum. Donec cursus eu est in venenatis. Donec porta diam ut sem consectetur, et eleifend ligula congue. Vestibulum eros dui, viverra nec felis vitae, vulputate sagittis risus."))
                                dispatch_async(dispatch_get_main_queue(), {
                                    self.booksSearchResults.sortInPlace({$0.title < $1.title}) // Sort the results alphabetically
                                    self.booksTable.reloadData()
                                    self.booksSearchBar.resignFirstResponder()
                                })
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Do something when search bar cancel button is clicked
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        booksSearchBar.resignFirstResponder()
        booksSearchBar.text = ""
        booksSearchResults.removeAll(keepCapacity: false)
        booksTable.reloadData()
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        booksSearchBar.resignFirstResponder()
        booksSearchBar.text = ""
        booksSearchResults.removeAll(keepCapacity: false)
        booksTable.reloadData()
    }
    
    @IBAction func cancelToBooksController(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func saveBookDetails(segue: UIStoryboardSegue) {
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BookCell", forIndexPath: indexPath) as! BookCell
        let book = self.booksSearchResults[indexPath.row] as Book
        cell.bookTitle.text = book.title
        cell.bookAuthor.text = book.author
        cell.bookImage.image = book.image
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "bookDetailSelected" {
            if let destination = segue.destinationViewController as? BookDetailsController {
                let path = booksTable.indexPathForSelectedRow
                let book = self.booksSearchResults[path!.row] as Book
                destination.viaSegueBookImage = book.image
                destination.viaSegueBookTitle = book.title
                destination.viaSegueBookAuthor = book.author
                destination.viaSegueBookSummary = book.summary
            }
        }
    }
}

class Book: NSObject {
    
    var title: String
    var author: String
    var image: UIImage
    var summary: String
    
    init(title: String, author: String, image: UIImage, summary: String) {
        self.title = title
        self.author = author
        self.image = image
        self.summary = summary
        super.init()
    }
}