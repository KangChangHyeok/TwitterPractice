//
//  TweetHeader.swift
//  TwitterPractice
//
//  Created by 강창혁 on 2022/10/19.
//

import UIKit

import SnapKit

protocol TweetHeaderDelegate: AnyObject {
    func showActionSheet()
    func handleFetchUser(withUsername username: String)
}

final class TweetHeader: BaseReusableView {
    
    // MARK: - Properties
    
    weak var delegate: TweetHeaderDelegate?
    
    // MARK: - UI
    
    private let replyLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [replyLabel, userProfileStackView])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.distribution = .fillProportionally
        return stackView
    }()
    
    private lazy var userProfileStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [profileImageView, nameStackView])
        stackView.spacing = 12
        return stackView
    }()
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 48 / 2
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleProfileImageTapped))
        iv.addGestureRecognizer(tap)
        iv.isUserInteractionEnabled = true
        iv.backgroundColor = .twitterBlue
        return iv
    }()
    
    private lazy var nameStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [fullnameLabel, usernameLabel])
        stackView.axis = .vertical
        stackView.spacing = -6
        return stackView
    }()
    
    private let fullnameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.text = "fullName"
        return label
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .lightGray
        label.text = "userName"
        return label
    }()
    
    private let captionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .left
        label.text = "6:33 PM - 020202020"
        return label
    }()
    private lazy var optionsButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .lightGray
        button.setImage(UIImage(named: "down_arrow_24pt"), for: .normal)
        button.addTarget(self, action: #selector(showActionSheet), for: .touchUpInside)
        return button
    }()
    
    private lazy var retweetsLabel = UILabel()
    private lazy var likesLabel = UILabel()
    private lazy var statsView: UIView = {
        let view = UIView()
        let divider1 = UIView()
        divider1.backgroundColor = .systemGroupedBackground
        view.addSubview(divider1)
        divider1.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingLeft: 0, height: 1.0)
        let stack = UIStackView(arrangedSubviews: [retweetsLabel, likesLabel])
        stack.axis = .horizontal
        stack.spacing = 12
        view.addSubview(stack)
        stack.centerY(inView: view)
        stack.anchor(left: view.leftAnchor, paddingLeft: 16)
        let divider2 = UIView()
        divider2.backgroundColor = .systemGroupedBackground
        view.addSubview(divider2)
        divider2.anchor(left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingLeft: 0, height: 1.0)
        return view
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [commentButton, retweetButton, likeButton, shareButton])
        stackView.spacing = 72
        return stackView
    }()
    
    private lazy var commentButton: UIButton = {
        let button = createButton(withImageName: "comment")
        button.addTarget(self, action: #selector(handleCommentTapped), for: .touchUpInside)
        return button
    }()
    private lazy var retweetButton: UIButton = {
        let button = createButton(withImageName: "retweet")
        button.addTarget(self, action: #selector(handleRetweetTapped), for: .touchUpInside)
        return button
    }()
    private lazy var likeButton: LikeButton = {
        let button = LikeButton()
        button.addTarget(self, action: #selector(handleLikeTapped), for: .touchUpInside)
        return button
    }()
    private lazy var shareButton: UIButton = {
        let button = createButton(withImageName: "share")
        button.addTarget(self, action: #selector(handleShareTapped), for: .touchUpInside)
        return button
    }()
    
    private let bottomDivider: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGroupedBackground
        return view
    }()
    
    // MARK: - Set
    
    override func setHierarchy(at view: UIView) {
        addSubview(mainStackView)
        addSubview(captionLabel)
        addSubview(dateLabel)
        addSubview(optionsButton)
        addSubview(statsView)
        addSubview(buttonStackView)
        addSubview(bottomDivider)
    }
    
    override func setLayout(at view: UIView) {
        mainStackView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(16)
        }
        profileImageView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 48, height: 48))
        }
        captionLabel.snp.makeConstraints { make in
            make.top.equalTo(mainStackView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(captionLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(16)
        }
        optionsButton.snp.makeConstraints { make in
            make.centerY.equalTo(mainStackView)
            make.trailing.equalToSuperview().inset(8)
        }
        statsView.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(40)
        }
        buttonStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(statsView.snp.bottom).offset(16)
            make.height.equalTo(20)
        }
        bottomDivider.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.top.equalTo(buttonStackView.snp.bottom).offset(16)
            make.left.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    // MARK: - Selectors
    @objc func handleProfileImageTapped() {
    }
    @objc func showActionSheet() {
        delegate?.showActionSheet()
    }
    @objc func handleCommentTapped() {
    }
    @objc func handleRetweetTapped() {
    }
    @objc func handleLikeTapped() {
    }
    @objc func handleShareTapped() {
    }
    // MARK: - Helpers
    func bind(_ tweet: Tweet?) {
        guard let tweet else { return }
        profileImageView.image = UIImage(data: tweet.user.profileImage)
        fullnameLabel.text = tweet.user.fullName
        usernameLabel.text = tweet.user.userName
        captionLabel.text = tweet.caption
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월 dd일 a hh시 mm분"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateLabel.text = dateFormatter.string(from: tweet.timeStamp)
        let userID = UserDefaults.fecthUserID()
        likeButton.isSelected = !tweet.likeUsers.filter({ $0 == userID }).isEmpty
        retweetsLabel.text = "리트윗 \(tweet.retweets.count)"
        likesLabel.text = "좋아요 \(tweet.likes)"
    }
    func createButton(withImageName imageName: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: imageName), for: .normal)
        button.tintColor = .darkGray
        button.setDimensions(width: 20, height: 20)
        return button
    }
}
