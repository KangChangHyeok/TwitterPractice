//
//  TweetController.swift
//  TwitterPractice
//
//  Created by 강창혁 on 2022/10/19.
//

import UIKit
import SwiftUI

private let reuseIdentifier = "TweetCell"
private let headerIdentifier = "TweetHeader"

final class TweetController: BaseViewController {

    // MARK: - Properties
    
    private let tweet: TweetDTO
    private var actionSheetLauncher: ActionSheetLauncher!
    private var dataSource: UICollectionViewDiffableDataSource<Int, TweetDTO>?
    // MARK: - UI
    
    private lazy var retweetsCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: repliesCollectionViewLayout())
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        return collectionView
    }()
    
    // MARK: - Initializer
    
    init(tweet: TweetDTO) {
        self.tweet = tweet
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    override func setupDefaults() {
        configureDataSource()
        fetchRetweets()
    }
    
    override func setupHierarchy() {
        view.addSubview(retweetsCollectionView)
    }
    
    override func setupLayout() {
        retweetsCollectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        tabBarController?.tabBar.isHidden = true
    }
    
    func configureDataSource() {
        let tweetCellRegisteration = UICollectionView.CellRegistration<TweetCell, TweetDTO> { [weak self] cell, indexPath, retweet in
            cell.bind(retweet)
            cell.delegate = self
        }
        
        let headerRegisteration = UICollectionView.SupplementaryRegistration<TweetHeader>(elementKind: "TweetHeader") { [weak self] header, elementKind, indexPath in
            header.bind(self?.tweet)
            header.delegate = self
        }
        
        dataSource = UICollectionViewDiffableDataSource<Int, TweetDTO>(
            collectionView: retweetsCollectionView) { collectionView, indexPath, retweet in
                return collectionView.dequeueConfiguredReusableCell(using: tweetCellRegisteration, for: indexPath, item: retweet)
        }
        
        dataSource?.supplementaryViewProvider = { view, kind, indexPath in
            return view.dequeueConfiguredReusableSupplementary(using: headerRegisteration, for: indexPath)
        }
    }
    
    func fetchRetweets() {
        Task {
            let retweets = try await NetworkService.fetchRetweets(retweetIDs: tweet.retweetIDs)
            applySnapShot(retweets: retweets)
        }
    }
    
    func applySnapShot(retweets: [TweetDTO]) {
        var snapShot = NSDiffableDataSourceSnapshot<Int, TweetDTO>()
        snapShot.appendSections([0])
        snapShot.appendItems(retweets)
        dataSource?.apply(snapShot)
    }
    
    func repliesCollectionViewLayout() -> UICollectionViewLayout {
        let estimatedHeight = CGFloat(100)
        let layoutSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(estimatedHeight)
        )
        let item = NSCollectionLayoutItem(layoutSize: layoutSize)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: layoutSize, repeatingSubitem: item, count: 1)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10
        
        let sectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: sectionHeaderSize, elementKind: "TweetHeader", alignment: .top)
        
        section.boundarySupplementaryItems = [sectionHeader]
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    fileprivate func presentActionSheet(foruser user: User) {
        actionSheetLauncher = ActionSheetLauncher(user: user)
        self.actionSheetLauncher.delegate = self
        self.actionSheetLauncher.present()
    }
    
    private func fetchChatRooms() async throws -> [ChatRoom] {
        let userEmail = UserDefaults.fecthUserID() ?? ""
        
        return try await NetworkService.chatRooms.getDocuments().documents
            .map { try $0.data(as: ChatRoom.self) }
            .sorted { $0.createdAt > $1.createdAt }
            .filter { $0.joinedUsers.contains { $0.email == userEmail} }
    }
    
    func requestTweets() {
        Task {
            do {
                let tweets = try await NetworkService.tweetCollection.getDocuments().documents
                    .map { try $0.data(as: TweetDTO.self) }
                    .filter({ $0.originalTweetID.isEmpty })
                    .sorted { $0.timeStamp > $1.timeStamp }
                var snapShot = NSDiffableDataSourceSnapshot<Int, TweetDTO>()
                snapShot.appendSections([0])
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


// MARK: - UICollectionViewDelegateFlowLayout

extension TweetController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        return CGSize(width: view.frame.width, height: 260)
    }
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: view.frame.width, height: 120)
    }
}
// MARK: - TweetHeaderDelegate

extension TweetController: TweetHeaderDelegate {
    func chatButtonDidTap(receiverID: String) {
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
    
    func retweetButtonDidTap(tweet: TweetDTO?) {
        guard let tweet else { return }
        let uploadTweetViewController = UploadTweetViewController(config: .reply(tweet))
        let nav = UINavigationController(rootViewController: uploadTweetViewController)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
    
    func likeButtonDidTap(tweet: TweetDTO?, likeCanceled: Bool) {
        guard let selectedTweet = tweet else { return }
        guard let userEmail = UserDefaults.fecthUserID() else { return }
        
        Task {
            
            let user = try await NetworkService.fetchUser(userID: userEmail)
            
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
    
    func shareButtonDidTap() {
        
    }
    
    func handleFetchUser(withUsername username: String) {
    }
    
    func optionButtonDidTap(_ sender: UIButton) {
        presentActionSheet(foruser: tweet.user)
    }
}

// MARK: - ActionSheetLauncherDelegate

extension TweetController: ActionSheetLaunCherDelegate {
    func didSelect(option: ActionSheetOptions) {
        switch option {
        case .follow(let user):
            break
        case .unfollow(let user):
            break
        case .report:
            print("Report tweet..")
        case .delete:
            Task {
                do {
                    try await NetworkService.tweetCollection.document(tweet.id).delete()
                    self.navigationController?.popViewController(animated: true)
                } catch {
                    print(error)
                }
            }
        case .blockUser:
            print("Block User..")
        }
    }
}

extension TweetController: TweetCellDelegate {
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
    
    func likeButtonDidTap(_ cell: TweetCell, likeCanceled: Bool) {
        guard let indexPath = cell.indexPath,
              let selectedTweet = dataSource?.snapshot().itemIdentifiers[indexPath.row] else { return }
        guard let userEmail = UserDefaults.fecthUserID() else { return }
        
        Task {
            
            let user = try await NetworkService.fetchUser(userID: userEmail)
            
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
    func profileImageViewDidTap(_ cell: TweetCell) {
        // 내 트윗을 눌렀으면 내 유저 객체 보내주고 아니면 해당 트윗의 유저 정보 보내주기
        guard let indexPath = cell.indexPath else { return }
        let selectedTweetUser = dataSource?.snapshot().itemIdentifiers[indexPath.row].user
        let controller = ProfileViewController(user: selectedTweetUser)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func replyButtonDidTap(_ cell: TweetCell) {
        guard let indexPath = cell.indexPath,
              let tweet = dataSource?.snapshot().itemIdentifiers[indexPath.row]  else { return }
        let uploadTweetViewController = UploadTweetViewController(config: .reply(tweet))
        let nav = UINavigationController(rootViewController: uploadTweetViewController)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
    
    
}
