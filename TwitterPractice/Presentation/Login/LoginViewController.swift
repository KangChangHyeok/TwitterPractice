//
//  LoginViewController.swift
//  TwitterPractice
//
//  Created by 강창혁 on 2022/10/04.
//

import UIKit

import SnapKit

final class LoginViewController: BaseViewController {
    
    // MARK: - Properties
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    private let logoImageView = UIImageView().configure(configuration: {
        $0.contentMode = .scaleAspectFit
        $0.image = .init(named: "TwitterLogo")
    })
    
    private lazy var emailContainerView = InputTextFieldView(
        withImage: UIImage(named: "ic_mail_outline_white_2x-1"),
        textField: emailTextField)
    
    private lazy var passwordContainerView = InputTextFieldView(
        withImage: UIImage(named: "ic_lock_outline_white_2x"),
        textField: passwordTextField
    )
    
    private lazy var stackView = UIStackView().configure(configuration: {
        $0.addArrangedSubview(emailContainerView)
        $0.addArrangedSubview(passwordContainerView)
        $0.addArrangedSubview(loginButton)
        $0.axis = .vertical
        $0.spacing = 20
        $0.distribution = .fillEqually
    })
        
    private let emailTextField = UITextField().configure(configuration: {
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 16)
        $0.attributedPlaceholder = NSAttributedString(
            string: "이메일 입력",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
    })
    
    private let passwordTextField = UITextField().configure(configuration: {
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 16)
        $0.attributedPlaceholder = NSAttributedString(
            string: "비밀번호 입력",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        $0.isSecureTextEntry = true
    })
    
    private lazy var loginButton = UIButton().configure {
        $0.setTitle("로그인", for: .normal)
        $0.backgroundColor = .white
        $0.titleLabel?.font = .boldSystemFont(ofSize: 20)
        $0.setTitleColor(.twitterBlue, for: .normal)
        $0.layer.cornerRadius = 5
        $0.addAction(loginButtonAction, for: .touchUpInside)
    }
    
    private lazy var loginButtonAction = UIAction { [weak self] _ in
        self?.loginButtonDidTap()
    }
    
    private lazy var dontHaveAccountButton = UIButton().configure {
        $0.setTitleColor(.white, for: .normal)
        $0.setTitle("아직 회원이 아니라면?  회원가입", for: .normal)
        $0.addAction(dontHaveAccountButtonAction, for: .touchUpInside)
    }
    
    private lazy var dontHaveAccountButtonAction = UIAction { [weak self] _ in
        let controller = RegisterationViewController()
        self?.navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: - Life Cycle
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func setupDefaults() {
        view.backgroundColor = .twitterBlue
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black
    }
    
    override func setupHierarchy() {
        view.addSubview(logoImageView)
        view.addSubview(stackView)
        view.addSubview(dontHaveAccountButton)
        
    }
    
    override func setupLayout() {
        logoImageView.snp.makeConstraints {
            $0.centerX.equalTo(view)
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.size.equalTo(CGSize(width: 150, height: 150))
        }
        stackView.snp.makeConstraints {
            $0.top.equalTo(logoImageView.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(32)
        }
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
        // email
        guard let email = emailTextField.text, email.isEmpty == false else {
            UIAlertController.presentAlert(
                title: "이메일 미 입력",
                messages: "이메일이 입력되지 않았습니다. 이메일을 입력해주세요.",
                self
            )
            return
        }
        //password
        guard let inputPassword = passwordTextField.text, inputPassword.isEmpty == false else {
            UIAlertController.presentAlert(
                title: "비밀번호 미 입력",
                messages: "비밀번호가 입력되지 않았습니다. 비밀번호를 입력해주세요.",
                self
            )
            return
        }
        // email, password 모두 입력시 db 조회해서 email - password 일치 확인
        Task {
            do {
                let userRef = NetworkService.userCollection.document(email)
                let userDocument = try await userRef.getDocument()
                
                //email 검증
                guard userDocument.exists else {
                    
                    UIAlertController.presentAlert(
                        title: "입력된 정보 오류",
                        messages: "존재하지 않는 아이디입니다.",
                        self
                    )
                    return
                }
                
                // 해당 아이디와 비밀번호 일치하는지 확인
                let user = try userDocument.data(as: User.self)
                
                guard user.password == inputPassword else {
                    UIAlertController.presentAlert(title: "입력된 정보 오류", messages: "비밀번호가 일치하지 않습니다", self)
                    return
                }
                // user정보 저장
                UserDefaults.standard.set(true, forKey: "userIsLogin")
                UserDefaults.standard.set(email, forKey: "userID")
                
                guard let window = Screen.window else { return }
                guard let tab = window.rootViewController as? MainTabController else { return }
                tab.checkUserIsloggedIn()
                
                self.dismiss(animated: true)
            } catch {
                print(error)
            }
        }
    }
}
