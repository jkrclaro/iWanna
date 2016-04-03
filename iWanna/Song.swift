//
//  Song.swift
//  iWanna
//
//  Created by John Claro on 01/04/2016.
//  Copyright © 2016 jkrclaro. All rights reserved.
//

import UIKit

class Song: NSObject {
    
    var title: String
    var artist: String
    var image: UIImage
    var popularity: String
    
    init(title: String, artist: String, image: UIImage, popularity: String) {
        self.title = title
        self.artist = artist
        self.image = image
        self.popularity = popularity
        super.init()
    }
}