//
//  MainViewViewController.swift
//  UIKitAVPlayer
//
//  Created by 邱翊均 on 2024/6/29.
//

import UIKit
import CoreMedia
import AVFoundation
//import MobileVLCKit

class MainViewViewController: UIViewController {
    
    // an array to store your clip info
    var clipArray: [clipInfo] = []
    var avPlayerModel: AVPlayerModel!
//    var mediaPlayer: VLCMediaPlayer!
    var mainView: MainView!
    
    init(avPlayerModel: AVPlayerModel!) {
//        self.mediaPlayer = mediaPlayer
        self.avPlayerModel = avPlayerModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        mainView = MainView()
        mainView?.mainViewDelegate = self
        mainView?.frame = UIScreen.main.bounds
        self.view.addSubview(mainView)
        
//        avPlayerModel = AVPlayerModel(url: URL(string: "http://192.168.0.104:84/2023-07-05-1/2023-07-05-1-15.mp4")!)
        mainView?.clipTableView.dataSource = self
        mainView?.clipTableView.delegate = self
        setupInitialConstraint()
    }
    // MARK: - the function will execute when the view transition: 橫向、縱向
    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            self.setupConstraint(size: size)
        }, completion: nil)
    }
    
    // MARK: - setup initial constraint with bounds
    func setupInitialConstraint() -> () {
        if view.bounds.width < view.bounds.height {
            print("portrait")
            mainView?.setupPortraitModeConstraint()
        } else {
            print("landscape")
            mainView?.setupLandscapeModeConstraint()
        }
    }
    // MARK: - setup constraint with CGSize
    func setupConstraint(size: CGSize) -> () {
        if size.width < size.height {
            print("portrait")
            mainView?.setupPortraitModeConstraint()
        } else {
            print("landscape")
            mainView?.setupLandscapeModeConstraint()
        }
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
        let videoViewController = VideoViewController(videoPlayerModel: avPlayerModel, frame: UIScreen.main.bounds)
//        let videoURL = URL(string: "http://192.168.0.104:84/2023-07-05-1/2023-07-05-1-15.mp4")!
//        videoViewController.asset = AVAsset(url: videoURL)
        let timeStr = clipArray[indexPath.row].startTime?.split(separator: ":")
        if let timeStr = timeStr {
            let (hour, minute, second) = (Int(timeStr[0]), Int(timeStr[1]), Int(timeStr[2]))
            var seconds = hour ?? 0 * 3600
            seconds += minute ?? 0 * 60
            seconds += second ?? 0
            avPlayerModel.player.seek(to: CMTime(seconds: Double(seconds), preferredTimescale: 1))
        }
        videoViewController.modalPresentationStyle = .fullScreen
        present(videoViewController, animated: true)
        mainView?.clipTableView.deselectRow(at: indexPath, animated: true)
    }
}
// MARK: - extension MainViewViewController: ClipRecordDelegate
extension MainViewViewController: ClipRecordDelegate {
    func receiveClipRecord(clipRecord: [clipInfo]) {
        self.clipArray = clipRecord
        mainView?.clipTableView.reloadData()
        print("receive clip", self.clipArray)
    }
}

extension MainViewViewController: MainViewDelegate {
    func playButtonTap() {
        print("tap")
        let videoViewController = VideoViewController(videoPlayerModel: avPlayerModel,frame: UIScreen.main.bounds)
        videoViewController.modalPresentationStyle = .fullScreen
        videoViewController.clipTableViewDataSourceDelegate = self
//        print(videoViewController.view.frame, "xxx")
        
        present(videoViewController, animated: true)
    }
    
    
}
