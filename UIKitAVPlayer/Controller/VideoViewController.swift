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

///啟動播放器需要至少一個參數 AVAsset, delegate?如果需要顯示剪輯時間
class VideoViewController: UIViewController {
    
    var asset: AVAsset!
    //MARK: - Player
    var player: AVPlayer!
    var playerItem: AVPlayerItem!
    weak var delegate: ClipRecordDelegate? //將clip結果回傳
    var playerLayer: AVPlayerLayer!
    
    //MARK: - player UI item
//    var playerView: UIView! //播放器
    var bottomControlBar: UIView! //播放器控制bar
    var playPauseButton: UIButton! //播放暫停鍵
    var fastForwardButton: UIButton! //快轉前進
    var fastBackwardButton: UIButton! //快轉後退
    var currentTimeLabel: UILabel! //現在時間標籤
    var totalProgressView: UIProgressView! //影片進度條
    var totalTimeLabel: UILabel! //影片總時長標籤
    var fastForwardAnimateImageView: UIImageView! //快轉前進點兩下秀出符號
    var fastBackwardAnimateImageView: UIImageView! //快轉後退點兩下秀出符號
    var closePlayerButton: UIButton! //關閉播放器
    //MARK: - additional player UI item
    var clipStartButton: UIButton! //設定剪輯開始時間
    var clipEndButton: UIButton! //設定剪輯結束時間
    //MARK: - Gesture
    var longTapHoldGesture: UIPanGestureRecognizer! //長按並拖動手指快轉
    var doubleTapGesture: UITapGestureRecognizer! //點兩下快轉
    var timeProcessBarGesture: UITapGestureRecognizer! //點進度條迅速調整播放時間段
    
    var cancellables: Set<AnyCancellable> = []
    var playerItemPublisher: AnyCancellable?
    
    var panGestureStartPoint: CGPoint?
    var clipComplete = true
    
    
    var clipRecord: [clipInfo] = []
    var tmpClipRecord: clipInfo?
    
