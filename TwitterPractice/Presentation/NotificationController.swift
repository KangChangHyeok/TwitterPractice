//
//  NotificationController.swift
//  TwitterPractice
//
//  Created by 강창혁 on 2022/10/04.
//

import UIKit

private let reuseIdentifier = "NotificationCell"

class NotificationController: UITableViewController {
    // MARK: - Properties
    private var notifications = [NotificationDTO]() {
        didSet { tableView.reloadData() }
    }
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchNotifications()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.barStyle = .default
    }
    // MARK: - Selectors

    @objc func handleRefresh() {
        fetchNotifications()
    }
    
    func fetchNotifications() {
        Task {
            let loginUserID = UserDefaults.fecthUserID() ?? ""
            self.notifications = try await NetworkService.notifications.getDocuments().documents
                .map({ try $0.data(as: NotificationDTO.self) })
                .filter { $0.user.email == loginUserID }
        }
    }
    
    // MARK: - Helpers
    func configureUI() {
        view.backgroundColor = .white
        navigationItem.title = "Notifications"
        tableView.register(NotificationCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 60
        tableView.separatorStyle = .none
        
        tableView.refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
    }
}
extension NotificationController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? NotificationCell
        guard let cell = cell else {return UITableViewCell() }
        cell.bind(notifications[indexPath.row])
        cell.delegate = self
        return cell
    }
}
extension NotificationController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notification = notifications[indexPath.row]
//        guard let tweetID = notification.tweetID else { return }
    }
}
// MARK: - NotificationCellDelegate

extension NotificationController: NotificationCellDelegate {
    func didTapFollow(_ cell: NotificationCell) {

    }
    
    func didTapProfileImage(_ cell: NotificationCell) {
//        guard let user = cell.notification?.user else { return }
    }
}
