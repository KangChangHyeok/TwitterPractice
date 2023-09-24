//
//  LoginViewController.swift
//  TwitterPractice
//
//  Created by 강창혁 on 2022/10/04.
//

import UIKit

import BuilderKit
import SnapKit

final class LoginViewController: BaseViewController {
    // MARK: - Properties
    
    var viewModel = LoginViewModel()
    
    private let logoImageView = UIImageViewBuilder()
        .contentMode(.scaleAspectFit)
        .image(.init(named: "TwitterLogo"))
        .create()
    
    private lazy var emailContainerView = InputTextFieldView(
        withImage: UIImage(named: "ic_mail_outline_white_2x-1"),
        textField: emailTextField)
    
    private lazy var passwordContainerView = InputTextFieldView(
        withImage: UIImage(named: "ic_lock_outline_white_2x"),
        textField: passwordTextField
    )
    
    private lazy var stackView = UIStackViewBuilder()
        .axis(.vertical)
        .spacing(20)
        .distribution(.fillEqually)
        .addArrangedSubviews([emailContainerView, passwordContainerView, loginButton])
        .create()
    
    private let emailTextField = UITextFieldBuilder()
        .textColor(.white)
        .font(.systemFont(ofSize: 16))
        .attributedPlaceHolder(NSAttributedString(
            string: "이메일 입력",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        )
        .create()
    
    private let passwordTextField = UITextFieldBuilder()
        .textColor(.white)
        .font(.systemFont(ofSize: 16))
        .attributedPlaceHolder(NSAttributedString(
            string: "비밀번호 입력",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        )
        .isSecureTextEntry(true)
        .create()
    
    private lazy var loginButton = UIButtonBuilder(buttonType: .filled)
        .title("로그인",font: .boldSystemFont(ofSize: 20) , color: .twitterBlue)
        .backgroundColor(.white)
        .cornerRadius(5)
        .addAction { [weak self] _ in
            guard let self else { return }
            self.loginButtonDidTap()
        }
        .create()
    
    private lazy var dontHaveAccountButton = UIButtonBuilder(buttonType: .plain)
        .foregroundColor(.white)
        .attributedTitle(attributedString("아직 회원이 아니라면?", " 회원가입"))
        .addAction { [weak self] _ in
            let controller = RegisterationViewController()
            self?.navigationController?.pushViewController(controller, animated: true)
        }
        .create()

    // MARK: - Override Methods
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func configureUI() {
        view.backgroundColor = .twitterBlue
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black
        
        view.addSubview(logoImageView)
        
        logoImageView.snp.makeConstraints {
            $0.centerX.equalTo(view)
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.size.equalTo(CGSize(width: 150, height: 150))
        }
        
        view.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.top.equalTo(logoImageView.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(32)
        }
        
        view.addSubview(dontHaveAccountButton)
        dontHaveAccountButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(40)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func attributedString(
        _ firstPart: String?,
        _ secondPart: String?
    ) -> AttributedString {
        guard let firstPart, let secondPart else { return AttributedString("nil") }
        var firstAttributedString = AttributedString(firstPart)
        firstAttributedString.font = .systemFont(ofSize: 16)
        
        var secondAttributedString = AttributedString(secondPart)
        secondAttributedString.font = .boldSystemFont(ofSize: 16)
        
        return firstAttributedString + secondAttributedString
    }
    
    private func loginButtonDidTap() {
        guard let email = emailTextField.text, email.isEmpty == false
        else {
            UIAlertController.presentAlert(
                title: "이메일 미 입력",
                messages: "이메일이 입력되지 않았습니다. 이메일을 입력해주세요.",
                self
            )
            return
        }
        guard let password = passwordTextField.text, password.isEmpty == false
        else {
            
            UIAlertController.presentAlert(
                title: "비밀번호 미 입력",
                messages: "비밀번호가 입력되지 않았습니다. 비밀번호를 입력해주세요.",
                self
            )
            return
        }
        viewModel.userLogin(email: email, password: password) {_, error in
            if let error = error {
                print("DEBUG: Login Error \(error.localizedDescription), alert 표시")
                UIAlertController.presentAlert(
                    title: "로그인 실패",
                    messages: "입력하신 이메일과 비밀번호를 다시 확인해 주세요.",
                    self
                )
                return
            }
            guard let window = Screen.window else { return }
            guard let tab = window.rootViewController as? MainTabController else { return }
            tab.authenticateUserAndConfigureUI()
            self.dismiss(animated: true)
        }
    }
}
