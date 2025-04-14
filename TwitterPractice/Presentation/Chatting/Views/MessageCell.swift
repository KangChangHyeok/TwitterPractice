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
    
    private lazy var stackView = UIStackView(arrangedSubviews: [recevierNameLabel, contentLabelBackgroundView]).configure {
        $0.spacing = 3
        $0.axis = .vertical
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private let recevierNameLabel = UILabel().configure {
        $0.font = .systemFont(ofSize: 12)
        $0.textColor = .lightGray
        $0.numberOfLines = 1
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
    
    private let messageTimeStampLabel = UILabel().configure {
        $0.numberOfLines = 1
        $0.font = .systemFont(ofSize: 12)
        $0.textColor = .lightGray
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func setDefaults(at view: UIView) {
    }
    
    override func setHierarchy(at view: UIView) {
        contentLabelBackgroundView.addSubview(contentLabel)
        view.addSubview(recevierProfileImageView)
        view.addSubview(stackView)
        view.addSubview(messageTimeStampLabel)
    }
    
    override func setLayout(at view: UIView) {
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(contentLabelBackgroundView).inset(12)
            make.bottom.equalTo(contentLabelBackgroundView.snp.bottom).inset(12)
            make.leading.equalTo(contentLabelBackgroundView).inset(8)
            make.trailing.equalTo(contentLabelBackgroundView.snp.trailing).inset(8)
        }
        recevierNameLabel.snp.makeConstraints { make in
            make.height.equalTo(15)
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
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "HH:mm"
                
                messageTimeStampLabel.text = dateFormatter.string(from: message.timeStamp)
                constraints = [
                    stackView.widthAnchor.constraint(lessThanOrEqualToConstant: contentView.frame.width * 0.8),
                    stackView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
                    stackView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
                    stackView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
                    messageTimeStampLabel.trailingAnchor.constraint(equalTo: self.stackView.leadingAnchor, constant: -3),
                    messageTimeStampLabel.bottomAnchor.constraint(equalTo: self.stackView.bottomAnchor)
                ]
            } else {
                recevierProfileImageView.isHidden = false
                recevierNameLabel.isHidden = false
                
                recevierProfileImageView.image = UIImage(data: receiver.profileImage)
                recevierNameLabel.text = receiver.userName
                
                contentLabel.textColor = .black
                contentLabelBackgroundView.backgroundColor = .systemGray6
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "HH:mm"
                
                messageTimeStampLabel.text = dateFormatter.string(from: message.timeStamp)
                
                constraints = [
                    recevierProfileImageView.widthAnchor.constraint(equalToConstant: 30),
                    recevierProfileImageView.heightAnchor.constraint(equalToConstant: 30),
                    recevierProfileImageView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
                    recevierProfileImageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
                    stackView.widthAnchor.constraint(lessThanOrEqualToConstant: (contentView.frame.width * 0.8) - 25),
                    stackView.topAnchor.constraint(equalTo: recevierProfileImageView.topAnchor),
                    stackView.leadingAnchor.constraint(equalTo: recevierProfileImageView.trailingAnchor, constant: 5),
                    stackView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
                    messageTimeStampLabel.leadingAnchor.constraint(equalTo: self.contentLabelBackgroundView.trailingAnchor, constant: 3),
                    messageTimeStampLabel.trailingAnchor.constraint(lessThanOrEqualTo: self.contentView.trailingAnchor),
                    messageTimeStampLabel.bottomAnchor.constraint(equalTo: self.contentLabelBackgroundView.bottomAnchor)
                ]
            }
            
            NSLayoutConstraint.activate(constraints)
            self.layoutConstraints = constraints
        }
    }
}
