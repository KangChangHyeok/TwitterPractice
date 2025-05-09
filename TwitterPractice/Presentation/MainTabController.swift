//
//  MainTabController.swift
//  TwitterPractice
//
//  Created by 강창혁 on 2022/10/04.
//

import UIKit

import SnapKit

final class MainTabController: UITabBarController {
    
    // MARK: - Properties
    
    private lazy var tweetRegisterButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .twitterBlue
        button.tintColor = .white
        button.setImage(.init(named: "new_tweet"), for: .normal)
        button.layer.cornerRadius = 28
        button.addTarget(self, action: #selector(actionButtonDidTap), for: .touchUpInside)
        return button
    }()
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .twitterBlue
        self.delegate = self
        configureUI()
        checkUserIsloggedIn()
        NotificationCenter.default.addObserver(
            self, selector: #selector(userLogout), name: NSNotification.Name("userLogout"), object: nil
        )
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
    
    func configureUI() {
        view.addSubview(tweetRegisterButton)
        tweetRegisterButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-64)
            $0.trailing.equalToSuperview().offset(-16)
            $0.size.equalTo(CGSize(width: 56, height: 56))
        }
    }
    
    func setTweetButtonIsHidden(_ isHidden: Bool) {
        self.tweetRegisterButton.isHidden = isHidden
    }
    
    // MARK: - API
    
    func checkUserIsloggedIn() {
        guard UserDefaults.userIsLogin() else {
            DispatchQueue.main.async { [weak self] in
                let nav = LoginNavigationController(rootViewController: LoginViewController())
                nav.modalPresentationStyle = .fullScreen
                self?.present(nav, animated: true)
            }
            return
        }
        tweetRegisterButton.isHidden = false
        configureViewControllers()
    }
    
    // MARK: - Helpers
    
    func configureViewControllers() {
        let feed = templateNavigationController(
            image: UIImage(named: "home_unselected"),
            rootViewController: HomeFeedViewController()
        )
        let explore = templateNavigationController(
            image: UIImage(named: "search_unselected"),
            rootViewController: UserSearchViewController()
        )
        let notifications = templateNavigationController(
            image: UIImage(named: "like_unselected"),
            rootViewController: NotificationController()
        )
        let conversations = templateNavigationController(
            image: UIImage(named: "ic_mail_outline_white_2x-1"),
            rootViewController: ChattingsViewController()
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
    
    @objc func actionButtonDidTap() {
        let controller = UploadTweetViewController(config: .tweet)
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true)
    }
    
    @objc func userLogout() {
        UserDefaults.standard.set(false, forKey: "userIsLogin")
        UserDefaults.standard.removeObject(forKey: "userID")
        self.viewControllers = []
        let navigationController = UINavigationController(rootViewController: LoginViewController())
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: true)
    }
}

extension MainTabController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        let tweetButtonIsHidden = viewController === self.viewControllers?[3]
        
        tweetRegisterButton.isHidden = tweetButtonIsHidden
    }
}
