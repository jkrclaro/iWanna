//
//  MovieDetailsController.swift
//
//
//  Created by John Claro on 19/03/2016.
//
//

import UIKit
import Foundation
import CoreData

class MovieDetailsController: UIViewController {
    
    @IBOutlet weak var movieDetailsTitle: UILabel!
    @IBOutlet weak var movieDetailsDirector: UILabel!
    @IBOutlet weak var movieDetailsPlot: UILabel!
    @IBOutlet weak var movieDetailsImage: UIImageView!
    @IBOutlet weak var movieDetailsReleaseDate: UILabel!
    @IBOutlet weak var movieDetailsRating: UILabel!
    @IBOutlet weak var movieDetailsSaveButton: UIBarButtonItem!
    
    var selectedMovie = Movie(title: "", director: "", image: UIImage(named: "NoBookCover")!, plot: "", releaseDate: "", rating: "0.0")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        movieDetailsTitle.text = selectedMovie.title
        movieDetailsDirector.text = selectedMovie.director
        movieDetailsPlot.text = selectedMovie.plot
        movieDetailsImage.image = selectedMovie.image
        movieDetailsReleaseDate.text = selectedMovie.releaseDate
        movieDetailsRating.text = selectedMovie.rating
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let myMoviesRequest = NSFetchRequest(entityName: "MyMovies")
        myMoviesRequest.predicate = NSPredicate(format: "title == %@", selectedMovie.title)
        myMoviesRequest.predicate = NSPredicate(format: "director == %@", selectedMovie.director)
        myMoviesRequest.predicate = NSPredicate(format: "plot == %@", selectedMovie.plot)
        myMoviesRequest.predicate = NSPredicate(format: "rating == %@", selectedMovie.rating)
        myMoviesRequest.predicate = NSPredicate(format: "title == %@ and director == %@ and plot == %@ and rating == %@ and releaseDate == %@", selectedMovie.title, selectedMovie.director, selectedMovie.plot, selectedMovie.rating, selectedMovie.releaseDate)
        do {
            let fetchedMovies = try managedContext.executeFetchRequest(myMoviesRequest)
            if fetchedMovies.count > 0 {
                movieDetailsSaveButton.enabled = false
            }
        } catch {
            fatalError("Failed to fetch movies: \(error)")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}