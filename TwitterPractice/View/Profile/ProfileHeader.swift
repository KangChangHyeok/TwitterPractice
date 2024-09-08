//
//  ProfileHeader.swift
//  TwitterPractice
//
//  Created by 강창혁 on 2022/10/11.
//

import UIKit

protocol ProfileHeaderDelegate: AnyObject {
    func backButtonDidTap()
    func didSelect(filter: ProfileFilterOptions)
    func profileEditButtonDidTap(_ button: UIButton, user: User?)
}

final class ProfileHeader: UICollectionReusableView {
    // MARK: - Properties
    
    weak var delegate: ProfileHeaderDelegate?
    
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
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 48 / 2
        iv.backgroundColor = .lightGray
        iv.layer.borderColor = UIColor.white.cgColor
        iv.layer.borderWidth = 4
        return iv
    }()
    
    lazy var editProfileFollowButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.borderColor = UIColor.twitterBlue.cgColor
        button.layer.borderWidth = 1.25
        button.backgroundColor = .clear
        button.setTitleColor(.twitterBlue, for: .normal)
        button.setTitleColor(.twitterBlue, for: .selected)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handleEditProfileFollow), for: .touchUpInside)
        button.tintAdjustmentMode = .normal
        button.setTitle("팔로우", for: .normal)
        button.setTitle("팔로잉", for: .selected)
        return button
    }()
    
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
    
    private lazy var followLabel: UILabel = {
        let label = UILabel()
        label.text = "0 팔로우"
        return label
    }()
    private lazy var followingLabel: UILabel = {
        let label = UILabel()
        label.text = "0 팔로잉"
        return label
    }()
    
    // MARK: - LifeCycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        filterBar.delegate = self
        addSubview(filterBar)
        filterBar.anchor(left: leftAnchor,
                         bottom: bottomAnchor,
                         right: rightAnchor, 
                         height: 50)
        
        addSubview(containerView)
        containerView.anchor(top: topAnchor,
                             left: leftAnchor,
                             right: rightAnchor,
                             height: 108)
        addSubview(profileImageView)
        
        profileImageView.anchor(top: containerView.bottomAnchor,
                                left: leftAnchor,
                                paddingTop: -24,
                                paddingLeft: 8)
        profileImageView.setDimensions(width: 80, height: 80)
        profileImageView.layer.cornerRadius = 80 / 2
        
        addSubview(editProfileFollowButton)
        editProfileFollowButton.anchor(top: containerView.bottomAnchor,
                                       right: rightAnchor,
                                       paddingTop: 12,
                                       paddingRight: 12)
        editProfileFollowButton.setDimensions(width: 100, height: 36)
        editProfileFollowButton.layer.cornerRadius = 36 / 2
        
        let userDetailStack = UIStackView(arrangedSubviews: [fullnameLabel,
                                                             usernameLabel,
                                                             bioLabel])
        userDetailStack.axis = .vertical
        userDetailStack.distribution = .fillProportionally
        userDetailStack.spacing = 4
        addSubview(userDetailStack)
        userDetailStack.anchor(top: profileImageView.bottomAnchor,
                               left: leftAnchor,
                               right: rightAnchor,
                               paddingTop: 8,
                               paddingLeft: 12,
                               paddingRight: 12)
        
        let followStack = UIStackView(arrangedSubviews: [followLabel,
                                                         followingLabel])
        followStack.axis = .horizontal
        followStack.spacing = 8
        followStack.distribution = .fillEqually
        addSubview(followStack)
        followStack.anchor(top: userDetailStack.bottomAnchor,
                           left: leftAnchor,
                           paddingTop: 8,
                           paddingLeft: 12)
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
    @objc func backButtonDidTap() {
        delegate?.backButtonDidTap()
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
            
            var currentLoginUser = try await NetworkManager.userCollection.document(currentLoginUserID).getDocument().data(as: User.self)
            
            if isUserFollow {
                // 팔로우한경우, db 수정후 새로운 user값 가져오기
                user.following.append(currentLoginUser.email)
                // 내가 누른 해당 유저의 팔로잉에 추가됨
                try await NetworkManager.userCollection.document(user.email).updateData([
                    "following": user.following
                ])
                
                currentLoginUser.follow.append(user.email)
                try await NetworkManager.userCollection.document(currentLoginUser.email).updateData([
                    "follow": currentLoginUser.follow
                ])
            } else {
                // 팔로우 취소한 경우, db 수정후 새로운 user값 가져오기
                user.following.removeAll { $0 == currentLoginUser.email }
                // 내가 누른 해당 유저의 팔로잉에서 삭제됨
                try await NetworkManager.userCollection.document(user.email).updateData([
                    "following": user.following
                ])
                currentLoginUser.follow.removeAll { $0 == user.email}
                try await NetworkManager.userCollection.document(currentLoginUser.email).updateData([
                    "follow": currentLoginUser.follow
                ])
            }
        }
        
    }
}

// MARK: - ProfileFilterViewDelegate

extension ProfileHeader: ProfileFilterViewDelegate {
    func filterView(_ view: ProfileFillterView, didSelect index: Int) {
        guard let filter = ProfileFilterOptions(rawValue: index) else { return }
        delegate?.didSelect(filter: filter)
    }
}
