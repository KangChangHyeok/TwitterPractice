//
//  SearchController.swift
//  TwitterPractice
//
//  Created by 강창혁 on 2022/10/04.
//

import UIKit

import SnapKit

final class ExploreController: BaseViewController {
    
    private enum Section {
        case main
    }
    
    // MARK: - Properties
    
    private var inSearchMode: Bool {
        return searchController.isActive && !searchController.searchBar.text!.isEmpty
    }
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "찾고싶은 사람을 검색하세요"
        return searchController
    }()
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, User>?
    
    private var users: [User]?
    
    // MARK: - UI
    
    private lazy var userCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createUserCollectionViewLayout())
        return collectionView
    }()
    
    // MARK: - Set
    
    override func setupDefaults(at viewController: UIViewController) {
        viewController.view.backgroundColor = .white
        viewController.navigationItem.title = "Explore"
        navigationItem.searchController = searchController
        definesPresentationContext = false
        configureDataSource()
        fetchUsers()
    }
    
    override func setupHierarchy(at view: UIView) {
        view.addSubview(userCollectionView)
    }
    
    override func setupLayout(at view: UIView) {
        userCollectionView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    // MARK: - LifeCycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    func configureDataSource() {
        let userCellRegisteration = UICollectionView.CellRegistration<UserCell, User> { cell, indexPath, user in
            cell.bind(user: user)
        }
        
        self.dataSource = UICollectionViewDiffableDataSource<Section, User>(collectionView: userCollectionView) { collectionView, indexPath, user in
            collectionView.dequeueConfiguredReusableCell(using: userCellRegisteration, for: indexPath, item: user)
        }
    }
    
    func fetchUsers() {
        Task {
            do {
                let users = try await NetworkManager.userCollection.getDocuments().documents.map { try $0.data(as: User.self) }
                self.users = users
                var snapShot = NSDiffableDataSourceSnapshot<Section, User>()
                snapShot.appendSections([.main])
                snapShot.appendItems(users)
                await dataSource?.apply(snapShot)
            } catch {
                print(error)
            }
        }
    }
    
    func createUserCollectionViewLayout() -> UICollectionViewLayout {
        let estimatedHeight = CGFloat(100)
        let layoutSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(estimatedHeight)
        )
        let item = NSCollectionLayoutItem(layoutSize: layoutSize)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: layoutSize, repeatingSubitem: item, count: 1)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10
        section.contentInsets = .init(top: 15, leading: 0, bottom: 0, trailing: 0)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
}

// MARK: - UISearchResultsUpdating

extension ExploreController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
        guard searchController.searchBar.text != "",
              let searchText = searchController.searchBar.text?.lowercased() else {
            guard let users else { return }
            var snapShot = NSDiffableDataSourceSnapshot<Section, User>()
            snapShot.appendSections([.main])
            snapShot.appendItems(users)
            dataSource?.apply(snapShot)
            return
        }
        guard let users else { return }
        let filteredUsers = users.filter {
            print($0.userName.contains(searchText))
            return $0.userName.contains(searchText)
        }
        var snapShot = NSDiffableDataSourceSnapshot<Section, User>()
        snapShot.appendSections([.main])
        snapShot.appendItems(filteredUsers)
        dataSource?.apply(snapShot)
    }
}
