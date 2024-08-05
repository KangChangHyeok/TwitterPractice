//
//  ProfileController.swift
//  TwitterPractice
//
//  Created by 강창혁 on 2022/10/11.
//

import UIKit
import FirebaseAuth

private let headerIdentifier = "ProfileHeader"

final class ProfileController: BaseViewController {
    
    // MARK: - Properties
    
    private enum Section {
        case tweet
    }
    
    private var user: User?
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, Tweet>?
    
    private var selectedFilter: ProfileFilterOptions = .tweets
    
    private var tweets = [Tweet]()
    
    private lazy var tweetCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .white
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.bounces = false
        return collectionView
    }()
    
    // MARK: - Set
    
    override func setDefaults(at viewController: UIViewController) {
        configureDataSource()
        requestUser()
        requestUserTweets()
        //        fetchLikedTweets()
        //        fetchReplies()
        //        checkIfUserIsFollowed()
        //        fetchUserStats()
    }
    
    override func setHierarchy(at view: UIView) {
        view.addSubview(tweetCollectionView)
    }
    
    override func setLayout(at view: UIView) {
        tweetCollectionView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    // MARK: - LifeCycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.isHidden = true
        let mainTab = tabBarController as? MainTabController
        mainTab?.setTweetButtonIsHidden(true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        let mainTab = tabBarController as? MainTabController
        mainTab?.setTweetButtonIsHidden(false)
    }
    
    func configureDataSource() {
        let profileHeaderRegisteration = UICollectionView.SupplementaryRegistration<ProfileHeader>(elementKind: "ProfileHeader") { [weak self] supplementaryView, elementKind, indexPath in
            supplementaryView.user = self?.user
        }
        
        let tweetCellRegisteration = UICollectionView.CellRegistration<TweetCell, Tweet> {
            cell, indexPath, tweet in
            cell.bind(tweet: tweet)
        }
        
        self.dataSource = UICollectionViewDiffableDataSource<Section, Tweet>(collectionView: self.tweetCollectionView) { collectionView, indexPath, tweet in
            return collectionView.dequeueConfiguredReusableCell(using: tweetCellRegisteration, for: indexPath, item: tweet)
        }
        
        dataSource?.supplementaryViewProvider = { view, kind, indexPath in
            return view.dequeueConfiguredReusableSupplementary(using: profileHeaderRegisteration, for: indexPath)
        }
    }
    
    func createLayout() -> UICollectionViewLayout {
        let estimatedHeight = CGFloat(100)
        let layoutSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(estimatedHeight)
        )
        let item = NSCollectionLayoutItem(layoutSize: layoutSize)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: layoutSize, repeatingSubitem: item, count: 1)
        
        let sectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(300))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: sectionHeaderSize, elementKind: "ProfileHeader", alignment: .top)
        
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [sectionHeader]
        section.interGroupSpacing = 10
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    // MARK: - API
    
    func requestUser() {
        Task {
            guard let userID = UserDefaults.fecthUserID() else { return }
            self.user = try await NetworkManager.requestUser(userID: userID)
        }
    }

    func requestUserTweets() {
        Task {
            guard let userID = UserDefaults.fecthUserID() else { return }
            self.tweets = try await NetworkManager.tweetCollection.getDocuments().documents.map { try $0.data(as: Tweet.self)
            }.filter { $0.user.email == userID }
            
            var snapshot = NSDiffableDataSourceSnapshot<Section, Tweet>()
            snapshot.appendSections([.tweet])
            snapshot.appendItems(self.tweets)
            await dataSource?.apply(snapshot)
        }
    }
    func fetchLikedTweets() {
//        TweetService.shared.fetchLikes(forUser: user) { tweets in
//            self.likedTweets = tweets
//        }
    }
    func fetchReplies() {
//        TweetService.shared.fetchReplies(forUser: user) { tweets in
//            self.replies = tweets
//        }
    }
    func checkIfUserIsFollowed() {
//        UserService.shared.checkIfUserIsFollowed(uid: user.uid) { isFollowed in
//            self.user.isFollowed = isFollowed
//            self.collectionView.reloadData()
//        }
    }
    func fetchUserStats() {
//        UserService.shared.fetchUserStats(uid: user.uid) { stats in
//            self.user.stats = stats
//            self.collectionView.reloadData()
//        }
    }
}

// MARK: - UICollectionViewDelegate

extension ProfileController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let controller = TweetController(tweet: currentDataSource[indexPath.row])
//        navigationController?.pushViewController(controller, animated: true)
    }
}

extension ProfileController: ProfileHeaderDelegate {
    func didSelect(filter: ProfileFilterOptions) {
        self.selectedFilter = filter
    }
    
    func handleEditProfileFollow(_ header: ProfileHeader) {
//        if user.isCurrentUser {
//            let controller = EditProfileController(user: user)
//            controller.delegate = self
//            let nav = UINavigationController(rootViewController: controller)
//            nav.modalPresentationStyle = .fullScreen
//            present(nav, animated: true)
//            return
//        }
//        if user.isFollowed {
//            UserService.shared.unfollowUser(uid: user.uid) { _, _ in
//                self.user.isFollowed = false
//                self.collectionView.reloadData()
//            }
//        } else {
//            UserService.shared.followUser(uid: user.uid) { _, _ in
//                self.user.isFollowed = true
//                self.collectionView.reloadData()
//                NotificationService.shared.uploadNotification(toUser: self.user, type: .follow)
//            }
//        }
    }
    func handleDismissal() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - EditProfileControllerDelegate


extension ProfileController: EditProfileControllerDelegate {
    func handleLogout() {
            do {
                try Auth.auth().signOut()
                let nav = UINavigationController(rootViewController: LoginViewController())
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true)
            } catch let error {
                print("DEBUG: Failed to sign out with error \(error.localizedDescription)")
            }
    }
    
    func controller(_ controller: EditProfileController, wantsToUpdate user: UserInfo) {
        controller.dismiss(animated: true)
//        self.user = user
        self.tweetCollectionView.reloadData()
    }
}
