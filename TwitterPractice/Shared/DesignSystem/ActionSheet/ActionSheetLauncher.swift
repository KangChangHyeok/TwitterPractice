//
//  ActionSheetLauncher.swift
//  TwitterPractice
//
//  Created by 강창혁 on 2022/10/23.
//

import UIKit

private let reuserIdentifier = "ActionSheetCell"

protocol ActionSheetLaunCherDelegate: AnyObject {
    func didSelect(option: ActionSheetOptions)
}

final class ActionSheetLauncher: NSObject {
    
    // MARK: - Properties
    
    var options: [ActionSheetOptions] {
        var results = [ActionSheetOptions]()
        
        guard let userID = UserDefaults.fecthUserID() else { return [.blockUser] }
        if user.email == userID {
            results.append(.delete)
        }
        results.append(.report)
    return results
    }
    
    private let user: User
    private let tableView = UITableView()
    private var window: UIWindow?
    weak var delegate: ActionSheetLaunCherDelegate?
    private var tableViewHeight: CGFloat?
    
    private lazy var blackView: UIView = {
        let view = UIView()
        view.alpha = 0
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleDismissal))
        view.addGestureRecognizer(tap)
        return view
    }()
    
    private lazy var footerView: UIView = {
        let view = UIView()
        view.addSubview(cancelButton)
        cancelButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12).isActive = true
        cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12).isActive = true
        cancelButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        cancelButton.layer.cornerRadius = 50 / 2
        return view
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .systemGray6
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleDismissal), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    
    init(user: User) {
        self.user = user
        super.init()
        configureTableView()
    }
    
    // MARK: - Selectors
    @objc func handleDismissal() {
        UIView.animate(withDuration: 0.5) {
            self.blackView.alpha = 0
            self.tableView.frame.origin.y += 300
        }
    }
    // MARK: - Helpers
    func showTableView(_ shouldShow: Bool) {
        guard let window = window else { return }
        guard let height = tableViewHeight else { return }
        let xxy = shouldShow ? window.frame.height - height : window.frame.height
        tableView.frame.origin.y = xxy
    }
    func present() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        
        self.window = window
        window.addSubview(blackView)
        blackView.frame = window.frame
        window.addSubview(tableView)
        let height = CGFloat(options.count * 60) + 100
        self.tableViewHeight = height
        tableView.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: height)
        UIView.animate(withDuration: 0.5) {
            self.blackView.alpha = 1
            self.showTableView(true)
        }
    }
    func configureTableView() {
        tableView.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 60
        tableView.separatorStyle = .none
        tableView.layer.cornerRadius = 5
        tableView.isScrollEnabled = false
        tableView.register(ActionSheetCell.self, forCellReuseIdentifier: reuserIdentifier)
    }
}

// MARK: - UITableViewDataSource

extension ActionSheetLauncher: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuserIdentifier, for: indexPath) as? ActionSheetCell
        cell?.option = options[indexPath.row]
        guard let cell = cell else { return UITableViewCell() }
        return cell
    }
}
// MARK: - TableViewDelegate

extension ActionSheetLauncher: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        footerView
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let option = options[indexPath.row]
        UIView.animate(withDuration: 0.5) {
            self.blackView.alpha = 0
            self.showTableView(false)
        } completion: { _ in
            self.delegate?.didSelect(option: option)
        }
    }
}
