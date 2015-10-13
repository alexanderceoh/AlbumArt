//
//  ViewController.swift
//  AlbumArt
//
//  Created by alex oh on 10/13/15.
//  Copyright © 2015 alex oh. All rights reserved.
//

import UIKit
import AFNetworking

typealias Dict = [String:AnyObject]

class AlbumsViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var albumSearchBar: UISearchBar!
    @IBOutlet weak var albumsCollectionView: UICollectionView!
    
    let albumData = AlbumsDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        albumSearchBar.delegate = self
        
        albumsCollectionView.dataSource = albumData
        
        albumData.searchForAlbum("daft punk") { () -> () in
            
            self.albumsCollectionView.reloadData()
            
        }

    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        let searchText = searchBar.text ?? ""
        
        albumData.searchForAlbum(searchText) { () -> () in
            
            self.albumsCollectionView.reloadData()
        
        }
        
        searchBar.resignFirstResponder()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let cell = sender as! AlbumCell
        
        let detailVC = segue.destinationViewController as! AlbumDetailViewController
        
        detailVC.albumInfo = cell.albumInfo
        
    }
  
}

class AlbumsDataSource: NSObject, UICollectionViewDataSource {
    
    var albums: [Album] = []
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albums.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("AlbumCell", forIndexPath: indexPath) as! AlbumCell
        
        let album = albums[indexPath.item]
        
        cell.albumInfo = album
        
        // add back image
        
        // if we have the image, reuse the image. If not then getImage().
        cell.albumImageView.image = album.albumImage ?? album.getImage()
        
        return cell
        
    }
    
    let requestManager = AFHTTPRequestOperationManager()
    
    
    
    func searchForAlbum(named: String, completion: () -> ()) {
        
        albums = []
        
        let namedStripped = named.stringByReplacingOccurrencesOfString(" ", withString: "+")
        
        let urlString = "https://itunes.apple.com/search?term=" + namedStripped + "&media=music&entity=album"
        
        requestManager.GET(urlString, parameters: nil, success: { (operation, data) -> Void in
            
            if let foundInfo = data as? Dict {
                
                if let results = foundInfo["results"] as? [Dict] {
                    
                    for result in results {
                        
                        let album = Album(info: result)
                        self.albums.append(album)
                        
                    }
                    
                    completion()
                    
                }
                
            }
                print(data)
            
            }) { (operation, error) -> Void in
                
                print(error)
                
        }
        
    }
    
}

class Album: NSObject {
    
    var artistName: String?
    var albumArtURL: String?
    var albumImage: UIImage? // will be set when downloaded
    var albumID: Int?
    var albumName: String?
    var itunesLink: String?
    var isNotExplicit: Bool?
    var albumPrice: Double?
    
    init(info: Dict) {
        
        artistName = info["artistName"] as? String
        albumArtURL = info["artworkUrl100"] as? String
        albumID = info["collectionID"] as? Int
        albumName = info["collectionName"] as? String
        itunesLink = info["collectionViewUrl"] as? String
        isNotExplicit = info["collectionExplicitness"] as? String ?? "" == "notExplicit"
        albumPrice = Double(info["collectionPrice"] as? String ?? "0.00")
        
        
    }
    
    // this is so we dont constantly call the image, we can just use it one time and reuse it.
    
    func getImage() -> UIImage? {
        
        if let imageURL = NSURL(string: albumArtURL ?? "") {
            
            if let imageData = NSData(contentsOfURL: imageURL) {
                
                albumImage = UIImage(data: imageData)
                
                return albumImage
                
            }
            
        }
        
        return nil
        
    }
    
}