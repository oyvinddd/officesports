//
//  CircleView.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 11/05/2022.
//

import UIKit

private let contentWrapRadius: CGFloat = (100 - 6 * 2) / 2

final class CircleView: UIView {
    
    private lazy var contentWrap: UIView = {
        let view = UIView.createView(.red, cornerRadius: contentWrapRadius)
        view.applyGradient([UIColor.yellow, UIColor.red])
        return view
    }()
    
    private lazy var textLabel: UILabel = {
        let label = UILabel.createLabel(UIColor.OS.Text.normal, alignment: .center)
        label.font = UIFont.boldSystemFont(ofSize: 60)
        return label
    }()
    
    private lazy var imageView: UIImageView = {
        return UIImageView.createImageView(nil)
    }()
    
    init(_ backgroundColor: UIColor, _ borderColor: UIColor, text: String? = nil, image: UIImage? = nil) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = borderColor
        contentWrap.backgroundColor = backgroundColor
        setupChildViews(text, image)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupChildViews(_ text: String?, _ image: UIImage?) {
        NSLayoutConstraint.pinToView(self, contentWrap, padding: 6)
        if let text = text {
            textLabel.text = text
            NSLayoutConstraint.pinToView(contentWrap, textLabel)
        }
        if let image = image {
            imageView.image = image
            NSLayoutConstraint.pinToView(contentWrap, imageView)
        }
    }
}
