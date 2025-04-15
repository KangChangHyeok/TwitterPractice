//
//  FeedController.swift
//  TwitterPractice
//
//  Created by 강창혁 on 2022/10/04.
//

import UIKit
import SwiftUI

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
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, TweetDTO>?
    
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
    
    override func setupDefaults() {
        self.view.backgroundColor = .white
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .white
        tabBarController?.navigationController?.navigationBar.standardAppearance = appearance
        let imageView = UIImageView(image: UIImage(named: "twitter_logo_blue"))
        imageView.contentMode = .scaleAspectFit
        imageView.setDimensions(width: 44, height: 44)
        self.navigationItem.titleView = imageView
        configureDataSource()
    }
    
    override func setupHierarchy() {
        view.addSubview(tweetCollectionView)
    }
    
    override func setupLayout() {
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
        let tweetCellRegisteration = UICollectionView.CellRegistration<TweetCell, TweetDTO> { cell, indexPath, tweet in
            cell.bind(tweet: tweet)
            cell.delegate = self
        }
        
        let dataSource = UICollectionViewDiffableDataSource<Section, TweetDTO>(collectionView: tweetCollectionView) { collectionView, indexPath, tweet in
            return collectionView.dequeueConfiguredReusableCell(using: tweetCellRegisteration, for: indexPath, item: tweet)
        }
        self.dataSource = dataSource
    }
    
    func requestUser() {
        Task {
            guard let userID = UserDefaults.fecthUserID() else { return }
            self.user = try await NetworkService.fetchUser(userID: userID)
        }
    }
    
    // MARK: - Selectors
    
    @objc func handleRefresh() {
        refreshControl.beginRefreshing()
        requestTweets()
        refreshControl.endRefreshing()
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
                let tweets = try await NetworkService.tweetCollection.getDocuments().documents
                    .map { try $0.data(as: TweetDTO.self) }
                    .filter({ $0.originalTweetID.isEmpty })
                    .sorted { $0.timeStamp > $1.timeStamp }
                var snapShot = NSDiffableDataSourceSnapshot<Section, TweetDTO>()
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
    
    private func fetchChatRooms() async throws -> [ChatRoom] {
        let userEmail = UserDefaults.fecthUserID() ?? ""
                
        return try await NetworkService.chatRooms.getDocuments().documents
                    .map { try $0.data(as: ChatRoom.self) }
                    .sorted { $0.createdAt > $1.createdAt }
                    .filter { $0.joinedUsers.contains { $0.email == userEmail} }
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
    
    func profileImageViewDidTap(_ cell: TweetCell) {
        // 내 트윗을 눌렀으면 내 유저 객체 보내주고 아니면 해당 트윗의 유저 정보 보내주기
        guard let indexPath = cell.indexPath else { return }
        let selectedTweetUser = dataSource?.snapshot().itemIdentifiers[indexPath.row].user
        let controller = ProfileViewController(user: selectedTweetUser)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func chatButtonDidTap(_ cell: TweetCell, receiverID: String) {
        // receiverid에 해당하는 유저의 채팅방이 있으면, 해당 채팅방으로 이동하고, 아니면 새로운 채팅방을 생성한다.
        Task {
            let userChatRooms = try await fetchChatRooms()
            guard let forRecevierChatRoom = userChatRooms.filter({ $0.joinedUsers.contains { $0.email == receiverID} }).first else {
                
                //해당 유저와의 채팅이 없으면 새로운 채팅방 생성후 채팅 시작하기
                let createdChatRoom = try await NetworkService.createChatRoom(for: receiverID)
                let chattingRoomViewController = ChattingRoomViewController(chatRoom: createdChatRoom)
                self.navigationController?.pushViewController(chattingRoomViewController, animated: true)
                return
            }
            // 있으면 기존의 채팅방으로 이동하기
            let chattingRoomViewController = ChattingRoomViewController(chatRoom: forRecevierChatRoom)
            self.navigationController?.pushViewController(chattingRoomViewController, animated: true)
        }
    }
    
    func replyButtonDidTap(_ cell: TweetCell) {
        guard let indexPath = cell.indexPath,
              let tweet = dataSource?.snapshot().itemIdentifiers[indexPath.row]  else { return }
        let uploadTweetViewController = UploadTweetViewController(config: .reply(tweet))
        let nav = UINavigationController(rootViewController: uploadTweetViewController)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
    
    func likeButtonDidTap(_ cell: TweetCell, likeCanceled: Bool) {
        guard let indexPath = cell.indexPath,
              let selectedTweet = dataSource?.snapshot().itemIdentifiers[indexPath.row] else { return }
        guard let user else { return }
        
        Task {
            if likeCanceled { //좋아요를 눌렀다면 해당 트윗의 likeUser에 현재 로그인한 유저의 이메일을 추가하고, likes + 1
                var likeUsers = selectedTweet.likeUsers
                likeUsers.append(user.email)
                let likes = selectedTweet.likes + 1
                
                try await NetworkService.tweetCollection.document(selectedTweet.id).updateData([
                    "likes": likes,
                    "likeUsers": likeUsers
                ])
                print("좋아요 누르기 완료")
            } else {
                let likes = selectedTweet.likes - 1
                var likeUsers = selectedTweet.likeUsers
                likeUsers.removeAll { $0 == user.email }
                
                try await NetworkService.tweetCollection.document(selectedTweet.id).updateData([
                    "likes": likes,
                    "likeUsers": likeUsers
                ])
                print("좋아요 취소 완료")
            }
            //좋아요를 취소했다면 해당 트윗의 likeUser에서 삭제하고 , likes - 1
            requestTweets()
        }
    }
    
    func shareButtonDidTap(_ cell: TweetCell, text: String?) {
        UIPasteboard.general.string = text
        
        let alertController = UIAlertController(title: "복사 완료", message: "클립보드에 트위터가 복사되었습니다.", preferredStyle: .alert)
        let checkAction = UIAlertAction(title: "확인", style: .default)
        alertController.addAction(checkAction)
        self.present(alertController, animated: true)
    }
}
