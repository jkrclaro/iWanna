//
//  BookDetailsController.swift
//
//
//  Created by John Claro on 19/03/2016.
//
//

import UIKit
import Foundation

class BookDetailsController: UIViewController {
    
    @IBOutlet weak var bookDetailsTitle: UILabel!
    @IBOutlet weak var bookDetailsAuthor: UILabel!
    @IBOutlet weak var bookDetailsSummary: UILabel!
    @IBOutlet weak var bookDetailsImage: UIImageView!
    
    var selectedBook = Book(title: "", author: "", image: UIImage(named: "ExampleBook")!, summary: "", publishedDate: "", rating: 0.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bookDetailsTitle.text = selectedBook.title
        bookDetailsAuthor.text = selectedBook.author
        bookDetailsSummary.text = selectedBook.summary
        bookDetailsImage.image = selectedBook.image
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}