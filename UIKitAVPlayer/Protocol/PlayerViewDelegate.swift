//
//  PlayerViewDelegate.swift
//  UIKitAVPlayer
//
//  Created by 邱翊均 on 2024/7/2.
//

import Foundation
import UIKit
protocol PlayerViewDelegate: AnyObject {
    func playOrPauseVideo(sender: UIButton)
    func fastForwardVideo(sender: UIButton?)
    func fastBackwardVideo(sender: UIButton?)
    func setClipEndPoint(sender: UIButton)
    func setClipStartPoint(sender: UIButton)
    func closePlayer(sender: UIButton)
}
