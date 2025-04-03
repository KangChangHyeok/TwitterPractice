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
    
    override func setupDefaults(at viewController: UIViewController) {
        configureDataSource()
        fetchRetweets()
    }
    
    override func setupHierarchy(at view: UIView) {
        view.addSubview(retweetsCollectionView)
    }
    
    override func setupLayout(at view: UIView) {
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
        let tweetCellRegisteration = UICollectionView.CellRegistration<TweetCell, TweetDTO> { cell, indexPath, retweet in
            cell.bind(retweet)
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
    func handleFetchUser(withUsername username: String) {
//        UserService.shared.fetchUser(WithUsername: username) { user in
//            let controller = ProfileController(user: user)
//            self.navigationController?.pushViewController(controller, animated: true)
//        }
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
