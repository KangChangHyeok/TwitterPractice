//
//  EditProfileHeader.swift
//  TwitterPractice
//
//  Created by 강창혁 on 2022/11/01.
//

import UIKit

protocol EditProfileHeaderDelegate: AnyObject {
    func didTapChangeProfilePhoto()
}
final class EditProfileHeader: BaseView {
    
    // MARK: - Properties
    
    weak var delegate: EditProfileHeaderDelegate?
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        iv.layer.borderColor = UIColor.white.cgColor
        iv.layer.borderWidth = 3.0
        return iv
    }()
    
    let changePhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("프로필 사진 변경", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    // MARK: - Set
    
    override func setDefaults(at view: UIView) {
        backgroundColor = .twitterBlue
    }
    
    override func setHierarchy(at view: UIView) {
        view.addSubview(profileImageView)
        view.addSubview(changePhotoButton)
    }
    
    override func setLayout(at view: UIView) {
        profileImageView.center(inView: self, yConstant: -16)
        profileImageView.setDimensions(width: 100, height: 100)
        profileImageView.layer.cornerRadius = 100 / 2
        changePhotoButton.centerX(inView: self,topAnchor: profileImageView.bottomAnchor, paddingTop: 8)
    }
}
