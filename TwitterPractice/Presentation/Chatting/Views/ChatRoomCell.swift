//
//  ChatRoomCell.swift
//  TwitterPractice
//
//  Created by kangChangHyeok on 08/04/2025.
//

import UIKit

import SnapKit

final class ChatRoomCell: BaseCVCell {
    
    private let recevierImageView = UIImageView().configure {
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 28
        $0.backgroundColor = .black
    }
    
    private lazy var recevierStackView = UIStackView(
        arrangedSubviews: [recevierNameLabel, lastMessageLabel]
    ).configure {
        $0.axis = .vertical
        $0.spacing = 4
    }
    
    private let recevierNameLabel = UILabel().configure {
        $0.text = "받는사람이름"
        $0.font = .systemFont(ofSize: 15)
    }
    
    private let lastMessageLabel = UILabel().configure {
        $0.text = "마지막메세지"
        $0.font = .systemFont(ofSize: 11)
    }
    
    private let dateLabel = UILabel().configure {
        $0.text = "4월 8일"
        $0.font = .systemFont(ofSize: 11)
    }
    
    override func setHierarchy(at view: UIView) {
        addSubview(recevierImageView)
        addSubview(recevierStackView)
        addSubview(dateLabel)
    }
    
    override func setLayout(at view: UIView) {
        recevierImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(8)
            make.size.equalTo(CGSize(width: 56, height: 56))
        }
        recevierStackView.snp.makeConstraints { make in
            make.centerY.equalTo(recevierImageView)
            make.leading.equalTo(recevierImageView.snp.trailing).offset(8)
        }
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(recevierStackView)
            make.trailing.equalToSuperview().inset(20)
        }
    }
    
    func bind(_ chatRoom: ChatRoom) {
        let loginUserID = UserDefaults.fecthUserID()!
        let recevierUser = chatRoom.joinedUsers.filter { $0.email != loginUserID }.first!
        let loginUser = chatRoom.joinedUsers.filter { $0.email == loginUserID }.first!
        
        recevierImageView.image = UIImage(data: recevierUser.profileImage)
        recevierNameLabel.text = recevierUser.userName
        lastMessageLabel.text = chatRoom.lastMessage
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM월 dd일"
        
        guard let lastMessageSendTime = chatRoom.lastMessageTime else {
            return
        }
        dateLabel.text = dateFormatter.string(from: lastMessageSendTime)
    }
}
