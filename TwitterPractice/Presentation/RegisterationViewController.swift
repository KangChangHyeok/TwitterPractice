//
//  RegisterationViewController.swift
//  TwitterPractice
//
//  Created by 강창혁 on 2022/10/04.
//
import UIKit

import BuilderKit

final class RegisterationViewController: BaseViewController {
    // MARK: - Properties
    
    var viewModel = RegisterViewModel()
    
    private let imagePicker = UIImagePickerController()
    private var profileImage: UIImage?
    
    private lazy var plusPhotoButton = UIButtonBuilder(buttonType: .plain)
        .foregroundColor(.white)
        .image(.init(named: "plus_photo")?.withRenderingMode(.alwaysTemplate))
        .addAction { [weak self] _ in
            guard let self else { return }
            self.present(imagePicker, animated: true, completion: nil)
        }
        .create()
    
    private lazy var emailContainerView = InputTextFieldView(
        withImage: .init(named: "ic_mail_outline_white_2x-1"),
        textField: emailTextField
    )
    
    private lazy var passwordContainerView = InputTextFieldView(
        withImage: .init(named: "ic_lock_outline_white_2x"),
        textField: passwordTextField
    )
    
    private lazy var fullnameContainerView = InputTextFieldView(
        withImage: .init(named: "ic_person_outline_white_2x"),
        textField: fullnameTextField
    )
    
    private lazy var usernameContainerView = InputTextFieldView(
        withImage: .init(named: "ic_person_outline_white_2x"),
        textField: usernameTextField
    )
    
    private lazy var stackView = UIStackViewBuilder()
        .axis(.vertical)
        .spacing(20)
        .distribution(.fillEqually)
        .addArrangedSubviews([
            emailContainerView,
            passwordContainerView,
            fullnameContainerView,
            usernameContainerView,
            registrationButton])
        .create()
    
    private let emailTextField = UITextFieldBuilder()
        .attributedPlaceHolder(NSAttributedString(
            string: "이메일 입력",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        )
        .textColor(.white)
        .create()
    
    private let passwordTextField = UITextFieldBuilder()
        .attributedPlaceHolder(NSAttributedString(
            string: "비밀번호 입력",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        )
        .textColor(.white)
        .isSecureTextEntry(true)
        .create()
    
    private let fullnameTextField = UITextFieldBuilder()
        .attributedPlaceHolder(NSAttributedString(
            string: "이름",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        )
        .textColor(.white)
        .create()
    
    private let usernameTextField = UITextFieldBuilder()
        .attributedPlaceHolder(NSAttributedString(
            string: "트위터에서 사용할 이름",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        )
        .textColor(.white)
        .create()
    
    private lazy var registrationButton = UIButtonBuilder(buttonType: .filled)
        .backgroundColor(.white)
        .foregroundColor(.twitterBlue)
        .cornerRadius(5)
        .title("회원가입", font: .boldSystemFont(ofSize: 20))
        .addAction { [weak self] _ in
            guard let self else { return }
            // 프로필 이미지 등록 안됐을때
            guard let profileImage = profileImage?.jpegData(compressionQuality: 0.5) else {
                UIAlertController.presentAlert(title: "프로필 이미지를 등록해주세요!", messages: nil, self)
                return
            }
            guard let email = self.emailTextField.text else { return }
            guard let password = self.passwordTextField.text else { return }
            guard let fullname = self.fullnameTextField.text else { return }
            guard let username = self.usernameTextField.text?.lowercased() else { return }
            
            let userInfo = User(
                email: email,
                password: password,
                fullName: fullname,
                userName: username,
                profileImage: profileImage,
                follow: [],
                following: []
            )
            
            Task {
                do {
                    let user = try await NetworkManager.userCollection.document(userInfo.email).getDocument()
                    
                    guard user.exists == false else {
                        UIAlertController.presentAlert(title: "이미 가입된 계정입니다.", messages: nil, self)
                        return
                    }
                    // 등록되지 않은 email이라면 회원가입 처리하기
                    try await NetworkManager.userCollection.document(userInfo.email).setData([
                        "email": userInfo.email,
                        "password": userInfo.password,
                        "fullName": userInfo.fullName,
                        "userName": userInfo.userName,
                        "profileImage": userInfo.profileImage,
                        "follow": [],
                        "following": []
                    ])
                    print("DEBUG: 유저 회원가입 및 등록 완료")
                    UserDefaults.standard.set(true, forKey: "userIsLogin")
                    UserDefaults.standard.set(userInfo.email, forKey: "userID")
                    // 회원가입이 완료되었을때
                    guard let window = Screen.window,
                          let tab = window.rootViewController as? MainTabController else { return }
                    tab.checkUserIsloggedIn()
                    self.dismiss(animated: true)
                } catch {
                    print("DEBUG: \(error)")
                }
            }
        }
        .create()
    
    private lazy var alreadyHaveAccountButton = UIButtonBuilder(buttonType: .plain)
        .foregroundColor(.white)
        .attributedTitle(attributedString("이미 가입된 계정이 있다면?", " 로그인"))
        .addAction { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
        .create()
    
    // MARK: - Helpers
    
    override func setupDefaults(at viewController: UIViewController) {
        view.backgroundColor = .twitterBlue
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black
    }
    
    override func setupHierarchy(at view: UIView) {
        view.addSubview(plusPhotoButton)
        view.addSubview(stackView)
        view.addSubview(alreadyHaveAccountButton)
    }
    
    override func setupLayout(at view: UIView) {
        plusPhotoButton.snp.makeConstraints {
            $0.centerX.equalTo(view)
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.size.equalTo(CGSize(width: 128, height: 128))
        }
        stackView.snp.makeConstraints {
            $0.top.equalTo(plusPhotoButton.snp.bottom).offset(32)
            $0.leading.trailing.equalToSuperview().inset(32)
        }
        alreadyHaveAccountButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(40)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    func attributedString(_ firstPart: String?, _ secondPart: String?) -> AttributedString {
        guard let firstPart, let secondPart else { return AttributedString("nil") }
        var firstAttributedString = AttributedString(firstPart)
        firstAttributedString.font = .systemFont(ofSize: 16)
        firstAttributedString.foregroundColor = .white
        
        var secondAttributedString = AttributedString(secondPart)
        secondAttributedString.font = .boldSystemFont(ofSize: 16)
        secondAttributedString.foregroundColor = .white
        
        return firstAttributedString + secondAttributedString
    }
}

// MARK: - UIImagePickerControllerDelegate

extension RegisterationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        guard let profileImage = info[.editedImage] as? UIImage else { return }
        self.profileImage = profileImage
        profileImage.jpegData(compressionQuality: 1)
        plusPhotoButton.layer.cornerRadius = 128 / 2
        plusPhotoButton.layer.masksToBounds = true
        plusPhotoButton.imageView?.contentMode = .scaleAspectFill
        plusPhotoButton.imageView?.clipsToBounds = true
        plusPhotoButton.layer.borderColor = UIColor.white.cgColor
        plusPhotoButton.layer.borderWidth = 3
        plusPhotoButton.setImage(profileImage.withRenderingMode(.alwaysOriginal), for: .normal)
        dismiss(animated: true)
    }
}
