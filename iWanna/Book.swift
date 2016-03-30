//
//  Book.swift
//  iWanna
//
//  Created by John Claro on 29/03/2016.
//  Copyright © 2016 jkrclaro. All rights reserved.
//

import UIKit

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
