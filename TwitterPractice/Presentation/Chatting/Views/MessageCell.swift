//
//  MyMessageCell.swift
//  TwitterPractice
//
//  Created by kangChangHyeok on 08/04/2025.
//

import UIKit

final class MessageCell: BaseCVCell {
    
    private var layoutConstraints: [NSLayoutConstraint]?
    
    private let recevierProfileImageView = UIImageView().configure {
        $0.backgroundColor = .black
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private let recevierNameLabel = UILabel().configure {
        $0.font = .systemFont(ofSize: 12)
        $0.textColor = .lightGray
        $0.numberOfLines = 0
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private let contentLabelBackgroundView = UIView().configure {
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private let contentLabel = UILabel().configure {
        $0.font = .systemFont(ofSize: 15)
        $0.numberOfLines = 0
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func setDefaults(at view: UIView) {
    }
    
    override func setHierarchy(at view: UIView) {
        contentLabelBackgroundView.addSubview(contentLabel)
        view.addSubview(recevierProfileImageView)
        view.addSubview(recevierNameLabel)
        view.addSubview(contentLabelBackgroundView)
    }
    
    override func setLayout(at view: UIView) {
        contentLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(12)
            make.leading.trailing.equalToSuperview().inset(8)
        }
    }
    
    override func prepareForReuse() {
        guard let layoutConstraints else { return }
        NSLayoutConstraint.deactivate(layoutConstraints)
        recevierProfileImageView.image = nil
    }
    
    func bind(_ message: Message) {
        Task {
            let receiver = try await NetworkService.fetchUser(userID: message.senderID)
            
            contentLabel.text = message.content
            
            let isMyMessage = message.senderID == UserDefaults.fecthUserID()!
            let constraints: [NSLayoutConstraint]
            
            if isMyMessage {
                recevierProfileImageView.isHidden = true
                recevierNameLabel.isHidden = true
                
                contentLabel.textColor = .white
                contentLabelBackgroundView.backgroundColor = .twitterBlue
                
                constraints = [
                    contentLabelBackgroundView.widthAnchor.constraint(lessThanOrEqualToConstant: contentView.frame.width * 0.8),
                    contentLabelBackgroundView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
                    contentLabelBackgroundView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
                    contentLabelBackgroundView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
                ]
            } else {
                recevierProfileImageView.isHidden = false
                recevierNameLabel.isHidden = false
                
                recevierProfileImageView.image = UIImage(data: receiver.profileImage)
                recevierNameLabel.text = receiver.userName
                
                contentLabel.textColor = .black
                contentLabelBackgroundView.backgroundColor = .gray
                
                constraints = [
                    recevierProfileImageView.widthAnchor.constraint(equalToConstant: 30),
                    recevierProfileImageView.heightAnchor.constraint(equalToConstant: 30),
                    recevierProfileImageView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
                    recevierProfileImageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
                    recevierNameLabel.topAnchor.constraint(equalTo: recevierProfileImageView.topAnchor),
                    recevierNameLabel.leadingAnchor.constraint(equalTo: recevierProfileImageView.trailingAnchor, constant: 3),
                    contentLabelBackgroundView.widthAnchor.constraint(lessThanOrEqualToConstant: (contentView.frame.width * 0.8) - 25),
                    contentLabelBackgroundView.topAnchor.constraint(equalTo: self.recevierNameLabel.bottomAnchor, constant: 3),
                    contentLabelBackgroundView.leadingAnchor.constraint(equalTo: self.recevierProfileImageView.trailingAnchor, constant: 3),
                    contentLabelBackgroundView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
                ]
            }
            
            NSLayoutConstraint.activate(constraints)
            self.layoutConstraints = constraints
        }
    }
}
