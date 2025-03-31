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
    
    private let tweet: Tweet
    private var actionSheetLauncher: ActionSheetLauncher!
    private var dataSource: UICollectionViewDiffableDataSource<Int, Retweet>?
    // MARK: - UI
    
    private lazy var retweetsCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: repliesCollectionViewLayout())
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    // MARK: - Initializer
    
    init(tweet: Tweet) {
        self.tweet = tweet
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Set
    
    override func setupDefaults(at viewController: UIViewController) {
        configureDataSource()
        applySnapShot()
    }
    
    override func setupHierarchy(at view: UIView) {
        view.addSubview(retweetsCollectionView)
    }
    
    override func setupLayout(at view: UIView) {
        retweetsCollectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.barStyle = .default
    }
    
    // MARK: - Helpers
    
    func configureDataSource() {
        let tweetCellRegisteration = UICollectionView.CellRegistration<TweetCell, Retweet> { cell, indexPath, retweet in
            cell.bind(retweet)
        }
        
        let headerRegisteration = UICollectionView.SupplementaryRegistration<TweetHeader>(elementKind: "TweetHeader") { [weak self] header, elementKind, indexPath in
            header.bind(self?.tweet)
            header.delegate = self
        }
        
        dataSource = UICollectionViewDiffableDataSource<Int, Retweet>(
            collectionView: retweetsCollectionView) { collectionView, indexPath, retweet in
                return collectionView.dequeueConfiguredReusableCell(using: tweetCellRegisteration, for: indexPath, item: retweet)
        }
        
        dataSource?.supplementaryViewProvider = { view, kind, indexPath in
            return view.dequeueConfiguredReusableSupplementary(using: headerRegisteration, for: indexPath)
        }
    }
    
    func applySnapShot() {
        var snapShot = NSDiffableDataSourceSnapshot<Int, Retweet>()
        snapShot.appendSections([0])
        snapShot.appendItems(tweet.retweets)
        Task {
            await dataSource?.apply(snapShot)
        }
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
    
    fileprivate func showActionSheet(foruser user: User) {
        actionSheetLauncher = ActionSheetLauncher(user: user)
        self.actionSheetLauncher.delegate = self
        self.actionSheetLauncher.show()
    }
}

// MARK: - UICollectionViewDataSource

//extension TweetController {
//    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return replies.count
//    }
//    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? TweetCell
//        guard let cell = cell else { return UICollectionViewCell() }
////        cell.tweet = replies[indexPath.row]
//        return cell
//    }
//}

// MARK: - UICollectionViewDelegate

//extension TweetController {
//    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as? TweetHeader else { return UICollectionReusableView() }
//        header.bind(tweet)
//        header.delegate = self
//        return header
//    }
//}

// MARK: - UICollectionViewDelegateFlowLayout

extension TweetController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//        let viewModel = TweetViewModel(tweet: tweet)
//        let captionHeight = viewModel.size(forwidth: view.frame.width).height
        return CGSize(width: view.frame.width, height: 260)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 120)
    }
}
// MARK: - TweetHeaderDelegate

extension TweetController: TweetHeaderDelegate {
    func handleFetchUser(withUsername username: String) {
//        UserService.shared.fetchUser(WithUsername: username) { user in
//            let controller = ProfileController(user: user)
//            self.navigationController?.pushViewController(controller, animated: true)
//        }
    }
    
    func showActionSheet() {
        showActionSheet(foruser: tweet.user)
//        if tweet.user.isCurrentUser {
//            showActionSheet(foruser: tweet.user)
//        } else {
//            UserService.shared.checkIfUserIsFollowed(uid: tweet.user.uid) { isFollowed in
//                var user = self.tweet.user
//                user.isFollowed = isFollowed
//                self.showActionSheet(foruser: user)
//            }
//        }
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
            print("Delete tweet..")
        case .blockUser:
            print("Block User..")
        }
    }
}
