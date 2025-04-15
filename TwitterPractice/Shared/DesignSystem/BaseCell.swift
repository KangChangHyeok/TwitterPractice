//
//  BaseCell.swift
//  TwitterPractice
//
//  Created by KangChangHyeok on 8/4/24.
//

import UIKit

open class BaseCVCell: UICollectionViewCell {
    
    //MARK: - Initailizer
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setDefaults(at: self.contentView)
        setHierarchy(at: self.contentView)
        setLayout(at: self.contentView)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func setDefaults(at view: UIView) {}
    
    open func setHierarchy(at view: UIView) {}
    
    open func setLayout(at view: UIView) {}
}

public extension BaseCVCell {
    
    var indexPath: IndexPath? {
        guard let collectionView = superview as? UICollectionView else {
            return nil
        }
        let indexPath = collectionView.indexPath(for: self)
        return indexPath
    }
}

open class BaseTVCell: UITableViewCell {
    
    //MARK: - Initailizer
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setDefaults(at: self.contentView)
        setHierarchy(at: self.contentView)
        setLayout(at: self.contentView)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func setDefaults(at view: UIView) {}
    
    open func setHierarchy(at view: UIView) {}
    
    open func setLayout(at view: UIView) {}
}

public extension BaseTVCell {
    
    var indexPath: IndexPath? {
        guard let tableView = superview as? UITableView else {
            return nil
        }
        let indexPath = tableView.indexPath(for: self)
        return indexPath
    }
}
