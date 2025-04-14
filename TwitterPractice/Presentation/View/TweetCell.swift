//
//  TweetCell.swift
//  TwitterPractice
//
//  Created by 강창혁 on 2022/10/11.
//

import UIKit

protocol TweetCellDelegate: AnyObject {
    func profileImageViewDidTap(_ cell: TweetCell)
    func chatButtonDidTap(_ cell: TweetCell, receiverID: String)
    func replyButtonDidTap(_ cell: TweetCell)
    func likeButtonDidTap(_ cell: TweetCell, likeCanceled: Bool)
}

final class TweetCell: BaseCVCell {
    
    // MARK: - Properties
    
    weak var delegate: TweetCellDelegate?
    private var tweet: TweetDTO?
    
    // MARK: - UI
    
    private let replyLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 24
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleProfileImageTapped))
        imageView.addGestureRecognizer(tap)
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    private let captionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var chatButton: UIButton = {
        let button = UIButton(type: .system)
        button.configure(imageName: "comment")
        button.addTarget(self, action: #selector(chatButtonDidTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var retweetButton: UIButton = {
        let button = UIButton(type: .system)
        button.configure(imageName: "retweet")
        button.addTarget(self, action: #selector(retweetButtonDidTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var likeButton: LikeButton = {
        let button = LikeButton()
        button.addTarget(self, action: #selector(handleLikeTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.configure(imageName: "share")
        return button
    }()
    
    private lazy var captionStackView: UIStackView = {
        let captionStackView = UIStackView(arrangedSubviews: [infoLabel, captionLabel])
        captionStackView.axis = .vertical
        captionStackView.distribution = .fillProportionally
        captionStackView.spacing = 4
        return captionStackView
    }()
    
    private lazy var imageCaptionStackView: UIStackView = {
        let imageCaptionStackView = UIStackView(arrangedSubviews: [profileImageView, captionStackView])
        imageCaptionStackView.distribution = .fillProportionally
        imageCaptionStackView.spacing = 12
        imageCaptionStackView.alignment = .leading
        return imageCaptionStackView
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [replyLabel, imageCaptionStackView])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.distribution = .fillProportionally
        return stackView
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let buttonStackView = UIStackView(arrangedSubviews: [chatButton, retweetButton, likeButton, shareButton])
        buttonStackView.axis = .horizontal
        buttonStackView.distribution = .equalCentering
        buttonStackView.spacing = 72
        return buttonStackView
    }()
    
    private let underLine: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGroupedBackground
        return view
    }()
    
    override func prepareForReuse() {
        self.tweet = nil
    }
    
    // MARK: - Set
    
    override func setHierarchy(at view: UIView) {
        view.addSubview(stackView)
        view.addSubview(buttonStackView)
        view.addSubview(underLine)
    }
    
    override func setLayout(at view: UIView) {
        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(4)
            make.leading.trailing.equalToSuperview().inset(12)
        }
        buttonStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(stackView.snp.bottom).offset(10)
        }
        buttonStackView.arrangedSubviews.forEach { button in
            button.snp.makeConstraints { make in
                make.size.equalTo(CGSize(width: 20, height: 20))
            }
        }
        underLine.snp.makeConstraints { make in
            make.top.equalTo(buttonStackView.snp.bottom).offset(10)
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
        profileImageView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 48, height: 48))
        }
    }
    
    // MARK: - Selectors
    
    @objc func handleProfileImageTapped() {
        delegate?.profileImageViewDidTap(self)
    }
    
    @objc func chatButtonDidTap() {
        guard let tweet else { return }
        delegate?.chatButtonDidTap(self, receiverID: tweet.user.email)
    }
    
    @objc func retweetButtonDidTap() {
        delegate?.replyButtonDidTap(self)
    }
    
    @objc func handleLikeTapped() {
        likeButton.isSelected.toggle()
        delegate?.likeButtonDidTap(self, likeCanceled: likeButton.isSelected)
    }
    
    @objc func handleShareTapped() { }
    
    // MARK: - Helpers

    func bind(tweet: TweetDTO) {
        self.tweet = tweet
        captionLabel.text = tweet.caption
        profileImageView.image = UIImage(data: tweet.user.profileImage)
        infoLabel.text = tweet.user.userName
        
        guard let userID = UserDefaults.fecthUserID() else { return }
        likeButton.isSelected = !tweet.likeUsers.filter({ $0 == userID }).isEmpty
    }
    
    func bind(_ retweet: TweetDTO) {
        captionLabel.text = retweet.caption
        profileImageView.image = UIImage(data: retweet.user.profileImage)
        infoLabel.text = retweet.user.userName
    }
}
