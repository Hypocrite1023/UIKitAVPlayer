//
//  SettingViewController.swift
//  UIKitAVPlayer
//
//  Created by 邱翊均 on 2024/6/28.
//

import UIKit
import AVKit
import AVFoundation
import Combine

class VideoViewController: UIViewController {
    
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    var playPauseButton: UIButton!
    var fastForwardButton: UIButton!
    var fastBackwardButton: UIButton!
    var currentTimeLabel: UILabel!
    var totalProgressView: UIProgressView!
    var totalTimeLabel: UILabel!
    var cancellables: Set<AnyCancellable> = []
    var playerItemPublisher: AnyCancellable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize AVAsset
        let videoURL = URL(string: "http://192.168.0.104:84/2023-07-05-1/2023-07-05-1-15.mp4")!
        let asset = AVAsset(url: videoURL)
        
        // Create AVPlayerItem
        let playerItem = AVPlayerItem(asset: asset)
        playerItemPublisher = playerItem.publisher(for: \.duration)
            .compactMap{ duration in
                duration.isValid ? duration.seconds : nil
            }
            .sink {
                [weak self] durationInSeconds in
                guard !durationInSeconds.isNaN else { return }
                
                self?.totalTimeLabel.text = String(format: "%02d:%02d:%02d", Int(durationInSeconds) / 3600, (Int(durationInSeconds) % 3600) / 60, Int(durationInSeconds) % 60)
                self?.cancelTheDurationPublisher()
            }
        playerItemPublisher?.store(in: &cancellables)
        
        // 初始化 AVPlayer
        player = AVPlayer(playerItem: playerItem)
        
        // 初始化 AVPlayerLayer
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = view.bounds
        playerLayer.videoGravity = .resizeAspect
        
        // 設置其他屬性
        playerLayer.backgroundColor = UIColor.black.cgColor
        playerLayer.cornerRadius = 10
        playerLayer.borderWidth = 2
        playerLayer.borderColor = UIColor.red.cgColor
        
        // 創建一個 UIView 來承載 AVPlayerLayer
        let playerView = UIView(frame: view.bounds)
        playerView.layer.addSublayer(playerLayer)
        view.addSubview(playerView)
        
