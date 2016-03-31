//
//  BookDetailsController.swift
//
//
//  Created by John Claro on 19/03/2016.
//
//

import UIKit
import Foundation
import CoreData

class BookDetailsController: UIViewController {
    
    @IBOutlet weak var bookDetailsTitle: UILabel!
    @IBOutlet weak var bookDetailsAuthor: UILabel!
    @IBOutlet weak var bookDetailsSummary: UILabel!
    @IBOutlet weak var bookDetailsImage: UIImageView!
    @IBOutlet weak var bookDetailsPublishedDate: UILabel!
    @IBOutlet weak var bookDetailsRating: UIImageView!
    @IBOutlet weak var bookDetailsSaveButton: UIBarButtonItem!
    
    var selectedBook = Book(title: "", author: "", image: UIImage(named: "ExampleBook")!, summary: "", publishedDate: "", rating: 0.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bookDetailsTitle.text = selectedBook.title
        bookDetailsAuthor.text = selectedBook.author
        bookDetailsSummary.text = selectedBook.summary
        bookDetailsImage.image = selectedBook.image
        bookDetailsPublishedDate.text = selectedBook.publishedDate
        bookDetailsRating.image = self.imageForRating(selectedBook.rating)
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let myBooksRequest = NSFetchRequest(entityName: "MyBooks")
        myBooksRequest.predicate = NSPredicate(format: "title == %@", selectedBook.title)
        myBooksRequest.predicate = NSPredicate(format: "author == %@", selectedBook.author)
        myBooksRequest.predicate = NSPredicate(format: "summary == %@", selectedBook.summary)
        myBooksRequest.predicate = NSPredicate(format: "rating == %@", selectedBook.rating)
        myBooksRequest.predicate = NSPredicate(format: "title == %@ and author == %@ and summary == %@ and rating == %@ and publishedDate == %@", selectedBook.title, selectedBook.author, selectedBook.summary, "\(selectedBook.rating)", selectedBook.publishedDate)
        do {
            let fetchedBooks = try managedContext.executeFetchRequest(myBooksRequest)
            if fetchedBooks.count > 0 {
                bookDetailsSaveButton.enabled = false
            }
        } catch {
            fatalError("Failed to fetch books: \(error)")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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