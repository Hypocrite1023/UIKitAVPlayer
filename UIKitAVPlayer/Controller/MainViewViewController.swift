//
//  MainViewViewController.swift
//  UIKitAVPlayer
//
//  Created by 邱翊均 on 2024/6/29.
//

import UIKit
import CoreMedia
import AVFoundation

class MainViewViewController: UIViewController {
    
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
    
    // an array to store your clip info
    var clipArray: [clipInfo] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupVideoViewTemplate()
        setupPlayButton()
        setupClipTableView()
        setupInitialConstraint()
    }
    // MARK: - the function will execute when the view transition: 橫向、縱向
    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            self.setupConstraint(size: size)
        }, completion: nil)
    }
    // MARK: - the function to start the AVPlayer
    @objc func activeThePlayer() -> () {
        let videoViewController = VideoViewController()
        let videoURL = URL(string: "http://192.168.0.104:84/2023-07-05-1/2023-07-05-1-15.mp4")!
        videoViewController.asset = AVAsset(url: videoURL)
        videoViewController.delegate = self
        present(videoViewController, animated: true)
    }
    // MARK: - setup videoViewTemplate
    func setupVideoViewTemplate() -> () {
        videoViewTemplate = UIView()
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
        self.view.addSubview(videoViewTemplate)
    }
    // MARK: - setup playButton
    func setupPlayButton() -> () {
        circleViewUnderPlayButton = UIView()
//        circleView.bounds.size = CGSize(width: 100, height: 100)
        circleViewUnderPlayButton.layer.cornerRadius = 25
        circleViewUnderPlayButton.clipsToBounds = true
        circleViewUnderPlayButton.backgroundColor = .white.withAlphaComponent(0.8)
        circleViewUnderPlayButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(circleViewUnderPlayButton)
        
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
        clipTableView = UITableView()
        clipTableView.dataSource = self
        clipTableView.delegate = self
        clipTableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(clipTableView)
    }
    // MARK: - setup initial constraint with bounds
    func setupInitialConstraint() -> () {
        if self.view.bounds.width < self.view.bounds.height {
            print("portrait")
            setupPortraitModeConstraint()
        } else {
            print("landscape")
            setupLandscapeModeConstraint()
        }
    }
    // MARK: - setup constraint with CGSize
    func setupConstraint(size: CGSize) -> () {
        if size.width < size.height {
            print("portrait")
            setupPortraitModeConstraint()
        } else {
            print("landscape")
            setupLandscapeModeConstraint()
        }
    }
    // MARK: - setup portrait constraint
    func setupPortraitModeConstraint() -> () {
        NSLayoutConstraint.deactivate(landscapeConstraints)
        portraitConstraints = [
            videoViewTemplate.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            videoViewTemplate.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            videoViewTemplate.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
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
            clipTableView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            clipTableView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            clipTableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ]
        NSLayoutConstraint.activate(portraitConstraints)
    }
    // MARK: - setup landscape constraint
    func setupLandscapeModeConstraint() -> () {
        NSLayoutConstraint.deactivate(portraitConstraints)
        landscapeConstraints = [
            videoViewTemplate.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            videoViewTemplate.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            videoViewTemplate.trailingAnchor.constraint(equalTo: self.view.centerXAnchor),
            videoViewTemplate.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
            playButton.centerXAnchor.constraint(equalTo: self.circleViewUnderPlayButton.centerXAnchor),
            playButton.centerYAnchor.constraint(equalTo: self.circleViewUnderPlayButton.centerYAnchor),
            playButton.widthAnchor.constraint(equalToConstant: 100),
            playButton.heightAnchor.constraint(equalToConstant: 100),
            
            circleViewUnderPlayButton.centerXAnchor.constraint(equalTo: self.videoViewTemplate.centerXAnchor),
            circleViewUnderPlayButton.centerYAnchor.constraint(equalTo: self.videoViewTemplate.centerYAnchor),
            circleViewUnderPlayButton.widthAnchor.constraint(equalToConstant: 50),
            circleViewUnderPlayButton.heightAnchor.constraint(equalToConstant: 50),
            
            
            clipTableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            clipTableView.leadingAnchor.constraint(equalTo: self.videoViewTemplate.trailingAnchor, constant: 20),
            clipTableView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            clipTableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ]
        NSLayoutConstraint.activate(landscapeConstraints)
    }
    
}
// MARK: - extension MainViewViewController: UITableViewDataSource
extension MainViewViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return clipArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "clipInfoCell")
        cell.textLabel?.text = clipArray[indexPath.row].startTime! + " - " + clipArray[indexPath.row].endTime!
        return cell
    }
    
    
}
// MARK: - extension MainViewViewController: UITableViewDelegate
extension MainViewViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let videoViewController = VideoViewController()
        let videoURL = URL(string: "http://192.168.0.104:84/2023-07-05-1/2023-07-05-1-15.mp4")!
        videoViewController.asset = AVAsset(url: videoURL)
        let timeStr = clipArray[indexPath.row].startTime?.split(separator: ":")
        if let timeStr = timeStr {
            let (hour, minute, second) = (Int(timeStr[0]), Int(timeStr[1]), Int(timeStr[2]))
            var seconds = hour ?? 0 * 3600
            seconds += minute ?? 0 * 60
            seconds += second ?? 0
            videoViewController.player.seek(to: CMTime(seconds: Double(seconds), preferredTimescale: 1))
        }
        present(videoViewController, animated: true)
        self.clipTableView.deselectRow(at: indexPath, animated: true)
    }
}
// MARK: - extension MainViewViewController: ClipRecordDelegate
extension MainViewViewController: ClipRecordDelegate {
    func receiveClipRecord(clipRecord: [clipInfo]) {
        self.clipArray = clipRecord
        self.clipTableView.reloadData()
        print("receive clip", self.clipArray)
    }
    
    
}
