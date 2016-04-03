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
import CoreData

class BooksController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var booksTable: UITableView!
    @IBOutlet weak var booksSearchBar: UISearchBar!
    
    var selectedBook = Book(title: "", author: "", image: UIImage(named: "NoBookCover")!, summary: "", publishedDate: "", rating: 0.0)
    var booksSearchResults = [Book]()
    var myBooks = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if booksSearchBar.text == "" {
            return myBooks.count
        } else {
            return booksSearchResults.count
        }
    }
    
    // Do something when search bar search button is clicked
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        booksSearchBar.resignFirstResponder()
        self.updateSearchBar()
    }
    
    func updateSearchBar() {
        let validKeyword = booksSearchBar.text!.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())
        let validBookURL = "https://www.googleapis.com/books/v1/volumes?q=" + validKeyword! + "&key=AIzaSyCLO9SKNd0GDTtPKpavS0yoFPoBS4FH3HE"
        
        Alamofire.request(.GET, validBookURL).responseJSON { (responseData) -> Void in
            let data = JSON(responseData.result.value!)
            self.booksSearchResults.removeAll(keepCapacity: false)
            
            self.refreshTable()
            
            for (_, bookDetails) in data["items"] {
                if let title = bookDetails["volumeInfo"]["title"].string {
                    if title.lowercaseString.containsString(self.booksSearchBar.text!.lowercaseString) {
                        var author = bookDetails["volumeInfo"]["authors"].first?.1.string
                        if author != nil {
                            author = bookDetails["volumeInfo"]["authors"].first!.1.string
                        } else {
                            author = "N/A"
                        }
                        
                        var summary = bookDetails["volumeInfo"]["description"].string
                        if summary != nil {
                            summary = bookDetails["volumeInfo"]["description"].string
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
                                self.booksSearchResults.append(Book(title: title, author: author!, image: image, summary: summary!, publishedDate: publishedDate!, rating: rating!))
                                self.refreshTable()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func refreshTable() {
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
        booksSearchResults.removeAll(keepCapacity: false)
        booksTable.reloadData()
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        booksSearchBar.resignFirstResponder()
        booksSearchBar.text = ""
        booksSearchResults.removeAll(keepCapacity: false)
        booksTable.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "MyBooks")
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            myBooks = results as! [NSManagedObject]
        }
        catch {
            print("Error")
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BookCell", forIndexPath: indexPath) as! BookCell

        if booksSearchBar.text == "" {
            let book = myBooks[indexPath.row]
            cell.bookTitle.text = book.valueForKey("title") as? String
            cell.bookAuthor.text = book.valueForKey("author") as? String
            cell.bookRating.image = self.imageForRating(book.valueForKey("rating") as! Double)
            cell.bookPublishedDate.text = book.valueForKey("publishedDate") as? String
            
            let paths: NSArray = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
            let documentsDir: NSString = paths.objectAtIndex(0) as! NSString
            let path: NSString = documentsDir.stringByAppendingString(book.valueForKey("coverImageFullURL") as! String)
            let bookCoverImage = UIImage(contentsOfFile: path as String)
            cell.bookImage.image = bookCoverImage
            
        } else {
            let book = self.booksSearchResults[indexPath.row] as Book // Pressing cancel while searching gives error
            cell.bookTitle.text = book.title
            cell.bookAuthor.text = book.author
            cell.bookImage.image = book.image
            cell.bookPublishedDate.text = book.publishedDate
            cell.bookRating.image = self.imageForRating(book.rating)
        }
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "bookDetailSelected" {
            if let destination = segue.destinationViewController as? BookDetailsController {
                let path = booksTable.indexPathForSelectedRow
                if booksSearchBar.text == "" {
                    let myBook = myBooks[path!.row]
                    let paths: NSArray = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
                    let documentsDir: NSString = paths.objectAtIndex(0) as! NSString
                    let path: NSString = documentsDir.stringByAppendingString(myBook.valueForKey("coverImageFullURL") as! String)
                    let myBookCoverImage = UIImage(contentsOfFile: path as String)
                    
                    let selectedMyBook = Book(title: myBook.valueForKey("title") as! String, author: myBook.valueForKey("author") as! String, image: myBookCoverImage!, summary: myBook.valueForKey("summary") as! String, publishedDate: myBook.valueForKey("publishedDate") as! String, rating: myBook.valueForKey("rating") as! Double)
                    
                    destination.selectedBook = selectedMyBook
                    selectedBook = selectedMyBook
                } else {
                    let book = self.booksSearchResults[path!.row] as Book
                    destination.selectedBook = book
                    selectedBook = book
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if booksSearchBar.text == "" {
            return true
        } else {
            return false
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if(editingStyle == UITableViewCellEditingStyle.Delete) {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext
            managedContext.deleteObject(myBooks[indexPath.row])
            myBooks.removeAtIndex(indexPath.row)
            do {
                try managedContext.save()
            } catch {
                fatalError("Failed to save deletion of book: \(error)")
            }
            self.booksTable.reloadData()
        }
    }
    
    @IBAction func cancelToBooksController(segue: UIStoryboardSegue) {
    }
    
    @IBAction func saveBookDetails(segue: UIStoryboardSegue) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let entity = NSEntityDescription.entityForName("MyBooks", inManagedObjectContext: managedContext)
        let item = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        
        let paths: NSArray = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDir: NSString = paths.objectAtIndex(0) as! NSString
        let dateFormat = NSDateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let now: NSDate = NSDate(timeIntervalSinceNow: 0)
        let theDate: NSString = dateFormat.stringFromDate(now)
        let coverImageFullURL = NSString(format: "/%@.png", theDate) 
        let pathFull: NSString = documentsDir.stringByAppendingString(coverImageFullURL as String)
        let pngFullData: NSData = UIImagePNGRepresentation(selectedBook.image)!
        pngFullData.writeToFile(pathFull as String, atomically: true)
        
        item.setValue(selectedBook.title, forKey: "title")
        item.setValue(selectedBook.publishedDate, forKey: "publishedDate")
        item.setValue(selectedBook.rating, forKey: "rating")
        item.setValue(selectedBook.summary, forKey: "summary")
        item.setValue(selectedBook.author, forKey: "author")
        item.setValue(coverImageFullURL, forKey: "coverImageFullURL")
        do {
            try managedContext.save()
            myBooks.append(item)
            self.booksTable.reloadData()
        }
        catch {
            print("Error")
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