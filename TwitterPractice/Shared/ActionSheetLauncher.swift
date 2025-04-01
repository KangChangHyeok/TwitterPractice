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
    
    private let user: User
    private let tableView = UITableView()
    private var window: UIWindow?
    private lazy var viewModel = ActionSheetViewModel(user: user)
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
        cancelButton.anchor(left: view.leftAnchor, right: view.rightAnchor, paddingLeft: 12, paddingRight: 12)
        cancelButton.centerY(inView: view)
        cancelButton.layer.cornerRadius = 50 / 2
        return view
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .systemGray6
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
        guard let window = UIApplication.shared.windows.first(where: {$0.isKeyWindow}) else { return }
        self.window = window
        window.addSubview(blackView)
        blackView.frame = window.frame
        window.addSubview(tableView)
        let height = CGFloat(viewModel.options.count * 60) + 100
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

//MARK: - UITableViewDataSource

extension ActionSheetLauncher: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.options.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuserIdentifier, for: indexPath) as? ActionSheetCell
        cell?.option = viewModel.options[indexPath.row]
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
        let option = viewModel.options[indexPath.row]
        UIView.animate(withDuration: 0.5) {
            self.blackView.alpha = 0
            self.showTableView(false)
        } completion: { _ in
            self.delegate?.didSelect(option: option)
        }
    }
}
