//
//  EditProfileController.swift
//  TwitterPractice
//
//  Created by 강창혁 on 2022/11/01.
//

import UIKit

import Firebase

private let reuserIdentifier = "EditProfileCell"

final class ProfileEditController: UITableViewController {
    
    // MARK: - Properties
    
    private var user: User?
    
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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UINavigationBarAppearance().backgroundColor = .white
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
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
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
        view.endEditing(true)
        
        guard let fullName = (tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? EditProfileCell)?.bioTextView.text else { return }
        guard let userName = (tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? EditProfileCell)?.bioTextView.text else { return }
        guard let userEmail = user?.email else { return }
        guard let profileImage = headerView.profileImageView.image?.jpegData(compressionQuality: 0.5) else {
            return
        }
        Task {
            do {
                try await NetworkManager.userCollection.document(userEmail).updateData([
                    "fullName": fullName,
                    "userName": userName,
                    "profileImage": profileImage
                ])
                
                let documents = try await NetworkManager.tweetCollection.whereField("user.email", isEqualTo: userEmail).getDocuments().documents
                
                print(documents)
                let db = Firestore.firestore()
                let batch = db.batch()
                
                
                documents.forEach { snapshot in
                    batch.updateData([
                        "user.fullName": fullName,
                        "user.userName": userName,
                        "user.profileImage": profileImage
                    ], forDocument: snapshot.reference)
                }
                
                try await batch.commit()
            } catch {
                print(error)
            }
            self.dismiss(animated: true)
        }
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
        headerView.profileImageView.image = image
        dismiss(animated: true)
    }
}
// MARK: - EditProfileCellDelegate

extension ProfileEditController: EditProfileCellDelegate {
    func updateUserInfo(_ cell: EditProfileCell) {
    }
}
