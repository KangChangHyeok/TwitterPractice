//
//  ProfileHeader.swift
//  TwitterPractice
//
//  Created by 강창혁 on 2022/10/11.
//

import UIKit

import SnapKit
import Firebase

protocol ProfileHeaderViewDelegate: AnyObject {
    func backButtonDidTap(_ button: UIButton)
    func filterDidTap(_ filter: ProfileFilterOptions)
    func profileEditButtonDidTap(_ button: UIButton, user: User?)
}

final class ProfileHeaderView: BaseReusableView {
    // MARK: - Properties
    
    weak var delegate: ProfileHeaderViewDelegate?
    
    private var user: User?
    
    // MARK: - UI
    
    private let filterBar = ProfileFillterView()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .twitterBlue
        view.addSubview(backButton)
        backButton.anchor(top: view.topAnchor, left: view.leftAnchor, paddingTop: 42, paddingLeft: 16)
        backButton.setDimensions(width: 30, height: 30)
        return view
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "baseline_arrow_back_white_24dp")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(backButtonDidTap), for: .touchUpInside)
        return button
    }()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = .lightGray
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 4
        imageView.layer.cornerRadius = 80 / 2
        return imageView
    }()
    
    lazy var editProfileFollowButton: UIButton = {
        let button = UIButton()
        button.layer.borderColor = UIColor.twitterBlue.cgColor
        button.layer.borderWidth = 1.25
        button.backgroundColor = .clear
        button.layer.cornerRadius = 36 / 2
        button.setTitleColor(.twitterBlue, for: .normal)
        button.setTitleColor(.twitterBlue, for: .selected)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handleEditProfileFollow), for: .touchUpInside)
        button.tintAdjustmentMode = .normal
        button.setTitle("팔로우", for: .normal)
        button.setTitle("팔로잉", for: .selected)
        return button
    }()
    
    private lazy var userDetailStackView = UIStackView(
        arrangedSubviews: [fullnameLabel, usernameLabel, bioLabel]
    ).configure {
        $0.axis = .vertical
        $0.distribution = .fillProportionally
        $0.spacing = 4
    }
    
    private let fullnameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .lightGray
        return label
    }()
    
    private let bioLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 3
        return label
    }()
    
    private lazy var followStackView = UIStackView(
        arrangedSubviews: [followLabel, followingLabel]
    ).configure {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.alignment = .leading
        $0.distribution = .fill
    }
    
    private lazy var followLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private lazy var followingLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    // MARK: - Setup
    
    override func setupDefaults() {
        filterBar.delegate = self
    }
    
    override func setupHierarchy() {
        addSubview(filterBar)
        addSubview(containerView)
        addSubview(profileImageView)
        addSubview(editProfileFollowButton)
        addSubview(userDetailStackView)
        addSubview(followStackView)
    }
    
    override func setupLayout() {
        
        containerView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(108)
        }
        
        profileImageView.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.bottom).inset(24)
            make.leading.equalToSuperview().offset(8)
            make.size.equalTo(CGSize(width: 80, height: 80))
        }
        
        editProfileFollowButton.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.bottom).offset(12)
            make.trailing.equalToSuperview().inset(12)
            make.size.equalTo(CGSize(width: 100, height: 36))
        }
        
        userDetailStackView.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(12)
        }
        
        followStackView.snp.makeConstraints { make in
            make.top.equalTo(userDetailStackView.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(12)
            make.bottom.equalTo(filterBar.snp.top).offset(-4)
        }
        
        filterBar.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(50)
        }
    }
    
    //MARK: - Bind
    
    func bind(user: User?) {
        guard let user = user else { return }
        self.user = user
        profileImageView.image = .init(data: user.profileImage)
        fullnameLabel.text = user.fullName
        usernameLabel.text = user.userName
        followLabel.text = "\(user.follow.count)" + " 팔로우"
        followingLabel.text = "\(user.following.count)" + " 팔로잉"
        guard let currentLoginUserID = UserDefaults.fecthUserID() else { return }
        
        if user.email == currentLoginUserID {
            editProfileFollowButton.setTitle("프로필 수정", for: .normal)
        } else {
            if user.following.contains(where: { $0 == currentLoginUserID }) {
                editProfileFollowButton.isSelected = true
            } else {
                editProfileFollowButton.isSelected = false
            }
        }
    }
    // MARK: - Selectors
    @objc func backButtonDidTap(sender: UIButton) {
        delegate?.backButtonDidTap(sender)
    }

    @objc func handleEditProfileFollow() {
        
        Task {
            guard let currentLoginUserID = UserDefaults.fecthUserID(),
                  var user,
            currentLoginUserID != user.email else {
                delegate?.profileEditButtonDidTap(editProfileFollowButton, user: user)
                return
            }
            editProfileFollowButton.isSelected.toggle()
            let isUserFollow = editProfileFollowButton.isSelected
            
            var currentLoginUser = try await NetworkService.userCollection.document(currentLoginUserID).getDocument().data(as: User.self)
            
            if isUserFollow {

                user.following.append(currentLoginUser.email)
                try await NetworkService.userCollection.document(user.email).updateData([
                    "following": user.following
                ])
                
                currentLoginUser.follow.append(user.email)
                try await NetworkService.userCollection.document(currentLoginUser.email).updateData([
                    "follow": currentLoginUser.follow
                ])
                
            } else {
                // 팔로우 취소한 경우, db 수정후 새로운 user값 가져오기
                user.following.removeAll { $0 == currentLoginUser.email }
                // 내가 누른 해당 유저의 팔로잉에서 삭제됨
                try await NetworkService.userCollection.document(user.email).updateData([
                    "following": user.following
                ])
                currentLoginUser.follow.removeAll { $0 == user.email}
                try await NetworkService.userCollection.document(currentLoginUser.email).updateData([
                    "follow": currentLoginUser.follow
                ])
            }
            
            let documents = try await NetworkService.tweetCollection.whereField("user.email", isEqualTo: user.email).getDocuments().documents
            
            let db = Firestore.firestore()
            let batch = db.batch()
            
            documents.forEach { snapshot in
                batch.updateData([
                    "user.follow": user.follow,
                    "user.following": user.following
                ], forDocument: snapshot.reference)
            }
            try await batch.commit()
        }
        
    }
}

// MARK: - ProfileFilterViewDelegate

extension ProfileHeaderView: ProfileFilterViewDelegate {
    func filterViewDidTap(_ view: ProfileFillterView, didSelect index: Int) {
        guard let filter = ProfileFilterOptions(rawValue: index) else { return }
        delegate?.filterDidTap(filter)
    }
}
