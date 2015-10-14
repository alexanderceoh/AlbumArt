//
//  TrackCell.swift
//  AlbumArt
//
//  Created by alex oh on 10/13/15.
//  Copyright © 2015 alex oh. All rights reserved.
//

import UIKit
import SVGPlayButton
import AVFoundation

class TrackCell: UITableViewCell {
    
    var trackInfo: Track! {
        
        didSet {
            
            if let trackPrice = trackInfo.trackPrice {
                
                buyButton.setTitle("$\(trackPrice)", forState: .Normal)

                
            } else {
                
                buyButton.hidden = true
                
            }
            
        }
        
    }

    @IBOutlet weak var trackNameLabel: UILabel!
    
    @IBOutlet weak var playButton: SVGPlayButton!
    
    @IBAction func pressedPlayButton(sender: SVGPlayButton) {
        
    }
    
    @IBOutlet weak var buyButton: UIButton!
    
    @IBAction func pressedBuyButton(sender: AnyObject) {
        
        if let urlString = trackInfo.trackViewURL {
        
            if let url = NSURL(string: urlString) {
                
                UIApplication.sharedApplication().openURL(url)

            }
            
        }
        
    }
    
    override func awakeFromNib() {
        
        // runs after loaded from storyboard
        playButton.progressTrackColor = UIColor.lightGrayColor()
        playButton.progressColor = UIColor.orangeColor()
        playButton.playColor = UIColor.purpleColor()
        playButton.pauseColor = UIColor.purpleColor()
        
        playButton.willPlay = { self.willPlayHandler() }
        playButton.willPause = { self.willPauseHandler() }
        
    }
    
    var player: AVAudioPlayer?
    
    private func willPlayHandler() {
        
        if let data = trackInfo.mediaData ?? trackInfo.getMedia() {
        
            player = player ?? (try? AVAudioPlayer(data: data))
        
        }
        
        player?.play()
            
        print("willPlay")
        
    }
    
    private func willPauseHandler() {
        
        player?.pause()
        print("willPause")
        
    }
    
}
