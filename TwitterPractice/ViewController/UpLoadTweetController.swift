//
//  UpLoadTweetController.swift
//  TwitterPractice
//
//  Created by 강창혁 on 2022/10/09.
//

import UIKit

enum UPloadTweetConfiguration {
    case tweet
    case reply(TweetInfo)
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
    
    override func setDefaults(at viewController: UIViewController) {
        viewController.view.backgroundColor = .white
        configureNavigationBar()
        configureDefaults(config: self.config)
        requestUser()
    }
    
    override func setHierarchy(at view: UIView) {
        view.addSubview(mainStackView)
    }
    
    override func setLayout(at view: UIView) {
        mainStackView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview()
        }
    }
    
    func configureDefaults(config: UPloadTweetConfiguration) {
        switch config {
        case .tweet:
            actionButton.setTitle("Tweet", for: .normal)
            captionTextView.placeholderLabel.text = "What's happening"
            replyLabel.isHidden = true
        case .reply(let tweet):
            actionButton.setTitle("Reply", for: .normal)
            captionTextView.placeholderLabel.text = "Tweet your reply"
            replyLabel.isHidden = false
            #warning("나중에 reply config 설정시 추가하기")
//            replyText = "Replying to @\(tweet.user.username)"
//            replyLabel.text = replyText
        }
    }
    // MARK: - Selectors
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    @objc func handleUploadTweet() {
        guard let caption = captionTextView.text else { return }
        Task {
            guard let userID = UserDefaults.fecthUserID() else { return }
            let user = try await NetworkManager.requestUser(userID: userID)
            let id = UUID().uuidString
            try await NetworkManager.tweetCollection.document(id).setData([
                "caption": caption,
                "likes": 0,
                "timeStamp": Date(),
                "likeUsers": [],
                "id": id,
                "user": [
                    "email": user.email,
                    "fullName": user.fullName,
                    "password": user.password,
                    "profileImage": user.profileImage,
                    "userName": user.userName,
                ]
            ])
            self.dismiss(animated: true)
        }
    }
    #warning("나중에 리트윗 기능넣을때 고려할것")
    //            if case .reply(let tweet) = self.config {
    //                NotificationService.shared.uploadNotification(toUser: tweet.user,
    //                                                              type: .reply,
    //                                                              tweetID: tweet.tweetID)
    //            }
    // MARK: - API
    
    func requestUser() {
        Task {
            guard let userID = UserDefaults.fecthUserID() else { return }
            self.user = try await NetworkManager.requestUser(userID: userID)
        }
    }
    
    // MARK: - Helpers
    
    func configureNavigationBar() {
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: actionButton)
    }
}
