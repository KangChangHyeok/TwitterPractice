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
            string: "Email",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        )
        .create()
    
    private let passwordTextField = UITextFieldBuilder()
        .textColor(.white)
        .font(.systemFont(ofSize: 16))
        .attributedPlaceHolder(NSAttributedString(
            string: "Password",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        )
        .isSecureTextEntry(true)
        .create()
    
    private lazy var loginButton = UIButtonBuilder(buttonType: .filled)
        .title("Log In",font: .boldSystemFont(ofSize: 20) , color: .twitterBlue)
        .backgroundColor(.white)
        .cornerRadius(5)
        .addAction { [weak self] _ in
            guard let self else { return }
            guard let email = emailTextField.text,
                  let password = passwordTextField.text else { return }
            viewModel.userLogin(email: email, password: password) {_, error in
                if let error = error {
                    print("DEBUG: Login Error \(error.localizedDescription)")
                    return
                }
                guard let window = Screen.window else { return }
                guard let tab = window.rootViewController as? MainTabController else { return }
                tab.authenticateUserAndConfigureUI()
                self.dismiss(animated: true)
            }
        }
        .create()
    
    private lazy var dontHaveAccountButton = UIButtonBuilder(buttonType: .plain)
        .foregroundColor(.white)
        .attributedTitle(attributedString("Dont Have an account", " Sign Up"))
        .addAction { [weak self] _ in
            let controller = RegisterationViewController()
            self?.navigationController?.pushViewController(controller, animated: true)
        }
        .create()

    // MARK: - Helpers
    
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
    private func attributedString(_ firstPart: String?, _ secondPart: String?) -> AttributedString {
        guard let firstPart, let secondPart else { return AttributedString("nil") }
        var firstAttributedString = AttributedString(firstPart)
        firstAttributedString.font = .systemFont(ofSize: 16)
        
        var secondAttributedString = AttributedString(secondPart)
        secondAttributedString.font = .boldSystemFont(ofSize: 16)
        
        return firstAttributedString + secondAttributedString
    }
}
