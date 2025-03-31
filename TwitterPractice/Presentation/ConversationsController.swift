//
//  ConversationsController.swift
//  TwitterPractice
//
//  Created by 강창혁 on 2022/10/04.
//

import UIKit

class ConversationsController: UIViewController {
    // MARK: - Properties
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    // MARK: - Helpers
    func configureUI() {
        view.backgroundColor = .white
        navigationItem.title = "Messages"
    }
}
