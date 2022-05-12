//
//  FloatingMenu.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 10/05/2022.
//

import UIKit

// MARK: - Floating Menu Delegate

protocol FloatingMenuDelegate: AnyObject {
    
    func settingsButtonTapped()
    
    func displayCodeButtonTapped()
    
    func registerMatchButtonTapped()
    
    func changeSportsButtonTapped()
}

final class FloatingMenu: UIView {
    
    private lazy var stackView: UIStackView = {
        return UIStackView.createStackView(.clear, axis: .horizontal, spacing: 4)
    }()
    
    private lazy var mbSettings: MenuButton = {
        let button = MenuButton(.white, image: nil)
        button.addTarget(self, action: #selector(settingsButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var mbChangeSports: MenuButton = {
        let button = MenuButton(.white, image: nil)
        button.addTarget(self, action: #selector(changeSportsButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var mbRegisterMatch: MenuButton = {
        let button = MenuButton(.white, image: nil)
        button.addTarget(self, action: #selector(registerMatchButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var mbShowQrCode: MenuButton = {
        let button = MenuButton(.white, image: nil)
        button.addTarget(self, action: #selector(displayCodeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private weak var delegate: FloatingMenuDelegate?
    
    init(delegate: FloatingMenuDelegate?) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        self.delegate = delegate
        backgroundColor = .blue
        applyCornerRadius(10)
        setupChildViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func toggle(turnOn: Bool, animated: Bool = true) {
    }
    
    private func setupChildViews() {
        NSLayoutConstraint.pinToView(self, stackView, padding: 4)
        
        stackView.addArrangedSubview(mbSettings)
        stackView.addArrangedSubview(mbRegisterMatch)
        stackView.addArrangedSubview(mbShowQrCode)
        stackView.addArrangedSubview(mbChangeSports)
    }
    
    // MARK: - Button Handling
    
    @objc private func settingsButtonTapped(_ sender: MenuButton) {
        delegate?.settingsButtonTapped()
    }
    
    @objc private func changeSportsButtonTapped(_ sender: MenuButton) {
        delegate?.changeSportsButtonTapped()
    }
    
    @objc private func registerMatchButtonTapped(_ sender: MenuButton) {
        delegate?.registerMatchButtonTapped()
    }
    
    @objc private func displayCodeButtonTapped(_ sender: MenuButton) {
        delegate?.displayCodeButtonTapped()
    }
}

// MARK: - Menu Button

private final class MenuButton: UIButton {
    
    init(_ backgroundColor: UIColor? = nil, image: UIImage? = nil) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = backgroundColor
        applyCornerRadius(5)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
