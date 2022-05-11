//
//  UIKit+Factory.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 10/05/2022.
//

import UIKit

extension UIView {
    
    class func createView(_ backgroundColor: UIColor) -> UIView {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = backgroundColor
        return view
    }
}

extension UIScrollView {
    
    class func createScrollView(_ backgroundColor: UIColor) -> UIScrollView {
        let scrollView = UIScrollView(frame: .zero)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = backgroundColor
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        scrollView.bounces = true
        return scrollView
    }
}

extension UITableView {
    
    class func createTableView(_ backgroundColor: UIColor) -> UITableView {
        let tableView = UITableView(frame: .zero)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.backgroundColor = backgroundColor
        tableView.separatorStyle = .none
        return tableView
    }
}

extension UIStackView {
    
    class func createStackView(_ backgroundColor: UIColor, axis: NSLayoutConstraint.Axis) -> UIStackView {
        let stackView = UIStackView(frame: .zero)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillProportionally
        stackView.backgroundColor = backgroundColor
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
    
    class func createButton(_ backgroundColor: UIColor, _ color: UIColor, title: String) -> UIButton {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(color, for: .normal)
        button.backgroundColor = backgroundColor
        button.setTitle(title, for: .normal)
        button.applyCornerRadius(8)
        return button
    }
}

extension UIImageView {
    
    class func createImageView(_ image: UIImage?) -> UIImageView {
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
}
