//
//  InputTextFieldView.swift
//  TwitterPractice
//
//  Created by 강창혁 on 2023/09/23.
//

import UIKit

import BuilderKit
import SnapKit

final class InputTextFieldView: UIView {
    
    let imageView = UIImageView()
    
    var textField: UITextField
    
    private let dividerView = UIViewBuilder()
        .backgroundColor(color: .white)
        .create()
    
    init(withImage: UIImage?, textField: UITextField) {
        self.textField = textField
        super.init(frame: .init(x: 0, y: 0, width: 0, height: 0))
        self.imageView.image = withImage
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        self.snp.makeConstraints {
            $0.height.equalTo(50)
        }
        
        self.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.leading.bottom.equalToSuperview().inset(8)
            $0.size.equalTo(CGSize(width: 24, height: 24))
        }
        self.addSubview(textField)
        textField.snp.makeConstraints {
            $0.leading.equalTo(imageView.snp.trailing).offset(8)
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(8)
        }
        self.addSubview(dividerView)
        dividerView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(8)
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(0.75)
        }
    }
}
