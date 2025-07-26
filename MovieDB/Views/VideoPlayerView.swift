//
//  VideoPlayerView.swift
//  MovieDB
//
//  Created by Jhon Lopez on 7/25/25.
//

import SwiftUI
import AVKit

struct VideoPlayerView: UIViewControllerRepresentable {
    let videoURL: URL
    
    func makeUIViewController(context: Context) -> some AVPlayerViewController {
        print("creating video controller for URL: \(videoURL)")
        let playerController = AVPlayerViewController()
        playerController.player = AVPlayer(url: videoURL)
        playerController.allowsPictureInPicturePlayback = true
        playerController.player?.play() // Play automatically
        return playerController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        print("updating video controller")
    }
    
    
}
