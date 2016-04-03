//
//  MoviesController.swift
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

class MoviesController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var moviesTable: UITableView!
    @IBOutlet weak var moviesSearchBar: UISearchBar!
    
    var selectedMovie = Movie(title: "", director: "", image: UIImage(named: "NoBookCover")!, plot: "", releaseDate: "", rating: "")
    var moviesSearchResults = [Movie]()
    var myMovies = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if moviesSearchBar.text == "" {
            return myMovies.count
        } else {
            return moviesSearchResults.count
        }
    }
    
    // Do something when search bar search button is clicked
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        moviesSearchBar.resignFirstResponder()
        self.updateSearchBar()
    }
    
    func updateSearchBar() {
        let validKeyword = moviesSearchBar.text!.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())
        let validMovieURL = "https://www.omdbapi.com/?t=" + validKeyword! + "&y=&plot=full&r=json"
        
        Alamofire.request(.GET, validMovieURL).responseJSON { (responseData) -> Void in
            let data = JSON(responseData.result.value!)
            self.moviesSearchResults.removeAll(keepCapacity: false)
            
            self.refreshTable()
            
            if let title = data["Title"].string {
                var director = data["Director"].string
                if director != nil {
                    director = data["Director"].string!
                } else {
                    director = "N/A"
                }
                
                var releaseDate = data["Released"].string
                if releaseDate != nil {
                    releaseDate = data["Released"].string!
                } else {
                    releaseDate = "N/A"
                }
                
                var plot = data["Plot"].string
                if plot != nil {
                    plot = data["Plot"].string!
                } else {
                    plot = "N/A"
                }
                
                var rating = data["imdbRating"].string
                if rating != nil {
                    rating = "imdbRating: " + data["imdbRating"].string!
                } else {
                    rating = "0.0"
                }
                
                var posterImageURL = data["Poster"].string
                if posterImageURL != nil {
                    posterImageURL = data["Poster"].string!
                    posterImageURL = posterImageURL!.stringByReplacingOccurrencesOfString("http:", withString: "https:")
                } else {
                    posterImageURL = ""
                }
                
                if posterImageURL != "" {
                    Alamofire.request(.GET, posterImageURL!).responseImage { response in
                        if let image = response.result.value {
                            self.moviesSearchResults.append(Movie(title: title, director: director!, image: image, plot: plot!, releaseDate: releaseDate!, rating: rating!))
                            self.refreshTable()
                        }
                    }
                } else {
                    self.moviesSearchResults.append(Movie(title: title, director: director!, image: UIImage(named: "NoBookCover")!, plot: plot!, releaseDate: releaseDate!, rating: rating!))
                    self.refreshTable()
                }
            }
            
            self.refreshTable()
        }
    }
    
    func refreshTable() {
        dispatch_async(dispatch_get_main_queue(), {
            self.moviesSearchResults.sortInPlace({$0.title < $1.title}) // Sort the results alphabetically
            self.moviesTable.reloadData()
            self.moviesSearchBar.resignFirstResponder()
        })
    }
    
    // Do something when search bar cancel button is clicked
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        moviesSearchBar.resignFirstResponder()
        moviesSearchBar.text = ""
        moviesSearchResults.removeAll(keepCapacity: false)
        moviesTable.reloadData()
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        moviesSearchBar.resignFirstResponder()
        moviesSearchBar.text = ""
        moviesSearchResults.removeAll(keepCapacity: false)
        moviesTable.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "MyMovies")
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            myMovies = results as! [NSManagedObject]
        }
        catch {
            print("Error")
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        if moviesSearchBar.text == "" {
            let movie = myMovies[indexPath.row]
            cell.movieTitle.text = movie.valueForKey("title") as? String
            cell.movieDirector.text = movie.valueForKey("director") as? String
            cell.movieRating.text = movie.valueForKey("rating") as? String
            cell.movieReleaseDate.text = movie.valueForKey("releaseDate") as? String
            
            let paths: NSArray = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
            let documentsDir: NSString = paths.objectAtIndex(0) as! NSString
            let path: NSString = documentsDir.stringByAppendingString(movie.valueForKey("posterImageFullURL") as! String)
            let movieCoverImage = UIImage(contentsOfFile: path as String)
            cell.movieImage.image = movieCoverImage
            
        } else {
            let movie = self.moviesSearchResults[indexPath.row] as Movie // Pressing cancel while searching gives error
            cell.movieTitle.text = movie.title
            cell.movieDirector.text = movie.director
            cell.movieImage.image = movie.image
            cell.movieReleaseDate.text = movie.releaseDate
            cell.movieRating.text = movie.rating
        }
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "movieDetailSelected" {
            if let destination = segue.destinationViewController as? MovieDetailsController {
                let path = moviesTable.indexPathForSelectedRow
                if moviesSearchBar.text == "" {
                    let myMovie = myMovies[path!.row]
                    let paths: NSArray = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
                    let documentsDir: NSString = paths.objectAtIndex(0) as! NSString
                    let path: NSString = documentsDir.stringByAppendingString(myMovie.valueForKey("posterImageFullURL") as! String)
                    let myMovieCoverImage = UIImage(contentsOfFile: path as String)
                    
                    let selectedMyMovie = Movie(title: myMovie.valueForKey("title") as! String, director: myMovie.valueForKey("director") as! String, image: myMovieCoverImage!, plot: myMovie.valueForKey("plot") as! String, releaseDate: myMovie.valueForKey("releaseDate") as! String, rating: myMovie.valueForKey("rating") as! String)
                    
                    destination.selectedMovie = selectedMyMovie
                    selectedMovie = selectedMyMovie
                } else {
                    let movie = self.moviesSearchResults[path!.row] as Movie // Search -> Search incorrect -> Click row -> Error!
                    destination.selectedMovie = movie
                    selectedMovie = movie
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if moviesSearchBar.text == "" {
            return true
        } else {
            return false
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if(editingStyle == UITableViewCellEditingStyle.Delete) {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext
            managedContext.deleteObject(myMovies[indexPath.row])
            myMovies.removeAtIndex(indexPath.row)
            do {
                try managedContext.save()
            } catch {
                fatalError("Failed to save deletion of book: \(error)")
            }
            self.moviesTable.reloadData()
        }
    }
    
    @IBAction func cancelToMoviesController(segue: UIStoryboardSegue) {
    }
    
    @IBAction func saveMovieDetails(segue: UIStoryboardSegue) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let entity = NSEntityDescription.entityForName("MyMovies", inManagedObjectContext: managedContext)
        let item = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        
        let paths: NSArray = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDir: NSString = paths.objectAtIndex(0) as! NSString
        let dateFormat = NSDateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let now: NSDate = NSDate(timeIntervalSinceNow: 0)
        let theDate: NSString = dateFormat.stringFromDate(now)
        let posterImageFullURL = NSString(format: "/%@.png", theDate)
        let pathFull: NSString = documentsDir.stringByAppendingString(posterImageFullURL as String)
        let pngFullData: NSData = UIImagePNGRepresentation(selectedMovie.image)!
        pngFullData.writeToFile(pathFull as String, atomically: true)
        
        item.setValue(selectedMovie.title, forKey: "title")
        item.setValue(selectedMovie.releaseDate, forKey: "releaseDate")
        item.setValue(selectedMovie.rating, forKey: "rating")
        item.setValue(selectedMovie.plot, forKey: "plot")
        item.setValue(selectedMovie.director, forKey: "director")
        item.setValue(posterImageFullURL, forKey: "posterImageFullURL")
        do {
            try managedContext.save()
            myMovies.append(item)
            self.moviesTable.reloadData()
        }
        catch {
            print("Error")
        }
    }
}