//
//  SongDetailsController.swift
//
//
//  Created by John Claro on 19/03/2016.
//
//

import UIKit
import Foundation
import CoreData

class SongDetailsController: UIViewController {
    
    @IBOutlet weak var songDetailsTitle: UILabel!
    @IBOutlet weak var songDetailsArtist: UILabel!
    @IBOutlet weak var songDetailsImage: UIImageView!
    @IBOutlet weak var songDetailsPopularity: UILabel!
    @IBOutlet weak var songDetailsSaveButton: UIBarButtonItem!
    
    var selectedSong = Song(title: "", artist: "", image: UIImage(named: "NoBookCover")!, popularity: "0.0")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        songDetailsTitle.text = selectedSong.title
        songDetailsArtist.text = selectedSong.artist
        songDetailsImage.image = selectedSong.image
        songDetailsPopularity.text = selectedSong.popularity
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let mySongsRequest = NSFetchRequest(entityName: "MySongs")
        mySongsRequest.predicate = NSPredicate(format: "title == %@ and artist == %@ and popularity == %@", selectedSong.title, selectedSong.artist, selectedSong.popularity)
        do {
            let fetchedSongs = try managedContext.executeFetchRequest(mySongsRequest)
            if fetchedSongs.count > 0 {
                songDetailsSaveButton.enabled = false
            }
        } catch {
            fatalError("Failed to fetch songs: \(error)")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}