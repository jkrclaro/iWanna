//
//  MoviesController.swift
//  iWanna
//
//  Created by John Claro on 18/03/2016.
//  Copyright © 2016 jkrclaro. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class MoviesController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var moviesTable: UITableView!
    @IBOutlet weak var moviesSearchBar: UISearchBar!
    
    var moviesSearchResults = [Movie]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return moviesSearchResults.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        let movie = moviesSearchResults[indexPath.row] as Movie
        cell.movieTitle.text = movie.title
        cell.movieDirector.text = movie.director
        return cell
    }
    
    // Do something when search bar search button is clicked
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        moviesSearchBar.resignFirstResponder()
        
        let validKeyword = moviesSearchBar.text!.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())
        let validURL = "https://www.googleapis.com/books/v1/volumes?q=" + validKeyword! + "&key=AIzaSyCLO9SKNd0GDTtPKpavS0yoFPoBS4FH3HE"
        
        Alamofire.request(.GET, validURL).responseJSON { (responseData) -> Void in
            let data = JSON(responseData.result.value!)
            
            self.moviesSearchResults.removeAll(keepCapacity: false)
            
            for (_, subData) in data["items"] {
                if let title = subData["volumeInfo"]["title"].string {
                    let isEqual = (title.lowercaseString == self.moviesSearchBar.text?.lowercaseString)
                    if isEqual {
                        self.moviesSearchResults.append(Movie(title: title, director: "Nikola Tesla"))
                    }
                }
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                self.moviesTable.reloadData()
                self.moviesSearchBar.resignFirstResponder()
            }
        }
    }
    
    // Do something when search bar cancel button is clicked
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        moviesSearchBar.resignFirstResponder()
        moviesSearchBar.text = ""
    }
    
    // Do something when refresh button is tapped
    @IBAction func refreshButtonTapped(sender: AnyObject) {
        moviesSearchBar.resignFirstResponder()
        moviesSearchBar.text = ""
        moviesSearchResults.removeAll(keepCapacity: false)
        moviesTable.reloadData()
    }
}

class Movie: NSObject {
    
    var title: String
    var director: String
    
    init(title: String, director: String) {
        self.title = title
        self.director = director
        super.init()
    }
}

