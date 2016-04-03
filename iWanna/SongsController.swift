//
//  SongsController.swift
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

class SongsController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var songsTable: UITableView!
    @IBOutlet weak var songsSearchBar: UISearchBar!
    
    var selectedSong = Song(title: "", artist: "", image: UIImage(named: "NoBookCover")!, popularity: "")
    var songsSearchResults = [Song]()
    var mySongs = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if songsSearchBar.text == "" {
            return mySongs.count
        } else {
            return songsSearchResults.count
        }
    }
    
    // Do something when search bar search button is clicked
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        songsSearchBar.resignFirstResponder()
        self.updateSearchBar()
    }
    
    func updateSearchBar() {
        let validKeyword = songsSearchBar.text!.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())
        let validSongURL = "https://api.spotify.com/v1/search?query=" + validKeyword! + "&offset=0&limit=50&type=track"
        
        dispatch_async(dispatch_get_main_queue(), {
            self.songsSearchResults.sortInPlace({$0.title < $1.title}) // Sort the results alphabetically
            self.songsTable.reloadData()
            self.songsSearchBar.resignFirstResponder()
        })
        
        Alamofire.request(.GET, validSongURL).responseJSON { (responseData) -> Void in
            let data = JSON(responseData.result.value!)
            self.songsSearchResults.removeAll(keepCapacity: false)
            
            self.refreshTable()

            
            for (_, details) in data["tracks"]["items"] {
                if let title = details["name"].string {
                    if title.lowercaseString == self.songsSearchBar.text!.lowercaseString {
                        var artists = ""
                        for (key, artistDetails) in details["artists"] {
                            if (key == "0") {
                                artists += artistDetails["name"].string!
                            } else {
                                artists += ", " + artistDetails["name"].string!
                            }
                        }
                        
                        var popularity = details["popularity"].rawString()
                        if popularity != nil {
                            popularity = "Popularity: " + popularity! + "/100"
                        } else {
                            popularity = "N/A"
                        }
                        
                        let imageURL = details["album"]["images"][1]["url"].string!
                        
                        Alamofire.request(.GET, imageURL).responseImage { response in
                            if let image = response.result.value {
                                self.songsSearchResults.append(Song(title: title, artist: artists, image: image, popularity: popularity!))
                                self.refreshTable()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func refreshTable() {
        dispatch_async(dispatch_get_main_queue(), {
            self.songsSearchResults.sortInPlace({$0.title < $1.title}) // Sort the results alphabetically
            self.songsTable.reloadData()
            self.songsSearchBar.resignFirstResponder()
        })
    }
    
    // Do something when search bar cancel button is clicked
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        songsSearchBar.resignFirstResponder()
        songsSearchBar.text = ""
        songsSearchResults.removeAll(keepCapacity: false)
        songsTable.reloadData()
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        songsSearchBar.resignFirstResponder()
        songsSearchBar.text = ""
        songsSearchResults.removeAll(keepCapacity: false)
        songsTable.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "MySongs")
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            mySongs = results as! [NSManagedObject]
        }
        catch {
            print("Error")
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SongCell", forIndexPath: indexPath) as! SongCell
        
        if songsSearchBar.text == "" {
            let song = mySongs[indexPath.row]
            cell.songTitle.text = song.valueForKey("title") as? String
            cell.songArtist.text = song.valueForKey("artist") as? String
            cell.songPopularity.text = song.valueForKey("popularity") as? String
            
            let paths: NSArray = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
            let documentsDir: NSString = paths.objectAtIndex(0) as! NSString
            let path: NSString = documentsDir.stringByAppendingString(song.valueForKey("songImageFullURL") as! String)
            let songCoverImage = UIImage(contentsOfFile: path as String)
            cell.songImage.image = songCoverImage
            
        } else {
            let song = self.songsSearchResults[indexPath.row] as Song
            cell.songTitle.text = song.title
            cell.songArtist.text = song.artist
            cell.songImage.image = song.image
            cell.songPopularity.text = song.popularity
        }
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "songDetailSelected" {
            if let destination = segue.destinationViewController as? SongDetailsController {
                let path = songsTable.indexPathForSelectedRow
                if songsSearchBar.text == "" {
                    let mySong = mySongs[path!.row]
                    let paths: NSArray = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
                    let documentsDir: NSString = paths.objectAtIndex(0) as! NSString
                    let path: NSString = documentsDir.stringByAppendingString(mySong.valueForKey("songImageFullURL") as! String)
                    let mySongCoverImage = UIImage(contentsOfFile: path as String)
                    
                    let selectedMySong = Song(title: mySong.valueForKey("title") as! String, artist: mySong.valueForKey("artist") as! String, image: mySongCoverImage!, popularity: mySong.valueForKey("popularity") as! String)
                    
                    destination.selectedSong = selectedMySong
                    selectedSong = selectedMySong
                } else {
                    let song = self.songsSearchResults[path!.row] as Song
                    destination.selectedSong = song
                    selectedSong = song
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if songsSearchBar.text == "" {
            return true
        } else {
            return false
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if(editingStyle == UITableViewCellEditingStyle.Delete) {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext
            managedContext.deleteObject(mySongs[indexPath.row])
            mySongs.removeAtIndex(indexPath.row)
            do {
                try managedContext.save()
            } catch {
                fatalError("Failed to save deletion of book: \(error)")
            }
            self.songsTable.reloadData()
        }
    }
    
    @IBAction func cancelToSongsController(segue: UIStoryboardSegue) {
    }
    
    @IBAction func saveSongDetails(segue: UIStoryboardSegue) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let entity = NSEntityDescription.entityForName("MySongs", inManagedObjectContext: managedContext)
        let item = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        
        let paths: NSArray = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDir: NSString = paths.objectAtIndex(0) as! NSString
        let dateFormat = NSDateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let now: NSDate = NSDate(timeIntervalSinceNow: 0)
        let theDate: NSString = dateFormat.stringFromDate(now)
        let songImageFullURL = NSString(format: "/%@.png", theDate)
        let pathFull: NSString = documentsDir.stringByAppendingString(songImageFullURL as String)
        let pngFullData: NSData = UIImagePNGRepresentation(selectedSong.image)!
        pngFullData.writeToFile(pathFull as String, atomically: true)
        
        item.setValue(selectedSong.title, forKey: "title")
        item.setValue(selectedSong.popularity, forKey: "popularity")
        item.setValue(selectedSong.artist, forKey: "artist")
        item.setValue(songImageFullURL, forKey: "songImageFullURL")
        do {
            try managedContext.save()
            mySongs.append(item)
            self.songsTable.reloadData()
        }
        catch {
            print("Error")
        }
    }
}