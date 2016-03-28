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
                        let author = bookDetails["volumeInfo"]["authors"].first!.1.string!
                        
                        var summary = bookDetails["volumeInfo"]["description"].string
                        if summary != nil {
                            summary = bookDetails["volumeInfo"]["description"].string!
                        } else {
                            summary = "N/A"
                        }
                        
                        var imageURL = bookDetails["volumeInfo"]["imageLinks"]["smallThumbnail"].string
                        if imageURL != nil {
                            imageURL = imageURL!.stringByReplacingOccurrencesOfString("http:", withString: "https:")
                        } else {
                            imageURL = "https://books.google.ie/books/content?id=&printsec=frontcover&img=1&zoom=5&source=gbs_api"
                        }
                        
                        var publishedDate = bookDetails["volumeInfo"]["publishedDate"].string
                        if publishedDate != nil {
                            publishedDate = bookDetails["volumeInfo"]["publishedDate"].string
                        } else {
                            publishedDate = "N/A"
                        }
                        
                        var rating = bookDetails["volumeInfo"]["averageRating"].double
                        if rating != nil {
                            rating = bookDetails["volumeInfo"]["averageRating"].double
                        } else {
                            rating = 0.0
                        }
                        
                        Alamofire.request(.GET, imageURL!).responseImage { response in
                            if let image = response.result.value {
                                self.booksSearchResults.append(Book(title: title, author: author, image: image, summary: summary!, publishedDate: publishedDate!, rating: rating!))
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
        cell.bookPublishedDate.text = book.publishedDate
        cell.bookRating.image = self.imageForRating(book.rating)
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
    
    func imageForRating(rating:Double) -> UIImage? {
        switch rating {
        case 0.0:
            return UIImage(named: "0stars")
        case 0.5:
            return UIImage(named: "0-5stars")
        case 1.0:
            return UIImage(named: "1stars")
        case 1.5:
            return UIImage(named: "1-5stars")
        case 2.0:
            return UIImage(named: "2stars")
        case 2.5:
            return UIImage(named: "2-5stars")
        case 3.0:
            return UIImage(named: "3stars")
        case 3.5:
            return UIImage(named: "3-5stars")
        case 4.0:
            return UIImage(named: "4stars")
        case 4.5:
            return UIImage(named: "4-5stars")
        case 5.0:
            return UIImage(named: "5stars")
        default:
            return nil
        }
        
    }
}

class Book: NSObject {
    
    var title: String
    var author: String
    var image: UIImage
    var summary: String
    var publishedDate: String
    var rating: Double
    
    init(title: String, author: String, image: UIImage, summary: String, publishedDate: String, rating: Double) {
        self.title = title
        self.author = author
        self.image = image
        self.summary = summary
        self.publishedDate = publishedDate
        self.rating = rating
        super.init()
    }
}