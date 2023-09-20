//
//  BaseViewController.swift
//  TwitterPractice
//
//  Created by 강창혁 on 2023/09/20.
//

import UIKit

protocol Base: AnyObject {
    associatedtype Controller
    func configure(controller: Controller)
    func configureUI()
}

class BaseViewController: UIViewController, Base {
    typealias Controller = UIViewController
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        view.backgroundColor = .systemBackground
        configure(controller: self)
        configureUI()
    }
    
    //MARK: - Initializer
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - 기본 설정
    
    func configure(controller: UIViewController) {
        
    }
    
    //MARK: - UI 설정
    
    func configureUI() {
        
    }
}

class BaseTabBarController: UITabBarController, Base {
    typealias Controller = UITabBarController
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        configure(controller: self)
        configureUI()
    }
    
    //MARK: - Initializer
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - 기본 설정
    
    func configure(controller: UITabBarController) {
        
    }
    
    //MARK: - UI 설정
    
    func configureUI() {
        
    }
}
