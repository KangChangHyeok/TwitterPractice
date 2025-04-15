//
//  ChattingRoomViewController.swift
//  TwitterPractice
//
//  Created by kangChangHyeok on 08/04/2025.
//

import UIKit
import SnapKit
import Firebase

final class ChattingRoomViewController: BaseViewController {
    
    private var chatRoom: ChatRoom
    
    private var dataSource: UICollectionViewDiffableDataSource<Int, Message>!
    
    private lazy var messageCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: messageCollectionViewLayout())
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private lazy var messageInputView = MessageInputView().configure {
        $0.messageSendButton.addTarget(self, action: #selector(messageSendButtonDidTap), for: .touchUpInside)
    }
    
    init(chatRoom: ChatRoom) {
        self.chatRoom = chatRoom
        super.init(nibName: nil, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupDefaults() {
        self.tabBarController?.tabBar.isHidden = true
        configureDataSource()
        fetchMessages()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )    }
    
    override func setupHierarchy() {
        view.addSubview(messageCollectionView)
        view.addSubview(messageInputView)
    }
    
    override func setupLayout() {
        messageCollectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.width.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(messageInputView.snp.top)
        }
        messageInputView.snp.makeConstraints { make in
            make.height.lessThanOrEqualTo(100)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.keyboardLayoutGuide.snp.top)
        }
    }
    
    private func messageCollectionViewLayout() -> UICollectionViewLayout {
        let layoutSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50)
        )
        let item = NSCollectionLayoutItem(layoutSize: layoutSize)
    
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: layoutSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 5
        section.contentInsets = .init(top: 5, leading: 15, bottom: 5, trailing: 15)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    private func configureDataSource() {
        let chatRoomCellRegisteration = UICollectionView.CellRegistration<MessageCell, Message> { cell, indexPath, item in
            cell.bind(item)
        }
        
        let dataSource = UICollectionViewDiffableDataSource<Int, Message>(collectionView: messageCollectionView) { collectionView, indexPath, message in
            return collectionView.dequeueConfiguredReusableCell(using: chatRoomCellRegisteration, for: indexPath, item: message)
        }
        self.dataSource = dataSource
    }
    
    private func fetchMessages() {
        Task {
            let messageIDs = chatRoom.messageIDs
            
            let messages: [Message]
            if messageIDs.isEmpty == false {
                messages = try await NetworkService.messages.whereField("id", in: messageIDs).getDocuments().documents
                    .map { try $0.data(as: Message.self) }
                    .sorted { $0.timeStamp < $1.timeStamp }
            } else {
                messages = []
            }
            
            var snapShot = NSDiffableDataSourceSnapshot<Int, Message>()
            snapShot.appendSections([0])
            snapShot.appendItems(messages)
            snapShot.reloadItems(messages)
            await dataSource.apply(snapShot)
            
        }
    }
    
    @objc func handleKeyboardWillShow(notification: Notification) {
        messageCollectionView.scrollToItem(
            at: IndexPath(item: dataSource.snapshot().itemIdentifiers.count - 1, section: 0),
            at: .bottom, animated: false
        )
    }
    
    @objc func messageSendButtonDidTap() {
        
        let loginUserID = UserDefaults.fecthUserID()!
        
        let message = Message(
            id: UUID().uuidString,
            senderID: loginUserID,
            content: messageInputView.textView.text,
            timeStamp: Date(),
            isRead: false
        )
        
        Task {
            do {
                // chatRoom에 message 반영
                try await NetworkService.chatRooms.document(chatRoom.id).updateData([
                    "messageIDs": FieldValue.arrayUnion([message.id]),
                    "lastMessageTime": Date(),
                    "lastMessage": message.content
                ]
                )
                
                let chatRoom = try await NetworkService.chatRooms.document(chatRoom.id).getDocument().data(as: ChatRoom.self)
                
                self.chatRoom = chatRoom
                // message 생성후 저장
                try NetworkService.messages.document(message.id).setData(from: message)
                messageInputView.reset()
                fetchMessages()
            } catch {
                print("에러: \(error)")
            }
        }
    }
}

extension ChattingRoomViewController: UICollectionViewDelegate {
    
}
