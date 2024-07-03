//
//  InputUrlTextFieldView.swift
//  UIKitAVPlayer
//
//  Created by 邱翊均 on 2024/7/2.
//

import UIKit

class InputUrlTextFieldView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    var promptLabel: UILabel!
    var urlInputField: UITextField!
    var submitButton: UIButton!
    var playerView: UIView!
    
    weak var submitButtonDelegate: InputUrlTextFieldButtonTapDelegate?
    var viewConstraints: [NSLayoutConstraint] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        self.frame = frame
        print(self.frame, "frame")
        setupPromptLabel()
        setupUrlInputField()
        setupSubmitButton()
        setupPlayerView()
//        setupPortraitConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupPromptLabel() {
        promptLabel = UILabel()
        promptLabel.text = "Input Video URL..."
        promptLabel.adjustsFontSizeToFitWidth = true
        promptLabel.layer.cornerRadius = 15
        promptLabel.clipsToBounds = true
        promptLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(promptLabel)
    }
    fileprivate func setupUrlInputField() {
        urlInputField = UITextField()
        urlInputField.placeholder = "video url".uppercased()
        urlInputField.keyboardType = .URL
        urlInputField.backgroundColor = .cyan
        urlInputField.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(urlInputField)
    }
    fileprivate func setupSubmitButton() {
        submitButton = UIButton(type: .custom)
        var submitButtonConf = UIButton.Configuration.plain()
        submitButtonConf.attributedTitle = AttributedString(NSAttributedString(string: "submit".uppercased(), attributes: [.foregroundColor: UIColor.white]))
        submitButton.configuration = submitButtonConf
        submitButton.backgroundColor = .blue
        submitButton.layer.cornerRadius = 15
        submitButton.clipsToBounds = true
        submitButton.bounds.size = CGSize(width: 200, height: 40)
        submitButton.addTarget(self, action: #selector(submitButtonTap), for: .touchUpInside)
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(submitButton)
    }
    
    fileprivate func setupPlayerView() {
        playerView = UIView()
        playerView.backgroundColor = .black
        playerView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(playerView)
    }
    func setupPortraitConstraints() {
        NSLayoutConstraint.deactivate(viewConstraints)
        viewConstraints = [
            urlInputField.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            urlInputField.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            urlInputField.heightAnchor.constraint(equalToConstant: 40),
            urlInputField.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            urlInputField.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            
            promptLabel.bottomAnchor.constraint(equalTo: urlInputField.topAnchor, constant: -20),
            promptLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            promptLabel.heightAnchor.constraint(equalToConstant: 40),
            promptLabel.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            promptLabel.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            
            submitButton.topAnchor.constraint(equalTo: urlInputField.bottomAnchor, constant: 20),
            submitButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            
            playerView.topAnchor.constraint(equalTo: submitButton.bottomAnchor, constant: 20),
            playerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            playerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            playerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ]
        NSLayoutConstraint.activate(viewConstraints)
    }
    @objc func submitButtonTap(sender: UIButton) {
        submitButtonDelegate?.urlSubmitButtonTap(sender: sender)
    }
}
