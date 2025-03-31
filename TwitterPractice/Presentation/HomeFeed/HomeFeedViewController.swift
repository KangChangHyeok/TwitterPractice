//
//  FeedController.swift
//  TwitterPractice
//
//  Created by 강창혁 on 2022/10/04.
//

import UIKit
import SwiftUI
import SDWebImage

final class HomeFeedViewController: BaseViewController {
    
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
    
    override func setupDefaults(at viewController: UIViewController) {
        viewController.view.backgroundColor = .white
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .white
        tabBarController?.navigationController?.navigationBar.standardAppearance = appearance
        let imageView = UIImageView(image: UIImage(named: "twitter_logo_blue"))
        imageView.contentMode = .scaleAspectFit
        imageView.setDimensions(width: 44, height: 44)
        viewController.navigationItem.titleView = imageView
        configureDataSource()
    }
    
    override func setupHierarchy(at view: UIView) {
        view.addSubview(tweetCollectionView)
    }
    
    override func setupLayout(at view: UIView) {
        tweetCollectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // MARK: - LifeCycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestUser()
        requestTweets()
        navigationController?.setNavigationBarHidden(false, animated: true)
        let mainTab = tabBarController as? MainTabController
        mainTab?.setTweetButtonIsHidden(false)
        tabBarController?.tabBar.isHidden = false
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
            print(self.user)
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
        let controller = ProfileViewController(user: self.user)
        tabBarController?.tabBar.isHidden = true
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
                
                print(tweets)
                print("트윗 새로 가져오기 완료")
            } catch {
                print("error", error)
            }
        }
    }
}

// MARK: - UICollectionViewDelegate/DataSource

extension HomeFeedViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let tweet = dataSource?.snapshot().itemIdentifiers[indexPath.row] else { return }
        let controller = TweetController(tweet: tweet)
        navigationController?.pushViewController(controller, animated: true)
    }
}

// MARK: - TweetCellDelegate

extension HomeFeedViewController: TweetCellDelegate {
    
    func handleLikeTapped(_ cell: TweetCell, likeCanceled: Bool) {
        guard let indexPath = cell.indexPath,
              let selectedTweet = dataSource?.snapshot().itemIdentifiers[indexPath.row] else { return }
        guard let user else { return }
        
        Task {
            if likeCanceled { //좋아요를 눌렀다면 해당 트윗의 likeUser에 현재 로그인한 유저의 이메일을 추가하고, likes + 1
                var likeUsers = selectedTweet.likeUsers
                likeUsers.append(user.email)
                let likes = selectedTweet.likes + 1
                
                try await NetworkManager.tweetCollection.document(selectedTweet.id).updateData([
                    "likes": likes,
                    "likeUsers": likeUsers
                ])
                print("좋아요 누르기 완료")
            } else {
                let likes = selectedTweet.likes - 1
                var likeUsers = selectedTweet.likeUsers
                likeUsers.removeAll { $0 == user.email }
                
                try await NetworkManager.tweetCollection.document(selectedTweet.id).updateData([
                    "likes": likes,
                    "likeUsers": likeUsers
                ])
                print("좋아요 취소 완료")
            }
            //좋아요를 취소했다면 해당 트윗의 likeUser에서 삭제하고 , likes - 1
            requestTweets()
        }
    }
    func handleProfileImageTapped(_ cell: TweetCell) {
        // 내 트윗을 눌렀으면 내 유저 객체 보내주고 아니면 해당 트윗의 유저 정보 보내주기
        guard let indexPath = cell.indexPath else { return }
        let selectedTweetUser = dataSource?.snapshot().itemIdentifiers[indexPath.row].user
        let controller = ProfileViewController(user: selectedTweetUser)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func handleReplyTapped(_ cell: TweetCell) {
        guard let indexPath = cell.indexPath,
              let tweet = dataSource?.snapshot().itemIdentifiers[indexPath.row]  else { return }
        let uploadTweetViewController = UploadTweetViewController(config: .reply(tweet))
        let nav = UINavigationController(rootViewController: uploadTweetViewController)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
}
