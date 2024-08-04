//
//  FeedController.swift
//  TwitterPractice
//
//  Created by 강창혁 on 2022/10/04.
//

import UIKit
import SDWebImage

private let reuseIdentifier = "TweetCell"

final class FeedViewController: BaseViewController {
    
    private enum Section {
        case main
    }
    
    // MARK: - Properties
    
    private var user: User? {
        didSet {
            configureLeftBarButton(user: user)
        }
    }
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, Tweet>?
    
    // MARK: - UI
    
    private lazy var tweetCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createTweetCollectionViewLayout())
        collectionView.backgroundColor = .white
        collectionView.refreshControl = refreshControl
        collectionView.delegate = self
        return collectionView
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        return refreshControl
    }()
    
    
    // MARK: - Set
    
    override func setDefaults(at viewController: UIViewController) {
        viewController.view.backgroundColor = .white
        let imageView = UIImageView(image: UIImage(named: "twitter_logo_blue"))
        imageView.contentMode = .scaleAspectFit
        imageView.setDimensions(width: 44, height: 44)
        viewController.navigationItem.titleView = imageView
        configureDataSource()
        requestUser()
        requestTweets()
    }
    
    override func setHierarchy(at view: UIView) {
        view.addSubview(tweetCollectionView)
    }
    
    override func setLayout(at view: UIView) {
        tweetCollectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    func createTweetCollectionViewLayout() -> UICollectionViewLayout {
        let estimatedHeight = CGFloat(100)
        let layoutSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(estimatedHeight)
        )
        let item = NSCollectionLayoutItem(layoutSize: layoutSize)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: layoutSize, repeatingSubitem: item, count: 1)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    func configureDataSource() {
        let tweetCellRegisteration = UICollectionView.CellRegistration<TweetCell, Tweet> { cell, indexPath, tweet in
            cell.bind(tweet: tweet)
            cell.delegate = self
        }
        
        let dataSource = UICollectionViewDiffableDataSource<Section, Tweet>(collectionView: tweetCollectionView) { collectionView, indexPath, tweet in
            return collectionView.dequeueConfiguredReusableCell(using: tweetCellRegisteration, for: indexPath, item: tweet)
        }
        self.dataSource = dataSource
    }
    
    func requestUser() {
        Task {
            guard let userID = UserDefaults.fecthUserID() else { return }
            self.user = try await NetworkManager.requestUser(userID: userID)
        }
    }
    
    // MARK: - Selectors
    
    @objc func handleRefresh() {
        Task {
            refreshControl.beginRefreshing()
            let tweets = try await NetworkManager.tweetCollection.getDocuments().documents.map { try $0.data(as: Tweet.self) }
            var snapShot = NSDiffableDataSourceSnapshot<Section, Tweet>()
            snapShot.appendSections([.main])
            snapShot.appendItems(tweets)
            await dataSource?.apply(snapShot, animatingDifferences: true)
            refreshControl.endRefreshing()
        }
    }
    
    @objc func handleProfileImageTap() {
        let controller = ProfileController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func configureLeftBarButton(user: User?) {
        guard let user = user else { return }
        
        let profileImageView = UIImageView()
        profileImageView.setDimensions(width: 32, height: 32)
        profileImageView.layer.cornerRadius = 32 / 2
        profileImageView.layer.masksToBounds = true
        profileImageView.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleProfileImageTap))
        profileImageView.addGestureRecognizer(tap)
        
        profileImageView.image = .init(data: user.profileImage)

        navigationController?.navigationBar.barStyle = .default
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: profileImageView)
    }
    
    func requestTweets() {
        Task {
            do {
                let tweets = try await NetworkManager.tweetCollection.getDocuments().documents.map { try $0.data(as: Tweet.self) }
                var snapShot = NSDiffableDataSourceSnapshot<Section, Tweet>()
                snapShot.appendSections([.main])
                snapShot.appendItems(tweets)
                await dataSource?.apply(snapShot, animatingDifferences: true)
            } catch {
                print("error", error)
            }
        }
    }
}

// MARK: - UICollectionViewDelegate/DataSource

extension FeedViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let controller = TweetController(tweet: tweets[indexPath.row])
//        navigationController?.pushViewController(controller, animated: true)
    }
}

// MARK: - TweetCellDelegate

extension FeedViewController: TweetCellDelegate {
    func handleFetchUser(withUsername username: String) {
//        UserService.shared.fetchUser(WithUsername: username) { user in
//            let controller = ProfileController(user: user)
//            self.navigationController?.pushViewController(controller, animated: true)
//        }
    }
    
    func handleLikeTapped(_ cell: TweetCell) {
//        guard let tweet = cell.tweet else { return }
//        TweetService.shared.likeTweet(tweet: tweet) { _, _ in
//            cell.tweet?.didLike.toggle()
//            let likes = tweet.didLike ? tweet.likes - 1 : tweet.likes + 1
//            cell.tweet?.likes = likes
//            guard !tweet.didLike else { return }
//            NotificationService.shared.uploadNotification(toUser: tweet.user, type: .like, tweetID: tweet.tweetID)
//        }
    }
    func handleProfileImageTapped(_ cell: TweetCell) {
//        guard let user = cell.tweet?.user else { return }
        guard let indexPath = tweetCollectionView.indexPath(for: cell) else { return }
        
        let tweets = dataSource?.snapshot().itemIdentifiers[indexPath.row]
        let controller = ProfileController(user: tweets?.user)
        navigationController?.pushViewController(controller, animated: true)
    }
    func handleReplyTapped(_ cell: TweetCell) {
//        guard let tweet = cell.tweet else { return }
//        let controller = UploadTweetViewController(user: tweet.user, config: .reply(tweet))
//        let nav = UINavigationController(rootViewController: controller)
//        nav.modalPresentationStyle = .fullScreen
//        present(nav, animated: true)
    }
}
