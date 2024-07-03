//
//  PlayerView.swift
//  UIKitAVPlayer
//
//  Created by 邱翊均 on 2024/7/1.
//

import UIKit
import AVFoundation

class PlayerView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
//    var asset: AVAsset!
    //MARK: - Player
//    var player: AVPlayer
//    var playerItem: AVPlayerItem
//    var playerLayer: AVPlayerLayer?
    //MARK: - player UI item
//    var playerView: UIView! //播放器
    var mergeView = UIView()
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
    
    weak var playerViewDelegate: PlayerViewDelegate?
    
    var playerLayer: AVPlayerLayer!
    
    var player: AVPlayer? {
        get {
            return playerLayer.player
        }
        set {
            playerLayer = AVPlayerLayer(player: newValue)
            playerLayer?.frame = self.bounds
            playerLayer?.videoGravity = .resizeAspect
            playerLayer?.backgroundColor = UIColor.black.cgColor
            self.layer.insertSublayer(playerLayer, below: mergeView.layer)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = frame
        mergeView.frame = frame
//        print(mergeView.frame)
        self.addSubview(mergeView)
//        self.playerViewDelegate = playerViewDelegate
        
//        setupPlayerLayer()
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
//        print(bottomControlBar.frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        mergeView.addSubview(bottomControlBar)
    }
    
    fileprivate func setupFastForwardAnimateImageView() {
        fastForwardAnimateImageView = UIImageView()
        fastForwardAnimateImageView.image = UIImage(systemName: "goforward.10")
        fastForwardAnimateImageView.isHidden = true
        fastForwardAnimateImageView.translatesAutoresizingMaskIntoConstraints = false
        fastForwardAnimateImageView.bounds.size = CGSize(width: 50, height: 50)
        fastForwardAnimateImageView.tintColor = .white.withAlphaComponent(0.5)
        addSubview(fastForwardAnimateImageView)
    }
    
    fileprivate func setupFastBackwardAnimateImageView() {
        fastBackwardAnimateImageView = UIImageView()
        fastBackwardAnimateImageView.image = UIImage(systemName: "gobackward.10")
        fastBackwardAnimateImageView.isHidden = true
        fastBackwardAnimateImageView.translatesAutoresizingMaskIntoConstraints = false
        fastBackwardAnimateImageView.bounds.size = CGSize(width: 50, height: 50)
        fastBackwardAnimateImageView.tintColor = .white.withAlphaComponent(0.5)
        mergeView.addSubview(fastBackwardAnimateImageView)
    }
    
    fileprivate func setupConstraints() {
        NSLayoutConstraint.activate([
            bottomControlBar.heightAnchor.constraint(equalToConstant: 30),
            bottomControlBar.leadingAnchor.constraint(equalTo: mergeView.leadingAnchor),
            bottomControlBar.trailingAnchor.constraint(equalTo: mergeView.trailingAnchor),
            bottomControlBar.bottomAnchor.constraint(equalTo: mergeView.safeAreaLayoutGuide.bottomAnchor),
            
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
            
            fastForwardAnimateImageView.centerYAnchor.constraint(equalTo: mergeView.centerYAnchor),
            fastForwardAnimateImageView.centerXAnchor.constraint(equalTo: mergeView.centerXAnchor, constant: mergeView.bounds.width / 4),
            
            fastBackwardAnimateImageView.centerYAnchor.constraint(equalTo: mergeView.centerYAnchor),
            fastBackwardAnimateImageView.centerXAnchor.constraint(equalTo: mergeView.centerXAnchor, constant: -mergeView.bounds.width / 4),
            
            clipEndButton.bottomAnchor.constraint(lessThanOrEqualTo: bottomControlBar.topAnchor, constant: -20),
            clipEndButton.trailingAnchor.constraint(equalTo: mergeView.safeAreaLayoutGuide.trailingAnchor),
            clipEndButton.heightAnchor.constraint(equalToConstant: 40),
            clipEndButton.widthAnchor.constraint(equalToConstant: 100),
            
            clipStartButton.bottomAnchor.constraint(lessThanOrEqualTo: bottomControlBar.topAnchor, constant: -20),
            clipStartButton.trailingAnchor.constraint(equalTo: mergeView.safeAreaLayoutGuide.trailingAnchor),
            clipStartButton.heightAnchor.constraint(equalToConstant: 40),
            clipStartButton.widthAnchor.constraint(equalToConstant: 100),
            
            closePlayerButton.leadingAnchor.constraint(equalTo: mergeView.safeAreaLayoutGuide.leadingAnchor),
            closePlayerButton.topAnchor.constraint(equalTo: mergeView.safeAreaLayoutGuide.topAnchor, constant: 10),
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
//        clipEndButton.isHidden = clipComplete
        clipEndButton.titleLabel?.textAlignment = .center
        clipEndButton.addTarget(self, action: #selector(setClipEndPoint), for: .touchUpInside)
        mergeView.addSubview(clipEndButton)
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
//        clipStartButton.isHidden = !clipComplete
        clipStartButton.titleLabel?.textAlignment = .center
        clipStartButton.addTarget(self, action: #selector(setClipStartPoint), for: .touchUpInside)
        mergeView.addSubview(clipStartButton)
    }
    
    fileprivate func setupClosePlayerButton() {
        closePlayerButton = UIButton()
        closePlayerButton.setTitle(nil, for: .normal)
        closePlayerButton.setImage(UIImage(systemName: "xmark.circle"), for: .normal)
        closePlayerButton.tintColor = .white.withAlphaComponent(0.8)
        closePlayerButton.translatesAutoresizingMaskIntoConstraints = false
        closePlayerButton.addTarget(self, action: #selector(closePlayer), for: .touchUpInside)
        mergeView.addSubview(closePlayerButton)
    }
    
    @objc func playOrPauseVideo() -> () {
        playerViewDelegate?.playOrPauseVideo(sender: self.playPauseButton)
    }
    @objc func fastForwardVideo() -> () {
        playerViewDelegate?.fastForwardVideo(sender: self.fastForwardButton)
    }
    @objc func fastBackwardVideo() -> () {
        playerViewDelegate?.fastBackwardVideo(sender: self.fastBackwardButton)
    }
    @objc func setClipEndPoint() -> () {
        playerViewDelegate?.setClipEndPoint(sender: self.clipEndButton)
    }
    @objc func setClipStartPoint() -> () {
        playerViewDelegate?.setClipStartPoint(sender: self.clipStartButton)
    }
    @objc func closePlayer() -> () {
        playerViewDelegate?.closePlayer(sender: self.closePlayerButton)
    }
}


