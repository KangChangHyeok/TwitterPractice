//
//  TweetCell.swift
//  TwitterPractice
//
//  Created by 강창혁 on 2022/10/11.
//

import UIKit

protocol TweetCellDelegate: AnyObject {
    func handleProfileImageTapped(_ cell: TweetCell)
    func handleReplyTapped(_ cell: TweetCell)
    func handleLikeTapped(_ cell: TweetCell)
    func handleFetchUser(withUsername username: String)
}

final class TweetCell: BaseCVCell {
    
    // MARK: - Properties
    
    weak var delegate: TweetCellDelegate?
    
    // MARK: - UI
    
    private let replyLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 24
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleProfileImageTapped))
        iv.addGestureRecognizer(tap)
        iv.isUserInteractionEnabled = true
        return iv
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
    
    private lazy var commentButton: UIButton = {
        let button = UIButton(type: .system)
        button.configure(imageName: "comment")
        button.addTarget(self, action: #selector(handleCommentTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var retweetButton: UIButton = {
        let button = UIButton(type: .system)
        button.configure(imageName: "retweet")
        button.addTarget(self, action: #selector(handleCommentTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.configure(imageName: "like")
        button.addTarget(self, action: #selector(handleCommentTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.configure(imageName: "share")
        button.addTarget(self, action: #selector(handleCommentTapped), for: .touchUpInside)
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
        let buttonStackView = UIStackView(arrangedSubviews: [commentButton, retweetButton, likeButton, shareButton])
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
        delegate?.handleProfileImageTapped(self)
    }
    @objc func handleCommentTapped() {
        delegate?.handleReplyTapped(self)
    }
    @objc func handleRetweetTapped() {
    }
    @objc func handleLikeTapped() {
        delegate?.handleLikeTapped(self)
    }
    @objc func handleShareTapped() {
    }
    // MARK: - Helpers

    func bind(tweet: Tweet) {
        captionLabel.text = tweet.caption
        profileImageView.image = UIImage(data: tweet.user.profileImage)
        infoLabel.text = tweet.user.userName
//        likeButton.tintColor = viewModel.likeButtonTintColor
//        likeButton.setImage(viewModel.likeButtonImage, for: .normal)
//        replyLabel.isHidden = viewModel.shouldHideReplyLabel
//        replyLabel.text = viewModel.replyText
    }
}
