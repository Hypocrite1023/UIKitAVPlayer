//
//  AVPlayerModel.swift
//  UIKitAVPlayer
//
//  Created by 邱翊均 on 2024/7/1.
//

import Foundation
import AVFoundation

struct AVPlayerModel {
    var player: AVPlayer
    
    init(url: URL) {
        self.player = AVPlayer(url: url)
    }
    
    func play() {
        player.play()
    }
    
    func pause() {
        player.pause()
    }
}
