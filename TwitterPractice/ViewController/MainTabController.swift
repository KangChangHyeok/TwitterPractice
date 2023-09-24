//
//  MainTabController.swift
//  TwitterPractice
//
//  Created by 강창혁 on 2022/10/04.
//

import UIKit

import BuilderKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import SnapKit

final class MainTabController: BaseTabBarController {

    // MARK: - Properties

    var user: User? {
        didSet {
            guard let nav = viewControllers?[0] as? UINavigationController else { return }
            guard let feed = nav.viewControllers.first as? FeedController else { return }
            feed.user = user
        }
    }

    lazy var actionButton = UIButtonBuilder(buttonType: .plain)
        .backgroundColor(.twitterBlue)
        .foregroundColor(.white)
        .image(.init(named: "new_tweet"))
        .cornerRadius(28)
        .addAction { [weak self] _ in
            guard let user = self?.user else { return }
            let controller = UploadTweetViewController(user: user, config: .tweet)
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .fullScreen
            self?.present(nav, animated: true)
        }
        .create()

    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .twitterBlue
        authenticateUserAndConfigureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        tabBar.backgroundColor = .systemBackground
    }
    
    override func configure(controller: UITabBarController) {
        controller.view.backgroundColor = .twitterBlue
        authenticateUserAndConfigureUI()
    }
     
    override func configureUI() {
        view.addSubview(actionButton)
        actionButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-64)
            $0.trailing.equalToSuperview().offset(-16)
            $0.size.equalTo(CGSize(width: 56, height: 56))
        }
    }
    
    // MARK: - API
    
    private func fetchUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return}
        UserService.shared.fetchUser(uid: uid) { user in
            self.user = user
        }
    }
    
    func authenticateUserAndConfigureUI() {
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                let nav = UINavigationController(rootViewController: LoginViewController())
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true)
            }
        } else {
            configureViewControllers()
            configureUI()
            fetchUser()
        }
    }
    
    // MARK: - Helpers
    
    private func configureViewControllers() {
        let feed = templateNavigationController(
            image: UIImage(named: "home_unselected"),
            rootViewController: FeedController(collectionViewLayout: UICollectionViewFlowLayout())
        )
        let explore = templateNavigationController(
            image: UIImage(named: "search_unselected"),
            rootViewController: ExploreController()
        )
        let notifications = templateNavigationController(
            image: UIImage(named: "like_unselected"),
            rootViewController: NotificationController()
        )
        let conversations = templateNavigationController(
            image: UIImage(named: "ic_mail_outline_white_2x-1"), 
            rootViewController: ConversationsController()
        )
        viewControllers = [feed, explore, notifications, conversations]
    }
    
    func templateNavigationController(
        image: UIImage?,
        rootViewController: UIViewController
    ) -> UINavigationController {
        let nav = UINavigationController(rootViewController: rootViewController)
        nav.tabBarItem.image = image
        return nav
    }
}
