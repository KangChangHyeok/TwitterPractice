//
//  UserCell.swift
//  TwitterPractice
//
//  Created by 강창혁 on 2022/10/12.
//

import UIKit

import SnapKit

final class UserCell: BaseCVCell {
    
    // MARK: - UI
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 40 / 2
        iv.backgroundColor = .twitterBlue
        return iv
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.text = "사용자이름"
        return label
    }()
    
    private let fullnameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "사용자이름"
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [usernameLabel, fullnameLabel])
        stackView.axis = .vertical
        stackView.spacing = 2
        return stackView
    }()
    
    // MARK: - Set
    
    override func setHierarchy(at view: UIView) {
        view.addSubview(profileImageView)
        view.addSubview(stackView)
    }
    
    override func setLayout(at view: UIView) {
        profileImageView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 40, height: 40))
            make.leading.equalToSuperview().offset(12)
            make.top.bottom.equalToSuperview().inset(5)
        }
        stackView.snp.makeConstraints { make in
            make.centerY.equalTo(profileImageView)
            make.leading.equalTo(profileImageView.snp.trailing).offset(12)
            make.top.bottom.equalTo(profileImageView)
        }
    }

    // MARK: - Bind1
    
    func bind(user: User?) {
        guard let user = user else { return }
        profileImageView.image = .init(data: user.profileImage)
        usernameLabel.text = user.userName
        fullnameLabel.text = user.fullName
    }
}
