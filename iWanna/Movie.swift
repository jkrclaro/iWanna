//
//  Movie.swift
//  iWanna
//
//  Created by John Claro on 01/04/2016.
//  Copyright © 2016 jkrclaro. All rights reserved.
//

import UIKit

class Movie: NSObject {
    
    var title: String
    var director: String
    var image: UIImage
    var plot: String
    var releaseDate: String
    var rating: String
    
    init(title: String, director: String, image: UIImage, plot: String, releaseDate: String, rating: String) {
        self.title = title
        self.director = director
        self.image = image
        self.plot = plot
        self.releaseDate = releaseDate
        self.rating = rating
        super.init()
    }
}
