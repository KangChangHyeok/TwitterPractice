//
//  MessageInputView.swift
//  TwitterPractice
//
//  Created by kangChangHyeok on 08/04/2025.
//

import UIKit

final class MessageInputView: BaseView {
    
    //MARK: - UI Components
    
    private lazy var border = UIView().configure {
        $0.layer.borderColor = UIColor.gray.cgColor
        $0.layer.borderWidth = 0.7
        $0.layer.cornerRadius = 17.5
        $0.backgroundColor = .clear
    }
    
    lazy var textView = UITextView().configure {
        $0.font = .systemFont(ofSize: 15)
        $0.backgroundColor = .white
        $0.textContainerInset = .init(top: 4, left: 0, bottom: 4, right: 0)
        $0.delegate = self
    }
    
    lazy var messageSendButton = UIButton().configure {
        $0.setImage(.init(systemName: "chevron.right")?.withTintColor(.white), for: .normal)
        $0.backgroundColor = .twitterBlue
        $0.layer.cornerRadius = 12.5
        $0.isEnabled = false
        $0.alpha = 0.5
    }
    
    // MARK: - Setup
    
    override func setHierarchy(at view: UIView) {
        border.addSubview(textView)
        border.addSubview(messageSendButton)
        view.addSubview(border)
    }
    
    override func setLayout(at view: UIView) {
        textView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(5)
            make.leading.equalToSuperview().inset(10)
            make.height.equalTo(25)
            make.centerY.equalToSuperview()
        }
        messageSendButton.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 25, height: 25))
            make.top.equalToSuperview().inset(5)
            make.leading.equalTo(textView.snp.trailing).offset(5)
            make.trailing.equalToSuperview().inset(10)
        }
        border.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(5)
            make.leading.trailing.equalToSuperview().inset(15)
        }
    }
    
    func reset() {
        textView.text = ""
        messageSendButton.isEnabled = false
    }
}

// MARK: - UITextViewDelegate

extension MessageInputView: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        messageSendButton.isEnabled = textView.text.isEmpty == false
        messageSendButton.alpha = textView.text.isEmpty == false ? 1 : 0.5
        
        let size = CGSize(width: textView.textContainer.size.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        textView.constraints.forEach { (constraint) in
            guard estimatedSize.height >= 25 else { return }
            guard constraint.firstAttribute == .height else { return }
            constraint.constant = estimatedSize.height
        }
    }
}
