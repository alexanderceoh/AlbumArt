//
//  AlbumDetailViewController.swift
//  AlbumArt
//
//  Created by alex oh on 10/13/15.
//  Copyright © 2015 alex oh. All rights reserved.
//

import UIKit
import AFNetworking

class AlbumDetailViewController: UIViewController {

    var albumInfo: Album!
    
    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var albumNameLabel: UILabel!
    @IBOutlet weak var tracksTableView: UITableView!
    
    let tracksData = TracksDataSource()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tracksTableView.dataSource = tracksData
        
        albumNameLabel.text = albumInfo.albumName
        
        albumImageView.image = albumInfo.albumImage ?? albumInfo.getImage()
        
        print(albumInfo.albumID)
        
        if let albumID = albumInfo.albumID {
            
            tracksData.findTracksForAlbum("\(albumID)", completion: { () -> () in
                
                // update tableView
                self.tracksTableView.reloadData()
                
            })
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

class TracksDataSource: NSObject, UITableViewDataSource {
    
    var tracks: [Track] = []
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return tracks.count
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("TrackCell", forIndexPath: indexPath) as! TrackCell
        
        let track = tracks[indexPath.row]
        
        cell.trackInfo = track
        
        // can only use trackNameLabel here because of the line (as! TrackCell) above when you declared cell.
        cell.trackNameLabel.text = track.trackName
        
        return cell
        
    }
    
    let requestManager = AFHTTPRequestOperationManager()
    
    func findTracksForAlbum(albumID: String, completion: () -> ()) {
        
        tracks = []
        
        let urlString = "https://itunes.apple.com/lookup?id=\(albumID)&entity=song"
                
        requestManager.GET(urlString, parameters: nil, success: { (operation, data) -> Void in
            
            if let foundInfo = data as? Dict {
                
                if let results = foundInfo["results"] as? [Dict] {
                    
                    for result in results {
                        
                        // if it does not have trackName we will ignore it. (the first dataset is for the album)
                        if result["trackName"] != nil {
                            
                            let track = Track(info: result)
                            self.tracks.append(track)
                            
                        }
                        
//                        let album = Album(info: result)
//                        self.albums.append(album)
                        
                    }
                    
                    completion()
                    
                }
                
            }
            
            }) { (operation, error) -> Void in
                
            print(error)
        }
        
    }
    
}

class Track: NSObject {
    
    var trackName: String?
    var trackNumber: Int?
    var trackPrice: Double?
    var mediaURL: String?
    var mediaData: NSData?
    
    var trackViewURL: String?
    
    init(info: Dict) {
        
        trackName = info["trackName"] as? String
        trackNumber = info["trackNumber"] as? Int
        trackPrice = info["trackPrice"] as? Double
        mediaURL = info["previewUrl"] as? String
        trackViewURL = info["trackViewUrl"] as? String
        
    }
    
    func getMedia() -> NSData? {
        
        if let mediaDataURL = NSURL(string: mediaURL ?? "") {
            
            mediaData = NSData(contentsOfURL: mediaDataURL)
            return mediaData
            
            }
        
        return nil
        
    }
    
}
