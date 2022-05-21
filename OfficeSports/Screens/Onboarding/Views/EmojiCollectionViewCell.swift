//
//  EmojiCollectionViewCell.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 21/05/2022.
//

import UIKit

final class EmojiCollectionViewCell: UICollectionViewCell {
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel.createLabel(.black, alignment: .center)
        label.font = UIFont.systemFont(ofSize: 40)
        return label
    }()
    
    var emoji: String? {
        didSet {
            guard let emoji = emoji else {
                return
            }
            emojiLabel.text = emoji
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupChildViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupChildViews() {
        NSLayoutConstraint.pinToView(contentView, emojiLabel, padding: 4)
    }
}
