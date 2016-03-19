//
//  SongsController.swift
//  iWanna
//
//  Created by John Claro on 18/03/2016.
//  Copyright © 2016 jkrclaro. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class SongsController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var songsTable: UITableView!
    @IBOutlet weak var songsSearchBar: UISearchBar!
    
    var songsSearchResults = [Song]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songsSearchResults.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SongCell", forIndexPath: indexPath) as! SongCell
        let song = songsSearchResults[indexPath.row] as Song
        cell.songTitle.text = song.title
        cell.songArtist.text = song.artist
        return cell
    }
    
    // Do something when search bar search button is clicked
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        songsSearchBar.resignFirstResponder()
        
        let validKeyword = songsSearchBar.text!.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())
        let validURL = "https://www.googleapis.com/books/v1/volumes?q=" + validKeyword! + "&key=AIzaSyCLO9SKNd0GDTtPKpavS0yoFPoBS4FH3HE"
        
        Alamofire.request(.GET, validURL).responseJSON { (responseData) -> Void in
            let data = JSON(responseData.result.value!)
            
            self.songsSearchResults.removeAll(keepCapacity: false)
            
            for (_, subData) in data["items"] {
                if let title = subData["volumeInfo"]["title"].string {
                    let isEqual = (title.lowercaseString == self.songsSearchBar.text?.lowercaseString)
                    if isEqual {
                        self.songsSearchResults.append(Song(title: title, artist: "Nikola Tesla"))
                    }
                }
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                self.songsTable.reloadData()
                self.songsSearchBar.resignFirstResponder()
            }
        }
    }
    
    // Do something when search bar cancel button is clicked
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        songsSearchBar.resignFirstResponder()
        songsSearchBar.text = ""
    }
    
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        songsSearchBar.resignFirstResponder()
        songsSearchBar.text = ""
        songsSearchResults.removeAll(keepCapacity: false)
        songsTable.reloadData()
    }
}

class Song: NSObject {
    
    var title: String
    var artist: String
    
    init(title: String, artist: String) {
        self.title = title
        self.artist = artist
        super.init()
    }
}
