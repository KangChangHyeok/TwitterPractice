//
//  ProfileController.swift
//  TwitterPractice
//
//  Created by 강창혁 on 2022/10/11.
//

import UIKit
import FirebaseAuth

private let headerIdentifier = "ProfileHeader"

final class ProfileViewController: BaseViewController {
    
    // MARK: - Properties
    
    private enum Section {
        case tweet
    }
    
    private var user: User?
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, TweetDTO>?
    
    private var tweets = [TweetDTO]()
    
    private var option: ProfileFilterOptions = .tweets
    
    private lazy var tweetCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .white
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.bounces = false
        return collectionView
    }()
    
    // MARK: - Initializer
    
    init(user: User?) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Set
    
    override func setupDefaults(at viewController: UIViewController) {
        configureDataSource()
        requestUserTweets()
    }
    
    override func setupHierarchy(at view: UIView) {
        view.addSubview(tweetCollectionView)
    }
    
    override func setupLayout(at view: UIView) {
        tweetCollectionView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    // MARK: - LifeCycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barStyle = .black
        navigationController?.setNavigationBarHidden(true, animated: true)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        let mainTab = tabBarController as? MainTabController
        mainTab?.setTweetButtonIsHidden(true)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
    
    func configureDataSource() {
        let profileHeaderRegisteration = UICollectionView.SupplementaryRegistration<ProfileHeaderView>(elementKind: "ProfileHeader") { [weak self] supplementaryView, elementKind, indexPath in
            supplementaryView.bind(user: self?.user)
            supplementaryView.delegate = self
        }
        
        let tweetCellRegisteration = UICollectionView.CellRegistration<TweetCell, TweetDTO> { [weak self]
            cell, indexPath, tweet in
            cell.bind(tweet: tweet)
            cell.delegate = self
        }
        
        self.dataSource = UICollectionViewDiffableDataSource<Section, TweetDTO>(collectionView: self.tweetCollectionView) { collectionView, indexPath, tweet in
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
            guard let userID = self.user?.email else { return }
            self.tweets = try await NetworkManager.tweetCollection.getDocuments().documents
                .map { try $0.data(as: TweetDTO.self) }
                .filter { $0.user.email == userID }
            
            var snapshot = NSDiffableDataSourceSnapshot<Section, TweetDTO>()
            snapshot.appendSections([.tweet])
            snapshot.appendItems(self.tweets)
            await dataSource?.apply(snapshot)
        }
    }
    
    func fetchUserRetweets() {
        Task {
            self.tweets = try await NetworkManager.tweetCollection.getDocuments().documents
                .map { try $0.data(as: TweetDTO.self) }
                .flatMap( { $0.retweets ?? [] })
                .filter({ $0.user.email == self.user?.email })
            
            var snapshot = NSDiffableDataSourceSnapshot<Section, TweetDTO>()
            snapshot.appendSections([.tweet])
            snapshot.appendItems(self.tweets)
            await dataSource?.apply(snapshot)
        }
    }
    
    func fetchUserLikedTweets() {
        guard let userID = self.user?.email else { return }
        Task {
            self.tweets = try await NetworkManager.tweetCollection.getDocuments().documents
                .map { try $0.data(as: TweetDTO.self) }
                .filter { $0.likeUsers.contains { $0 == userID } }
            
            var snapshot = NSDiffableDataSourceSnapshot<Section, TweetDTO>()
            snapshot.appendSections([.tweet])
            snapshot.appendItems(self.tweets)
            await dataSource?.apply(snapshot)
        }
        
    }
}

// MARK: - UICollectionViewDelegate

extension ProfileViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let controller = TweetController(tweet: currentDataSource[indexPath.row])
//        navigationController?.pushViewController(controller, animated: true)
    }
}

extension ProfileViewController: ProfileHeaderViewDelegate {
    
    func backButtonDidTap(_ button: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    func filterDidTap(_ filter: ProfileFilterOptions) {
        self.option = filter
        switch option {
        case .tweets:
            requestUserTweets()
        case .replies:
            fetchUserRetweets()
        case .likes:
            fetchUserLikedTweets()
        }
    }
    
    func profileEditButtonDidTap(_ button: UIButton, user: User?) {
        let navigationController = UINavigationController(rootViewController: ProfileEditController(user: user))
        navigationController.modalPresentationStyle = .overFullScreen
        self.present(navigationController, animated: true)
    }
    
    
    
    func handleEditProfileFollow(_ header: ProfileHeaderView) {
    }
    
}

// MARK: - TweetCellDelegate

extension ProfileViewController: TweetCellDelegate {
    
    func handleProfileImageTapped(_ cell: TweetCell) { return }
    
    func handleReplyTapped(_ cell: TweetCell) {
        
    }
    
    func handleLikeTapped(_ cell: TweetCell, likeCanceled: Bool) {
        guard let indexPath = cell.indexPath,
              let selectedTweet = dataSource?.snapshot().itemIdentifiers[indexPath.row] else { return }
        guard let user else { return }
        //좋아요를 눌렀다면 해당 트윗의 likeUser에 추가하고, likes + 1
        Task {
            if likeCanceled {
                let likes = selectedTweet.likes + 1
                var likeUsers = selectedTweet.likeUsers
                likeUsers.append(user.email)
                
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
                
                requestUserTweets()
            }
            //좋아요를 취소했다면 해당 트윗의 likeUser에서 삭제하고 , likes - 1
        }
    }
    
    func handleFetchUser(withUsername username: String) {
        
    }
}

extension ProfileViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