    fileprivate func setupPlayPauseButton() {
        playPauseButton = UIButton()
        playPauseButton.setTitle(nil, for: .normal)
        playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        playPauseButton.addTarget(self, action: #selector(playOrPauseVideo), for: .touchUpInside)
        playPauseButton.tintColor = .white
        playPauseButton.translatesAutoresizingMaskIntoConstraints = false
        bottomControlBar.addSubview(playPauseButton)
    }
    
    fileprivate func setupFastForwardButton() {
        fastForwardButton = UIButton()
        fastForwardButton.setTitle(nil, for: .normal)
        fastForwardButton.setImage(UIImage(systemName: "goforward.10"), for: .normal)
        fastForwardButton.addTarget(self, action: #selector(fastForwardVideo), for: .touchUpInside)
        fastForwardButton.tintColor = .white
        fastForwardButton.translatesAutoresizingMaskIntoConstraints = false
        bottomControlBar.addSubview(fastForwardButton)
    }
    
    fileprivate func setupFastBackwardButton() {
        fastBackwardButton = UIButton()
        fastBackwardButton.setTitle(nil, for: .normal)
        fastBackwardButton.setImage(UIImage(systemName: "gobackward.10"), for: .normal)
        fastBackwardButton.addTarget(self, action: #selector(fastBackwardVideo), for: .touchUpInside)
        fastBackwardButton.tintColor = .white
        fastBackwardButton.translatesAutoresizingMaskIntoConstraints = false
        bottomControlBar.addSubview(fastBackwardButton)
    }
    
    fileprivate func setupCurrentTimeLabel() {
        currentTimeLabel = UILabel()
        currentTimeLabel.textColor = .white.withAlphaComponent(0.8)
        currentTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        currentTimeLabel.textAlignment = .center
        bottomControlBar.addSubview(currentTimeLabel)
    }
    
    fileprivate func setupTotalTimeLabel() {
        totalTimeLabel = UILabel()
        totalTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        totalTimeLabel.textColor = .white.withAlphaComponent(0.8)
        totalTimeLabel.textAlignment = .center
        bottomControlBar.addSubview(totalTimeLabel)
    }
    
    fileprivate func setupTotalProgressView() {
        totalProgressView = UIProgressView()
        totalProgressView.translatesAutoresizingMaskIntoConstraints = false
        totalProgressView.progressTintColor = .white.withAlphaComponent(0.5)
        totalProgressView.trackTintColor = .gray.withAlphaComponent(0.5)
        bottomControlBar.addSubview(totalProgressView)
    }
    
    fileprivate func setupBottomControllBar() {
        bottomControlBar = UIView()
        bottomControlBar.backgroundColor = .gray.withAlphaComponent(0.3)
        bottomControlBar.layer.cornerRadius = 15
        bottomControlBar.clipsToBounds = true
        bottomControlBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomControlBar)
    }
    
    fileprivate func setupFastForwardAnimateImageView() {
        fastForwardAnimateImageView = UIImageView()
        fastForwardAnimateImageView.image = UIImage(systemName: "goforward.10")
        fastForwardAnimateImageView.isHidden = true
        fastForwardAnimateImageView.translatesAutoresizingMaskIntoConstraints = false
        fastForwardAnimateImageView.bounds.size = CGSize(width: 50, height: 50)
        fastForwardAnimateImageView.tintColor = .white.withAlphaComponent(0.5)
        view.addSubview(fastForwardAnimateImageView)
    }
    
    fileprivate func setupFastBackwardAnimateImageView() {
        fastBackwardAnimateImageView = UIImageView()
        fastBackwardAnimateImageView.image = UIImage(systemName: "gobackward.10")
        fastBackwardAnimateImageView.isHidden = true
        fastBackwardAnimateImageView.translatesAutoresizingMaskIntoConstraints = false
        fastBackwardAnimateImageView.bounds.size = CGSize(width: 50, height: 50)
        fastBackwardAnimateImageView.tintColor = .white.withAlphaComponent(0.5)
        view.addSubview(fastBackwardAnimateImageView)
    }
    
    fileprivate func setupConstraints() {
        NSLayoutConstraint.activate([
            bottomControlBar.heightAnchor.constraint(equalToConstant: 30),
            bottomControlBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomControlBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomControlBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            fastBackwardButton.topAnchor.constraint(equalTo: bottomControlBar.safeAreaLayoutGuide.topAnchor),
            fastBackwardButton.bottomAnchor.constraint(equalTo: bottomControlBar.safeAreaLayoutGuide.bottomAnchor),
            fastBackwardButton.leadingAnchor.constraint(equalTo: bottomControlBar.safeAreaLayoutGuide.leadingAnchor),
            fastBackwardButton.widthAnchor.constraint(equalTo: fastBackwardButton.heightAnchor, multiplier: 1.0),
            
            playPauseButton.topAnchor.constraint(equalTo: bottomControlBar.safeAreaLayoutGuide.topAnchor),
            playPauseButton.bottomAnchor.constraint(equalTo: bottomControlBar.safeAreaLayoutGuide.bottomAnchor),
            playPauseButton.leadingAnchor.constraint(equalTo: fastBackwardButton.trailingAnchor),
            playPauseButton.widthAnchor.constraint(equalTo: playPauseButton.heightAnchor, multiplier: 1.0),
            
            fastForwardButton.topAnchor.constraint(equalTo: bottomControlBar.safeAreaLayoutGuide.topAnchor),
            fastForwardButton.bottomAnchor.constraint(equalTo: bottomControlBar.safeAreaLayoutGuide.bottomAnchor),
            fastForwardButton.leadingAnchor.constraint(equalTo: playPauseButton.trailingAnchor),
            fastForwardButton.widthAnchor.constraint(equalTo: fastForwardButton.heightAnchor, multiplier: 1.0),
            
            currentTimeLabel.leadingAnchor.constraint(equalTo: fastForwardButton.trailingAnchor),
            currentTimeLabel.topAnchor.constraint(equalTo: bottomControlBar.safeAreaLayoutGuide.topAnchor),
            currentTimeLabel.bottomAnchor.constraint(equalTo: bottomControlBar.safeAreaLayoutGuide.bottomAnchor),
            currentTimeLabel.widthAnchor.constraint(equalToConstant: 100),
            
            totalTimeLabel.trailingAnchor.constraint(equalTo: bottomControlBar.safeAreaLayoutGuide.trailingAnchor),
            totalTimeLabel.topAnchor.constraint(equalTo: bottomControlBar.safeAreaLayoutGuide.topAnchor),
            totalTimeLabel.bottomAnchor.constraint(equalTo: bottomControlBar.safeAreaLayoutGuide.bottomAnchor),
            totalTimeLabel.widthAnchor.constraint(equalToConstant: 100),
            
            totalProgressView.leadingAnchor.constraint(equalTo: currentTimeLabel.trailingAnchor),
            totalProgressView.trailingAnchor.constraint(equalTo: totalTimeLabel.leadingAnchor),
            totalProgressView.heightAnchor.constraint(equalToConstant: 50),
            totalProgressView.centerYAnchor.constraint(equalTo: bottomControlBar.centerYAnchor),
            
            fastForwardAnimateImageView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            fastForwardAnimateImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: self.view.bounds.width / 4),
            
            fastBackwardAnimateImageView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            fastBackwardAnimateImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: -self.view.bounds.width / 4),
            
            clipEndButton.bottomAnchor.constraint(lessThanOrEqualTo: bottomControlBar.topAnchor, constant: -20),
            clipEndButton.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            clipEndButton.heightAnchor.constraint(equalToConstant: 40),
            clipEndButton.widthAnchor.constraint(equalToConstant: 100),
            
            clipStartButton.bottomAnchor.constraint(lessThanOrEqualTo: bottomControlBar.topAnchor, constant: -20),
            clipStartButton.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            clipStartButton.heightAnchor.constraint(equalToConstant: 40),
            clipStartButton.widthAnchor.constraint(equalToConstant: 100),
            
            closePlayerButton.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            closePlayerButton.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 10),
            closePlayerButton.heightAnchor.constraint(equalToConstant: 30),
            closePlayerButton.widthAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    fileprivate func setupClipEndButton() {
        clipEndButton = UIButton()
        clipEndButton.setTitle("CLIP END POINT", for: .normal)
        clipEndButton.tintColor = .white
        clipEndButton.backgroundColor = .blue.withAlphaComponent(0.8)
        clipEndButton.translatesAutoresizingMaskIntoConstraints = false
        clipEndButton.layer.cornerRadius = 15
        clipEndButton.titleLabel?.adjustsFontSizeToFitWidth = true
        clipEndButton.clipsToBounds = true
        clipEndButton.isHidden = clipComplete
        clipEndButton.titleLabel?.textAlignment = .center
        clipEndButton.addTarget(self, action: #selector(setClipEndPoint), for: .touchUpInside)
        self.view.addSubview(clipEndButton)
    }
    
    fileprivate func setupClipStartButton() {
        clipStartButton = UIButton()
        clipStartButton.setTitle("CLIP START POINT", for: .normal)
        clipStartButton.tintColor = .white
        clipStartButton.backgroundColor = .blue.withAlphaComponent(0.8)
        clipStartButton.translatesAutoresizingMaskIntoConstraints = false
        clipStartButton.layer.cornerRadius = 15
        clipStartButton.titleLabel?.adjustsFontSizeToFitWidth = true
        clipStartButton.clipsToBounds = true
        clipStartButton.isHidden = !clipComplete
        clipStartButton.titleLabel?.textAlignment = .center
        clipStartButton.addTarget(self, action: #selector(setClipStartPoint), for: .touchUpInside)
        self.view.addSubview(clipStartButton)
    }
    
    fileprivate func setupClosePlayerButton() {
        closePlayerButton = UIButton()
        closePlayerButton.setTitle(nil, for: .normal)
        closePlayerButton.setImage(UIImage(systemName: "xmark.circle"), for: .normal)
        closePlayerButton.tintColor = .white.withAlphaComponent(0.8)
        closePlayerButton.translatesAutoresizingMaskIntoConstraints = false
        closePlayerButton.addTarget(self, action: #selector(closePlayer), for: .touchUpInside)
        self.view.addSubview(closePlayerButton)
    }
    
    fileprivate func setupGesture() {
        longTapHoldGesture = UIPanGestureRecognizer(target: self, action: #selector(longTapHoldSwipeGesture))
        longTapHoldGesture.minimumNumberOfTouches = 1
        longTapHoldGesture.maximumNumberOfTouches = 1
        self.view.addGestureRecognizer(longTapHoldGesture)
        
        doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(doubleTap))
        doubleTapGesture.numberOfTapsRequired = 2
        self.view.addGestureRecognizer(doubleTapGesture)
        
        timeProcessBarGesture = UITapGestureRecognizer(target: self, action: #selector(seekTimeThroughTimePrcessBar))
        timeProcessBarGesture.numberOfTapsRequired = 1
        self.totalProgressView.addGestureRecognizer(timeProcessBarGesture)
    }
    // MARK: - viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // MARK: - 建構介面
        playerItem = AVPlayerItem(asset: asset)
        
        // 將影片總時長publish
        playerItemPublisher = playerItem.publisher(for: \.duration)
            .compactMap{ duration in
                duration.isValid ? duration.seconds : nil
            }
            .sink {
                [weak self] durationInSeconds in
                guard !durationInSeconds.isNaN else { return }
                //設定影片總時長標籤
                self?.totalTimeLabel.text = String(format: "%02d:%02d:%02d", Int(durationInSeconds) / 3600, (Int(durationInSeconds) % 3600) / 60, Int(durationInSeconds) % 60)
                //取消訂閱
                self?.cancelTheDurationPublisher()
            }
        playerItemPublisher?.store(in: &cancellables)
        
        player = AVPlayer(playerItem: playerItem)
        // 初始化 AVPlayerLayer
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = view.bounds
        playerLayer.videoGravity = .resizeAspect
        
        // 設置其他屬性
        playerLayer.backgroundColor = UIColor.black.cgColor
        playerLayer.cornerRadius = 10
        view.layer.addSublayer(playerLayer)
        
        setupBottomControllBar()
        setupPlayPauseButton()
        setupFastForwardButton()
        setupFastBackwardButton()
        setupCurrentTimeLabel()
        setupTotalTimeLabel()
        setupTotalProgressView()
        setupFastForwardAnimateImageView()
        setupFastBackwardAnimateImageView()
        setupClosePlayerButton()
        //MARK: - 額外播放器界面 clip function
        setupClipEndButton()
        setupClipStartButton()
        // MARK: - 設定constraints
        setupConstraints()
        // MARK: - 設定播放器支持的手勢
        setupGesture()
        // 開始播放
        player.play()
        if self.player.timeControlStatus == .playing {
            self.playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        }
        //每秒更新player的currentTime
        Timer.publish(every: 1.0, on: .main, in: RunLoop.Mode.common)
            .autoconnect()
            .sink {
                [weak self] _ in
                guard let self = self else { return }
                self.updateCurrentTime(time: self.player.currentTime())
                self.totalProgressView.setProgress(Float(self.player.currentTime().seconds / (self.player.currentItem?.duration.seconds ?? 0)), animated: true)
            }
            .store(in: &cancellables)
        
    }
    // MARK: - normal player function
    @objc func playOrPauseVideo() -> () {
        if self.player.timeControlStatus == .playing {
            self.player.pause()
            self.playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        } else if self.player.timeControlStatus == .paused {
            self.player.play()
            self.playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        }
    }
    
    @objc func fastForwardVideo() -> () {
//        let currentVideoTime = self.player.currentTime()
        let newTime = CMTimeAdd(self.player.currentTime(), CMTimeMake(value: 10, timescale: 1))
        
        self.player.seek(to: newTime)
    }
    
    @objc func fastBackwardVideo() -> () {
//        let currentVideoTime = self.player.currentTime()
        let newTime = CMTimeAdd(self.player.currentTime(), CMTimeMake(value: -10, timescale: 1))
        
        self.player.seek(to: newTime)
    }
    
    func updateCurrentTime(time: CMTime) -> () {
        let currentTimeInSecond = time.seconds
//        print(currentTimeInSecond)
        let hour = Int(currentTimeInSecond / 3600)
        let minute = (Int(currentTimeInSecond) % 3600) / 60
        let second = Int(currentTimeInSecond) % 60
        let timeLabel = String(format: "%02d:%02d:%02d", hour, minute, second)
        self.currentTimeLabel.text = timeLabel
    }
    
    @objc func closePlayer() -> () {
        self.playerLayer.removeFromSuperlayer()
        // 移除播放器視圖
        for subview in self.view.subviews {
            subview.removeFromSuperview()
        }
        
        // 停止播放器
        self.player.pause()
        
        // 取消所有的訂閱
        self.cancellables.forEach { $0.cancel() }
        self.cancellables.removeAll()
        
        self.delegate?.receiveClipRecord(clipRecord: self.clipRecord)
        // 解釋掉self.view.window?.rootViewController = nil
        // 這會導致返回到主頁面
        self.dismiss(animated: true, completion: nil)
    }
    
    func cancelTheDurationPublisher() {
        playerItemPublisher?.cancel()
    }
    // MARK: - Gesture functions
    @objc func doubleTap(sender: UIGestureRecognizer) {
        if sender.state == .ended {
            let location = sender.location(in: self.view)
            print(location.x, location.y)
            if location.x >= self.view.bounds.width / 2 {
                fastForwardVideo()
                self.fastForwardAnimateImageView.isHidden = false
                UIView.animateKeyframes(withDuration: 0.5, delay: 0, options: [], animations: {
                    UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.25) {
                        self.fastForwardAnimateImageView.bounds.size = CGSize(width: 100, height: 100)
                    }
                    UIView.addKeyframe(withRelativeStartTime: 0.25, relativeDuration: 0.25) {
                        self.fastForwardAnimateImageView.bounds.size = CGSize(width: 50, height: 50)
                    }
                }) {
                    _ in
                    self.fastForwardAnimateImageView.isHidden = true
                }
            } else {
                fastBackwardVideo()
                self.fastBackwardAnimateImageView.isHidden = false
                UIView.animateKeyframes(withDuration: 0.5, delay: 0, options: [], animations: {
                    UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.25) {
                        self.fastBackwardAnimateImageView.bounds.size = CGSize(width: 100, height: 100)
                    }
                    UIView.addKeyframe(withRelativeStartTime: 0.25, relativeDuration: 0.25) {
                        self.fastBackwardAnimateImageView.bounds.size = CGSize(width: 50, height: 50)
                    }
                }) {
                    _ in
                    self.fastBackwardAnimateImageView.isHidden = true
                }
            }
        }
    }
    
    @objc func longTapHoldSwipeGesture(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .possible:
            break
        case .began:
            print("began", sender.location(in: self.view))
            self.panGestureStartPoint = sender.location(in: self.view)
        case .changed:
            print("changed", sender.location(in: self.view))
            if let startPoint = self.panGestureStartPoint?.x {
                let currentPoint = sender.location(in: self.view)
                let threshold: CGFloat = 10.0 // 設定一個閾值來防止過於頻繁的觸發
                if currentPoint.x - startPoint > threshold {
                    let newTime = CMTimeAdd(self.player.currentTime(), CMTimeMake(value: 1, timescale: 1))
                    self.player.seek(to: newTime)
                    self.panGestureStartPoint = currentPoint
                    self.player.isMuted = true
                } else if startPoint - currentPoint.x > threshold {
                    let newTime = CMTimeAdd(self.player.currentTime(), CMTimeMake(value: -1, timescale: 1))
                    self.player.seek(to: newTime)
                    self.panGestureStartPoint = currentPoint
                    self.player.isMuted = true
                }
            }
        case .ended:
            print("ended", sender.location(in: self.view))
            self.player.isMuted = false
            break
        case .cancelled:
            self.player.isMuted = false
            break
        case .failed:
            self.player.isMuted = false
            break
        @unknown default:
            break
        }
    }
    
    @objc func seekTimeThroughTimePrcessBar(sender: UITapGestureRecognizer) -> () {
        print(sender.location(in: self.totalProgressView), self.totalProgressView.bounds.width)
        if let videoTotalTime = self.player.currentItem?.duration.seconds {
            let seekTime = sender.location(in: self.totalProgressView).x / self.totalProgressView.bounds.width * videoTotalTime
            self.player.seek(to: CMTime(seconds: seekTime, preferredTimescale: 1))
        }
        
    }
    // MARK: - 額外剪輯function
    @objc func setClipStartPoint(sender: UIButton) -> () {
        print("clip start")
        clipComplete.toggle()
        if let currentTimeInSecond = self.player.currentItem?.currentTime().seconds {
            let hour = Int(currentTimeInSecond / 3600)
            let minute = (Int(currentTimeInSecond) % 3600) / 60
            let second = Int(currentTimeInSecond) % 60
            let timeLabel = String(format: "%02d:%02d:%02d", hour, minute, second)
            tmpClipRecord = clipInfo(startTime: timeLabel, endTime: nil)
        }
        
        UIView.animateKeyframes(withDuration: 0.5, delay: 0, animations: {
            let originalSize = self.clipStartButton.bounds.size
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.25) {
                self.clipStartButton.bounds.size = CGSize(width: originalSize.width + 10, height: originalSize.height + 10)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.25, relativeDuration: 0.25) {
                self.clipStartButton.bounds.size = originalSize
            }
        }) {
            _ in
            self.updateClipButtonStatus()
        }
        
        
//        updateClipButtonStatus()
    }
    
    @objc func setClipEndPoint(sender: UIButton) -> () {
        print("clip end")
        clipComplete.toggle()
        if let currentTimeInSecond = self.player.currentItem?.currentTime().seconds {
            let hour = Int(currentTimeInSecond / 3600)
            let minute = (Int(currentTimeInSecond) % 3600) / 60
            let second = Int(currentTimeInSecond) % 60
            let timeLabel = String(format: "%02d:%02d:%02d", hour, minute, second)
            tmpClipRecord?.endTime = timeLabel
            if let tmpClipRecord = tmpClipRecord {
                clipRecord.append(tmpClipRecord)
            }
            self.tmpClipRecord = nil
            print(clipRecord.description)
        }
        UIView.animateKeyframes(withDuration: 0.5, delay: 0, animations: {
            let originalSize = self.clipEndButton.bounds.size
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.25) {
                self.clipEndButton.bounds.size = CGSize(width: originalSize.width + 10, height: originalSize.height + 10)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.25, relativeDuration: 0.25) {
                self.clipEndButton.bounds.size = originalSize
            }
        }) {
            _ in
            self.updateClipButtonStatus()
        }
    }
    
    func updateClipButtonStatus() -> () {
        self.clipStartButton.isHidden = !clipComplete
        self.clipEndButton.isHidden = clipComplete
    }
    
    // MARK: - when view transition this function will execute
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
    
    override func viewWillDisappear(_ animated: Bool) {
        self.delegate = nil
        print("view disappear, delegate release")
    }
    
    deinit {
        print("deinit VideoViewController")
    }
}

protocol ClipRecordDelegate: AnyObject {
    func receiveClipRecord(clipRecord: [clipInfo])
}
