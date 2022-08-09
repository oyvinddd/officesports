//
//  UIKit+Factory.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 10/05/2022.
//

import UIKit

extension UIView {
    
    class func createView(_ backgroundColor: UIColor, cornerRadius: CGFloat = 0) -> UIView {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = backgroundColor
        if cornerRadius > 0 {
            view.layer.masksToBounds = true
            view.layer.cornerRadius = cornerRadius
        }
        return view
    }
}

extension UIScrollView {
    
    class func createScrollView(_ backgroundColor: UIColor, delegate: UIScrollViewDelegate?) -> UIScrollView {
        let scrollView = UIScrollView(frame: .zero)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.delegate = delegate
        scrollView.backgroundColor = backgroundColor
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        scrollView.bounces = false
        return scrollView
    }
}

extension UITableView {
    
    class func createTableView(_ backgroundColor: UIColor, dataSource: UITableViewDataSource? = nil) -> UITableView {
        let tableView = UITableView(frame: .zero)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        tableView.backgroundColor = backgroundColor
        tableView.separatorStyle = .none
        tableView.dataSource = dataSource
        return tableView
    }
}

extension UIStackView {
    
    class func createStackView(_ backgroundColor: UIColor, axis: NSLayoutConstraint.Axis, spacing: CGFloat = 0) -> UIStackView {
        let stackView = UIStackView(frame: .zero)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        stackView.backgroundColor = backgroundColor
        stackView.spacing = spacing
        stackView.axis = axis
        return stackView
    }
}

extension UILabel {
    
    class func createLabel(_ color: UIColor, alignment: NSTextAlignment = .left, text: String? = nil) -> UILabel {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = alignment
        label.textColor = color
        label.text = text
        label.numberOfLines = 0
        return label
    }
}

extension UIButton {
    
    class func createButton(_ backgroundColor: UIColor, _ color: UIColor, _ selectedColor: UIColor? = nil, title: String? = nil) -> UIButton {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        button.setTitleColor(color, for: .normal)
        button.setTitleColor(selectedColor, for: .selected)
        button.setTitleColor(selectedColor, for: .highlighted)
        button.setTitleColor(selectedColor, for: .focused)
        button.backgroundColor = backgroundColor
        button.setTitle(title, for: .normal)
        button.applyCornerRadius(8)
        return button
    }
    
    class func createButton(_ backgroundColor: UIColor, tintColor: UIColor, image: UIImage?) -> UIButton {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(image, for: .normal)
        button.backgroundColor = backgroundColor
        button.tintColor = tintColor
        return button
    }
}

extension UIImageView {
    
    class func createImageView(_ image: UIImage?, alpha: Float = 1) -> UIImageView {
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.alpha = CGFloat(alpha)
        return imageView
    }
}

extension UITextField {
    
    class func createTextField(_ backgroundColor: UIColor, color: UIColor, placeholder: String? = nil) -> UITextField {
        let textField = UITextField(frame: .zero)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = backgroundColor
        textField.placeholder = placeholder
        textField.textColor = color
        return textField
    }
}

extension UICollectionView {
    
    class func createCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }
}
