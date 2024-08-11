//
//  EditProfileController.swift
//  TwitterPractice
//
//  Created by 강창혁 on 2022/11/01.
//

import UIKit

private let reuserIdentifier = "EditProfileCell"

protocol EditProfileControllerDelegate: AnyObject {
    func handleLogout()
}

final class ProfileEditController: UITableViewController {
    
    // MARK: - Properties
    
    private var user: User?
    
    private var userInfoChanged = false
    
    weak var delegate: EditProfileControllerDelegate?
    
    private var imageChanged: Bool {
        return selectedImage != nil
    }
    
    private var selectedImage: UIImage? {
        didSet { headerView.profileImageView.image = selectedImage }
    }
    
    // MARK: - UI
    
    private lazy var headerView: EditProfileHeader = {
        let headerView = EditProfileHeader()
        headerView.changePhotoButton.addTarget(self, action: #selector(profileButtonDidTap), for: .touchUpInside)
        return headerView
    }()
    
    private lazy var footerView: EditProfileFooter = {
        let view = EditProfileFooter()
        view.logoutButton.addTarget(self, action: #selector(logoutButtonDidTap), for: .touchUpInside)
        return view
    }()
        
    private let imagePicker = UIImagePickerController()
    
    // MARK: - Lifecycle
    
    init(user: User?) {
        self.user = user
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureImagePicker()
        configureNavigationBar()
        configureTableView()
        configureProfileImage()
    }
}

// MARK: - Private

private extension ProfileEditController {
    
    func configureImagePicker() {
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
    }
    
    func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.twitterBlue
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = .white
        
        navigationItem.title = "프로필 수정"
        navigationItem.titleView?.tintColor = .white
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonDidTap))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonDidTap))
        
    }
    
    func configureTableView() {
        tableView.tableHeaderView = headerView
        headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 180)
        
        footerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 100)
        tableView.tableFooterView = footerView
        
        tableView.register(EditProfileCell.self, forCellReuseIdentifier: reuserIdentifier)
    }
    
    func updateUserData() {
        if imageChanged && !userInfoChanged {
        }
        
        if userInfoChanged && !imageChanged {
//            UserService.shared.saveUserData(user: user) { err, ref in
//                self.delegate?.controller(self, wantsToUpdate: self.user)
//            }
        }
        
        if userInfoChanged && imageChanged {
//            UserService.shared.saveUserData(user: user) { err, ref in
//                self.updateProfileImage()
//            }
        }
    }
    
    func configureProfileImage() {
        guard let user else { return }
        headerView.profileImageView.image = .init(data: user.profileImage)
    }
}

// MARK: - @Objc

private extension ProfileEditController {
    
    @objc func cancelButtonDidTap() {
        self.dismiss(animated: true)
    }
    
    @objc func doneButtonDidTap() {
        self.dismiss(animated: true)
        view.endEditing(true)
        guard imageChanged || userInfoChanged else { return }
        updateUserData()
    }
    
    @objc func profileButtonDidTap() {
        present(imagePicker, animated: true)
    }
    
    @objc func logoutButtonDidTap() {
        // 유저 정보 삭제
        UserDefaults.standard.set(false, forKey: "userIsLogin")
        UserDefaults.standard.removeObject(forKey: "userID")
        
        let alret = UIAlertController(title: nil, message: "로그아웃 하시겠습니까?", preferredStyle: .actionSheet)
        alret.addAction(UIAlertAction(title: "로그아웃", style: .destructive, handler: { _ in
            self.dismiss(animated: true) {
                NotificationCenter.default.post(name: NSNotification.Name("userLogout"), object: nil)
            }
        }))
        
        alret.addAction(UIAlertAction(title: "취소", style: .cancel))
        
        present(alret, animated: true)
    }
}
// MARK: - UITableViewDataSource

extension ProfileEditController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuserIdentifier, for: indexPath) as? EditProfileCell
        
        guard let cell = cell else { return UITableViewCell() }
        cell.delegate = self
        switch indexPath.row {
        case 0:
            cell.bind(title: "fullName", description: user?.fullName)
        case 1:
            cell.bind(title: "userName", description: user?.userName)
        default: break
        }
        return cell
    }
}

extension ProfileEditController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let option = EditProfileOptions(rawValue: indexPath.row) else { return 0 }
        return option == .bio ? 100 : 48
    }
}

// MARK: - UIImagePickerControllerDelegate

extension ProfileEditController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        guard let image = info[.editedImage] as? UIImage else { return }
        self.selectedImage = image
        dismiss(animated: true)
    }
}
// MARK: - EditProfileCellDelegate

extension ProfileEditController: EditProfileCellDelegate {
    func updateUserInfo(_ cell: EditProfileCell) {
//        guard let viewModel = cell.viewModel else { return }
//        userInfoChanged = true
//        navigationItem.rightBarButtonItem?.isEnabled = true
        
//        switch viewModel.option {
//            
//        case .fullname:
//            guard let fullname = cell.infoTextField.text else { return }
//            user?.fullName = fullname
//        case .username:
//            guard let username = cell.infoTextField.text else { return }
//            user.username = username
//        case .bio:
//            user.bio = cell.bioTextView.text
//        }
    }
}

//extension ProfileEditController: EditProfileFooterDelegate {
//    
//    func handleLogout() {
//        let alret = UIAlertController(title: nil, message: "Are you sure you want to log out?", preferredStyle: .actionSheet)
//        alret.addAction(UIAlertAction(title: "Log out", style: .destructive, handler: { _ in
//            self.dismiss(animated: true) {
//                self.delegate?.handleLogout()
//            }
//        }))
//        
//        alret.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//        
//        present(alret, animated: true)
//    }
//    
//}
