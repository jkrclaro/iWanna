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
    
    var viaSegueBookTitle = ""
    var viaSegueBookAuthor = ""
    var viaSegueBookSummary = ""
    var viaSegueBookImage = UIImage(named: "ExampleBook")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bookDetailsTitle.text = viaSegueBookTitle
        bookDetailsAuthor.text = viaSegueBookAuthor
        bookDetailsSummary.text = viaSegueBookSummary
        bookDetailsImage.image = viaSegueBookImage
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}