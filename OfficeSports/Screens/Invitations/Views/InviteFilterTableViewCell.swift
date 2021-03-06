//
//  InviteFilterTableViewCell.swift
//  OfficeSports
//
//  Created by Øyvind Hauge on 21/06/2022.
//

import UIKit

private let leftButtonTitle = "Received"
private let rightButtonTitle = "Sent"

protocol InviteFilterDelegate: AnyObject {
    
    func leftButtonTapped()
    
    func rightButtonTapped()
}

final class InviteFilterTableViewCell: UITableViewCell {
    
    private lazy var contentWrap: UIView = {
        return UIView.createView(.white, cornerRadius: 15)
    }()
    
    private lazy var leftButton: UIButton = {
        let title = leftButtonTitle.uppercased()
        let button = UIButton.createButton(.clear, UIColor.OS.Text.normal, title: title)
        button.addTarget(self, action: #selector(leftButtonTapped), for: .touchUpInside)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        return button
    }()
    
    private lazy var rightButton: UIButton = {
        let title = rightButtonTitle.uppercased()
        let button = UIButton.createButton(.clear, UIColor.OS.Text.disabled, title: title)
        button.addTarget(self, action: #selector(rightButtonTapped), for: .touchUpInside)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        return button
    }()
    
    private lazy var separatorView: UIView = {
        return UIView.createView(UIColor.OS.General.separator)
    }()
    
    private lazy var feedbackGenerator: UIImpactFeedbackGenerator = {
        return UIImpactFeedbackGenerator(style: .medium)
    }()
    
    weak var delegate: InviteFilterDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupChildViews()
        configureUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func toggleLeftButton(enabled: Bool) {
        if enabled {
            leftButton.setTitleColor(UIColor.OS.Text.normal, for: .normal)
            rightButton.setTitleColor(UIColor.OS.Text.disabled, for: .normal)
        } else {
            rightButton.setTitleColor(UIColor.OS.Text.normal, for: .normal)
            leftButton.setTitleColor(UIColor.OS.Text.disabled, for: .normal)
        }
    }
    
    private func setupChildViews() {
        contentView.addSubview(contentWrap)
        contentWrap.addSubview(leftButton)
        contentWrap.addSubview(rightButton)
        contentWrap.addSubview(separatorView)
        
        NSLayoutConstraint.activate([
            leftButton.leftAnchor.constraint(equalTo: contentWrap.leftAnchor),
            leftButton.topAnchor.constraint(equalTo: contentWrap.topAnchor),
            leftButton.bottomAnchor.constraint(equalTo: contentWrap.bottomAnchor),
            leftButton.rightAnchor.constraint(equalTo: rightButton.leftAnchor),
            leftButton.heightAnchor.constraint(equalToConstant: 40),
            rightButton.rightAnchor.constraint(equalTo: contentWrap.rightAnchor),
            rightButton.topAnchor.constraint(equalTo: contentWrap.topAnchor),
            rightButton.bottomAnchor.constraint(equalTo: contentWrap.bottomAnchor),
            rightButton.widthAnchor.constraint(equalTo: leftButton.widthAnchor),
            rightButton.heightAnchor.constraint(equalTo: leftButton.heightAnchor),
            contentWrap.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
            contentWrap.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16),
            contentWrap.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentWrap.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            separatorView.centerXAnchor.constraint(equalTo: contentWrap.centerXAnchor),
            separatorView.heightAnchor.constraint(equalTo: contentWrap.heightAnchor),
            separatorView.centerYAnchor.constraint(equalTo: contentWrap.centerYAnchor),
            separatorView.widthAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    private func configureUI() {
        backgroundColor = .clear
        selectionStyle = .none
    }
    
    @objc private func leftButtonTapped(_ sender: UIButton) {
        toggleLeftButton(enabled: true)
        feedbackGenerator.impactOccurred()
        delegate?.leftButtonTapped()
    }
    
    @objc private func rightButtonTapped(_ sender: UIButton) {
        toggleLeftButton(enabled: false)
        feedbackGenerator.impactOccurred()
        delegate?.rightButtonTapped()
    }
}
