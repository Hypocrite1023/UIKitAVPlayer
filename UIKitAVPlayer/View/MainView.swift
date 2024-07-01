//
//  MainView.swift
//  UIKitAVPlayer
//
//  Created by 邱翊均 on 2024/7/1.
//

import UIKit
import AVKit

class MainView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    // UIView to show the video
    var videoViewTemplate: UIView!
    // play button
    var playButton: UIButton!
    var circleViewUnderPlayButton: UIView!
    //table view to show your clips
    var clipTableView: UITableView!
    
    //portrait constraint setting
    var portraitConstraints: [NSLayoutConstraint] = []
    //landscape constraint setting
    var landscapeConstraints: [NSLayoutConstraint] = []
    
    weak var mainViewDelegate: MainViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.videoViewTemplate = UIView()
        self.playButton = UIButton()
        self.circleViewUnderPlayButton = UIButton()
        self.clipTableView = UITableView()
        
        setupVideoViewTemplate()
        setupPlayButton()
        setupClipTableView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - setup videoViewTemplate
    func setupVideoViewTemplate() -> () {
        videoViewTemplate.backgroundColor = .black
        let videoPreviewImage = UIImageView()
        videoPreviewImage.contentMode = .scaleAspectFit
        videoPreviewImage.translatesAutoresizingMaskIntoConstraints = false
        let videoAsset = AVAsset(url: URL(string: "http://192.168.0.104:84/2023-07-05-1/2023-07-05-1-15.mp4")!)
        let previewImageGenerator = AVAssetImageGenerator(asset: videoAsset)
        
        videoPreviewImage.image = UIImage(cgImage: try! previewImageGenerator.copyCGImage(at: CMTime(seconds: 5, preferredTimescale: 1), actualTime: nil))
        self.videoViewTemplate.addSubview(videoPreviewImage)
        NSLayoutConstraint.activate([
            videoPreviewImage.topAnchor.constraint(equalTo: videoViewTemplate.topAnchor),
            videoPreviewImage.leadingAnchor.constraint(equalTo: videoViewTemplate.leadingAnchor),
            videoPreviewImage.trailingAnchor.constraint(equalTo: videoViewTemplate.trailingAnchor),
            videoPreviewImage.bottomAnchor.constraint(equalTo: videoViewTemplate.bottomAnchor)
        ])
        videoViewTemplate.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(videoViewTemplate)
    }
    // MARK: - setup playButton
    func setupPlayButton() -> () {
//        circleView.bounds.size = CGSize(width: 100, height: 100)
        circleViewUnderPlayButton.layer.cornerRadius = 25
        circleViewUnderPlayButton.clipsToBounds = true
        circleViewUnderPlayButton.backgroundColor = .white.withAlphaComponent(0.8)
        circleViewUnderPlayButton.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(circleViewUnderPlayButton)
        
        playButton = UIButton()
        playButton.setTitle(nil, for: .normal)
        playButton.translatesAutoresizingMaskIntoConstraints = false
//        playButton.bounds.size = CGSize(width: 100, height: 100)
        playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
//        playButton.backgroundColor = .white.withAlphaComponent(0.8)
        playButton.tintColor = .gray
        playButton.addTarget(self, action: #selector(activeThePlayer), for: .touchUpInside)
        self.circleViewUnderPlayButton.addSubview(playButton)
    }
    // MARK: - setup clipTableView
    func setupClipTableView() -> () {
//        clipTableView.dataSource = clipTableViewDataSource
//        clipTableView.delegate = clipTableViewDelegate
        clipTableView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(clipTableView)
    }
    // MARK: - setup portrait constraint
    func setupPortraitModeConstraint() -> () {
        NSLayoutConstraint.deactivate(landscapeConstraints)
        portraitConstraints = [
            videoViewTemplate.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            videoViewTemplate.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor),
            videoViewTemplate.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor),
            videoViewTemplate.heightAnchor.constraint(equalToConstant: 250),
            
            playButton.centerXAnchor.constraint(equalTo: self.circleViewUnderPlayButton.centerXAnchor),
            playButton.centerYAnchor.constraint(equalTo: self.circleViewUnderPlayButton.centerYAnchor),
            playButton.widthAnchor.constraint(equalToConstant: 100),
            playButton.heightAnchor.constraint(equalToConstant: 100),
            
            circleViewUnderPlayButton.centerXAnchor.constraint(equalTo: self.videoViewTemplate.centerXAnchor),
            circleViewUnderPlayButton.centerYAnchor.constraint(equalTo: self.videoViewTemplate.centerYAnchor),
            circleViewUnderPlayButton.widthAnchor.constraint(equalToConstant: 50),
            circleViewUnderPlayButton.heightAnchor.constraint(equalToConstant: 50),
            
            
            clipTableView.topAnchor.constraint(equalTo: self.videoViewTemplate.bottomAnchor, constant: 20),
            clipTableView.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor),
            clipTableView.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor),
            clipTableView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor)
        ]
        NSLayoutConstraint.activate(portraitConstraints)
    }
    // MARK: - setup landscape constraint
    func setupLandscapeModeConstraint() -> () {
        NSLayoutConstraint.deactivate(portraitConstraints)
        landscapeConstraints = [
            videoViewTemplate.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            videoViewTemplate.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            videoViewTemplate.trailingAnchor.constraint(equalTo: self.centerXAnchor),
            videoViewTemplate.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            playButton.centerXAnchor.constraint(equalTo: self.circleViewUnderPlayButton.centerXAnchor),
            playButton.centerYAnchor.constraint(equalTo: self.circleViewUnderPlayButton.centerYAnchor),
            playButton.widthAnchor.constraint(equalToConstant: 100),
            playButton.heightAnchor.constraint(equalToConstant: 100),
            
            circleViewUnderPlayButton.centerXAnchor.constraint(equalTo: self.videoViewTemplate.centerXAnchor),
            circleViewUnderPlayButton.centerYAnchor.constraint(equalTo: self.videoViewTemplate.centerYAnchor),
            circleViewUnderPlayButton.widthAnchor.constraint(equalToConstant: 50),
            circleViewUnderPlayButton.heightAnchor.constraint(equalToConstant: 50),
            
            
            clipTableView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            clipTableView.leadingAnchor.constraint(equalTo: self.videoViewTemplate.trailingAnchor, constant: 20),
            clipTableView.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor),
            clipTableView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor)
        ]
        NSLayoutConstraint.activate(landscapeConstraints)
    }
    // MARK: - the function to start the AVPlayer
    @objc func activeThePlayer() -> () {
        mainViewDelegate?.playButtonTap()
    }
}