        playPauseButton = UIButton()
        playPauseButton.setTitle(nil, for: .normal)
        playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        playPauseButton.addTarget(self, action: #selector(playOrPauseVideo), for: .touchUpInside)
        playPauseButton.tintColor = .white
        playPauseButton.translatesAutoresizingMaskIntoConstraints = false
        
        
        fastForwardButton = UIButton()
        fastForwardButton.setTitle(nil, for: .normal)
        fastForwardButton.setImage(UIImage(systemName: "goforward.10"), for: .normal)
        fastForwardButton.addTarget(self, action: #selector(fastForwardVideo), for: .touchUpInside)
        fastForwardButton.tintColor = .white
        fastForwardButton.translatesAutoresizingMaskIntoConstraints = false
        
        fastBackwardButton = UIButton()
        fastBackwardButton.setTitle(nil, for: .normal)
        fastBackwardButton.setImage(UIImage(systemName: "gobackward.10"), for: .normal)
        fastBackwardButton.addTarget(self, action: #selector(fastBackwardVideo), for: .touchUpInside)
        fastBackwardButton.tintColor = .white
        fastBackwardButton.translatesAutoresizingMaskIntoConstraints = false
        
        currentTimeLabel = UILabel()
        currentTimeLabel.textColor = .white.withAlphaComponent(0.8)
        currentTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        currentTimeLabel.textAlignment = .center
        
        totalTimeLabel = UILabel()
        totalTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        totalTimeLabel.textColor = .white.withAlphaComponent(0.8)
        totalTimeLabel.textAlignment = .center
        
        totalProgressView = UIProgressView()
        totalProgressView.translatesAutoresizingMaskIntoConstraints = false
        totalProgressView.progressTintColor = .white.withAlphaComponent(0.5)
        totalProgressView.trackTintColor = .gray.withAlphaComponent(0.5)
        
        let bottomControlBar = UIView()
        bottomControlBar.backgroundColor = .gray.withAlphaComponent(0.3)
        bottomControlBar.layer.cornerRadius = 15
        bottomControlBar.clipsToBounds = true
        bottomControlBar.translatesAutoresizingMaskIntoConstraints = false
        
        bottomControlBar.addSubview(playPauseButton)
        bottomControlBar.addSubview(fastForwardButton)
        bottomControlBar.addSubview(fastBackwardButton)
        bottomControlBar.addSubview(currentTimeLabel)
        bottomControlBar.addSubview(totalProgressView)
        bottomControlBar.addSubview(totalTimeLabel)
        
        view.addSubview(bottomControlBar)
        
        NSLayoutConstraint.activate([bottomControlBar.heightAnchor.constraint(equalToConstant: 30),
                                     bottomControlBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                                     bottomControlBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                                     bottomControlBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
                                    ])
        NSLayoutConstraint.activate([fastBackwardButton.topAnchor.constraint(equalTo: bottomControlBar.safeAreaLayoutGuide.topAnchor),
//                                     fastBackwardButton.widthAnchor.constraint(equalToConstant: 50),
                                     fastBackwardButton.bottomAnchor.constraint(equalTo: bottomControlBar.safeAreaLayoutGuide.bottomAnchor),
                                     fastBackwardButton.leadingAnchor.constraint(equalTo: bottomControlBar.safeAreaLayoutGuide.leadingAnchor),
                                     fastBackwardButton.widthAnchor.constraint(equalTo: fastBackwardButton.heightAnchor, multiplier: 1.0)
                                    ])
        NSLayoutConstraint.activate([playPauseButton.topAnchor.constraint(equalTo: bottomControlBar.safeAreaLayoutGuide.topAnchor),
//                                     playPauseButton.widthAnchor.constraint(equalToConstant: 50),
                                     playPauseButton.bottomAnchor.constraint(equalTo: bottomControlBar.safeAreaLayoutGuide.bottomAnchor),
                                     playPauseButton.leadingAnchor.constraint(equalTo: fastBackwardButton.trailingAnchor),
                                     playPauseButton.widthAnchor.constraint(equalTo: playPauseButton.heightAnchor, multiplier: 1.0)
                                    ])
        
        
        NSLayoutConstraint.activate([fastForwardButton.topAnchor.constraint(equalTo: bottomControlBar.safeAreaLayoutGuide.topAnchor),
//                                     fastForwardButton.widthAnchor.constraint(equalToConstant: 50),
                                     fastForwardButton.bottomAnchor.constraint(equalTo: bottomControlBar.safeAreaLayoutGuide.bottomAnchor),
                                     fastForwardButton.leadingAnchor.constraint(equalTo: playPauseButton.trailingAnchor),
                                     fastForwardButton.widthAnchor.constraint(equalTo: fastForwardButton.heightAnchor, multiplier: 1.0)
                                    ])
        NSLayoutConstraint.activate([currentTimeLabel.leadingAnchor.constraint(equalTo: fastForwardButton.trailingAnchor),
                                     currentTimeLabel.topAnchor.constraint(equalTo: bottomControlBar.safeAreaLayoutGuide.topAnchor),
                                     currentTimeLabel.bottomAnchor.constraint(equalTo: bottomControlBar.safeAreaLayoutGuide.bottomAnchor),
                                     currentTimeLabel.widthAnchor.constraint(equalToConstant: 100)
                                    ])
        NSLayoutConstraint.activate([totalTimeLabel.trailingAnchor.constraint(equalTo: bottomControlBar.safeAreaLayoutGuide.trailingAnchor),
                                     totalTimeLabel.topAnchor.constraint(equalTo: bottomControlBar.safeAreaLayoutGuide.topAnchor),
                                     totalTimeLabel.bottomAnchor.constraint(equalTo: bottomControlBar.safeAreaLayoutGuide.bottomAnchor),
                                     totalTimeLabel.widthAnchor.constraint(equalToConstant: 100)
                                    ])
        NSLayoutConstraint.activate([totalProgressView.leadingAnchor.constraint(equalTo: currentTimeLabel.trailingAnchor),
                                     totalProgressView.trailingAnchor.constraint(equalTo: totalTimeLabel.leadingAnchor),
                                     totalProgressView.heightAnchor.constraint(lessThanOrEqualToConstant: 20),
                                     totalProgressView.centerYAnchor.constraint(equalTo: bottomControlBar.centerYAnchor)
                                    ])
        
        
        
        // 開始播放
//        player.play()
        Timer.publish(every: 1.0, on: .main, in: RunLoop.Mode.common)
            .autoconnect()
            .sink {
                [weak self] _ in
                guard let self = self else { return }
                self.updateCurrentTime(time: self.player.currentTime())
                self.totalProgressView.setProgress(Float(self.player.currentTime().seconds / (self.player.currentItem?.duration.seconds ?? 0)), animated: true)
            }
            .store(in: &cancellables)
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(doubleTap))
        doubleTapGesture.numberOfTapsRequired = 2
        self.view.addGestureRecognizer(doubleTapGesture)
    }
    
    @objc func playOrPauseVideo() {
        if self.player.timeControlStatus == .playing {
            self.player.pause()
            self.playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        } else if self.player.timeControlStatus == .paused {
            self.player.play()
            self.playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        }
    }
    
    @objc func fastForwardVideo() {
        let currentVideoTime = self.player.currentTime()
        let newTime = CMTimeAdd(self.player.currentTime(), CMTimeMake(value: 10, timescale: 1))
        
        self.player.seek(to: newTime)
    }
    
    @objc func fastBackwardVideo() {
        let currentVideoTime = self.player.currentTime()
        let newTime = CMTimeAdd(self.player.currentTime(), CMTimeMake(value: -10, timescale: 1))
        
        self.player.seek(to: newTime)
    }
    
    func updateCurrentTime(time: CMTime) {
        let currentTimeInSecond = time.seconds
//        print(currentTimeInSecond)
        let hour = Int(currentTimeInSecond / 3600)
        let minute = (Int(currentTimeInSecond) % 3600) / 60
        let second = Int(currentTimeInSecond) % 60
        let timeLabel = String(format: "%02d:%02d:%02d", hour, minute, second)
        self.currentTimeLabel.text = timeLabel
    }
    
    func cancelTheDurationPublisher() {
        playerItemPublisher?.cancel()
    }
    
    @objc func doubleTap(sender: UIGestureRecognizer) {
        if sender.state == .ended {
            let location = sender.location(in: self.view)
            print(location.x, location.y)
            if location.x >= self.view.bounds.width / 2 {
                fastForwardVideo()
            } else {
                fastBackwardVideo()
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            if let windowScene = self.view.window?.windowScene {
                let orientation = windowScene.interfaceOrientation
                if orientation.isLandscape {
                    
                    self.playerLayer.frame = self.view.bounds
                    self.playerLayer.videoGravity = .resizeAspect
                    print("橫向")
                } else if orientation.isPortrait {
                    self.playerLayer.frame = self.view.bounds
                    self.playerLayer.videoGravity = .resizeAspect
                    print("縱向")
                }
            }
        }, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
