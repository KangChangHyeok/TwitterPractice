//
//  ConversationsController.swift
//  TwitterPractice
//
//  Created by 강창혁 on 2022/10/04.
//

import UIKit

final class ChattingsViewController: UIViewController {
    
    // MARK: - Properties
    
    private var dataSource: UICollectionViewDiffableDataSource<Int, ChatRoom>!
    
    private lazy var chattingCollectionView: UICollectionView = {
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
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureDataSource()
        fetchChatRooms()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        view.backgroundColor = .white
        navigationItem.title = "Messages"
        
        view.addSubview(chattingCollectionView)
        chattingCollectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide.snp.edges)
        }
    }
    
    private func createTweetCollectionViewLayout() -> UICollectionViewLayout {
        let layoutSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(80)
        )
        let item = NSCollectionLayoutItem(layoutSize: layoutSize)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: layoutSize, repeatingSubitem: item, count: 1)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    func configureDataSource() {
        let chatRoomCellRegisteration = UICollectionView.CellRegistration<ChatRoomCell, ChatRoom> { cell, indexPath, item in
            cell.bind(item)
        }
        
        let dataSource = UICollectionViewDiffableDataSource<Int, ChatRoom>(collectionView: chattingCollectionView) { collectionView, indexPath, tweet in
            return collectionView.dequeueConfiguredReusableCell(using: chatRoomCellRegisteration, for: indexPath, item: tweet)
        }
        self.dataSource = dataSource
    }
    
    @objc private  func handleRefresh() {
        refreshControl.beginRefreshing()
        fetchChatRooms()
        refreshControl.endRefreshing()
    }
    
    private func fetchChatRooms() {
        Task {
            do {
                let chatRooms = try await NetworkService.chatRooms.getDocuments().documents
                    .map { try $0.data(as: ChatRoom.self) }
                    .sorted { $0.createdAt > $1.createdAt }
                var snapShot = NSDiffableDataSourceSnapshot<Int, ChatRoom>()
                snapShot.appendSections([0])
                snapShot.appendItems(chatRooms)
                await dataSource?.apply(snapShot, animatingDifferences: true)
                
            } catch {
                print("에러", error)
            }
        }
    }
}

extension ChattingsViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedChatRoom = self.dataSource.snapshot().itemIdentifiers[indexPath.row]
        
        self.navigationController?.pushViewController(ChattingRoomViewController(chatRoom: selectedChatRoom), animated: true)
    }
}
