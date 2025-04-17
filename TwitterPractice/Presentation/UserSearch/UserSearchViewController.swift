//
//  UserSearchViewController.swift
//  TwitterPractice
//
//  Created by 강창혁 on 2022/10/04.
//

import UIKit

import SnapKit

final class UserSearchViewController: BaseViewController {
    
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
    
    private lazy var userCollectionView = UICollectionView(frame: .zero, collectionViewLayout: createUserCollectionViewLayout()).configure {
        $0.delegate = self
    }
    
    // MARK: - Set
    
    override func setupDefaults() {
        self.view.backgroundColor = .white
        self.navigationItem.title = "Explore"
        self.navigationItem.searchController = searchController
        self.definesPresentationContext = false
        configureDataSource()
        fetchUsers()
    }
    
    override func setupHierarchy() {
        view.addSubview(userCollectionView)
    }
    
    override func setupLayout() {
        userCollectionView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    // MARK: - LifeCycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        tabBarController?.tabBar.isHidden = false
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
                let users = try await NetworkService.userCollection.getDocuments().documents.map { try $0.data(as: User.self) }
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

extension UserSearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
        guard searchController.searchBar.text?.isEmpty == false,
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

extension UserSearchViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let user = users?[indexPath.row]
        let controller = ProfileViewController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
}
