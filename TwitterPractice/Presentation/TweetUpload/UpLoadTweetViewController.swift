//
//  UpLoadTweetController.swift
//  TwitterPractice
//
//  Created by 강창혁 on 2022/10/09.
//

import UIKit
import Firebase

enum UPloadTweetConfiguration {
    case tweet
    case reply(TweetDTO)
}

final class UploadTweetViewController: BaseViewController {
    
    // MARK: - Properties
    
    private var user: User? {
        didSet {
            guard let user else { return }
            profileImageView.image = .init(data: user.profileImage)
        }
    }
    private let config: UPloadTweetConfiguration
    
    private lazy var actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0, y: 0, width: 64, height: 32)
        button.layer.cornerRadius = 32 / 2
        button.backgroundColor = .twitterBlue
        button.setTitle("Tweet", for: .normal)
        button.clipsToBounds = true
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleUploadTweet), for: .touchUpInside)
        return button
    }()
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleToFill
        iv.clipsToBounds = true
        iv.setDimensions(width: 48, height: 48)
        iv.layer.cornerRadius = 48 / 2
        iv.backgroundColor = .twitterBlue
        return iv
    }()
    
    private let captionTextView = InputTextView()
    
    private lazy var imageCaptionStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [profileImageView, captionTextView])
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.alignment = .leading
        return stackView
    }()
    
    private lazy var replyLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .lightGray
        label.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        return label
    }()
    
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [replyLabel, imageCaptionStackView])
        stackView.axis = .vertical
        stackView.spacing = 12
        return stackView
    }()
    
    // MARK: - Initializer
    
    init(config: UPloadTweetConfiguration) {
        self.config = config
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Set
    
    override func setupDefaults() {
        self.view.backgroundColor = .white
        configureNavigationBar()
        configureDefaults(config: self.config)
        requestUser()
    }
    
    override func setupHierarchy() {
        view.addSubview(mainStackView)
    }
    
    override func setupLayout() {
        mainStackView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview()
        }
    }
    
    func configureDefaults(config: UPloadTweetConfiguration) {
        switch config {
        case .tweet:
            actionButton.setTitle("Tweet", for: .normal)
            captionTextView.placeholderLabel.text = "무슨 일이 일어났나요?"
            replyLabel.isHidden = true
        case .reply(let tweet):
            actionButton.setTitle("Reply", for: .normal)
            captionTextView.placeholderLabel.text = "리트윗을 작성해 주세요."
            replyLabel.isHidden = false
            replyLabel.text = "Replying to @\(tweet.user.userName)"
        }
    }
    // MARK: - Selectors
    
    @objc func cancelButtonDidTap() {
        dismiss(animated: true, completion: nil)
    }
    @objc func handleUploadTweet() {
        switch config {
        // 일반적인 트윗 작성시
        case .tweet:
            guard let caption = captionTextView.text else { return }
            Task {
                guard let userID = UserDefaults.fecthUserID() else { return }
                let user = try await NetworkService.fetchUser(userID: userID)
                let tweetID = UUID().uuidString
                try await NetworkService.tweetCollection.document(tweetID).setData([
                    "originalTweetID": "",
                    "id": tweetID,
                    "caption": caption,
                    "likes": 0,
                    "likeUsers": [],
                    "retweetIDs": [],
                    "timeStamp": Date(),
                    "user": [
                        "email": user.email,
                        "fullName": user.fullName,
                        "password": user.password,
                        "profileImage": user.profileImage,
                        "userName": user.userName,
                        "follow": user.follow,
                        "following": user.following
                    ]
                ])
                self.dismiss(animated: true)
            }
        // 리트윗 작성시
        case .reply(var tweet):
            guard let caption = captionTextView.text else { return }
            Task {
                guard let userID = UserDefaults.fecthUserID() else { return }
                let user = try await NetworkService.fetchUser(userID: userID)
                let retweetID = UUID().uuidString
                do {
                    // 리트윗 저장하기
                    let retweet = [
                        "originalTweetID": tweet.id,
                        "id": retweetID,
                        "caption": caption,
                        "likes": 0,
                        "likeUsers": [],
                        "retweetIDs": [],
                        "timeStamp": Date(),
                        "user": [
                            "email": user.email,
                            "fullName": user.fullName,
                            "password": user.password,
                            "profileImage": user.profileImage,
                            "userName": user.userName,
                            "follow": user.follow,
                            "following": user.following
                        ]
                    ]
                    try await NetworkService.tweetCollection.document(retweetID).setData(retweet)
                    tweet.retweetIDs.append(retweetID)
                    var updatedRetweetIDs = tweet.retweetIDs
                    
                    try await NetworkService.tweetCollection.document(tweet.id).updateData(["retweetIDs": updatedRetweetIDs])
                    
                    let notificationID = UUID().uuidString
                
                    try await NetworkService.notifications.document(notificationID).setData([
                        "id": notificationID,
                        "tweetID": tweet.id,
                        "caption": caption,
                        "type": NotificationType.reply.description,
                        "timeStamp": Date(),
                        "user": [
                            "email": user.email,
                            "fullName": user.fullName,
                            "password": user.password,
                            "profileImage": user.profileImage,
                            "userName": user.userName,
                            "follow": user.follow,
                            "following": user.following
                        ]
                    ])
                    print("알림 전송 완료!")
                } catch {
                    print("ERROR: \(error)")
                }
                
                self.dismiss(animated: true)
            }
        }
        
    }
    // MARK: - API
    
    func requestUser() {
        Task {
            guard let userID = UserDefaults.fecthUserID() else { return }
            self.user = try await NetworkService.fetchUser(userID: userID)
        }
    }
    
    // MARK: - Helpers
    
    func configureNavigationBar() {
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonDidTap))
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: actionButton)
    }
}
