//
//  FloatingMenu.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 10/05/2022.
//

import UIKit
import AudioToolbox

// MARK: - Floating Menu Delegate

protocol FloatingMenuDelegate: AnyObject {
    
    func displayCodeButtonTapped()
    
    func toggleCameraButtonTapped()
    
    func foosballButtonTapped()
    
    func tableTennisButtonTapped()
}

final class FloatingMenu: UIView {
    
    private lazy var stackView: UIStackView = {
        return UIStackView.createStackView(.clear, axis: .horizontal, spacing: 4)
    }()
    
    private lazy var mbFoosballButton: MenuButton = {
        let image = UIImage(named: "Soccer")!.withRenderingMode(.alwaysTemplate)
        let button = MenuButton(.clear, image: image)
        button.addTarget(self, action: #selector(foosballButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var mbTableTennisButton: MenuButton = {
        let image = UIImage(named: "TableTennis")!.withRenderingMode(.alwaysTemplate)
        let button = MenuButton(.clear, image: image)
        button.addTarget(self, action: #selector(tableTennisButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var mbToggleCamera: MenuButton = {
        let button = MenuButton(.clear, image: UIImage(systemName: "qrcode.viewfinder", withConfiguration: buttonImageConfig))
        button.addTarget(self, action: #selector(toggleCameraButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var mbShowQrCode: MenuButton = {
        let button = MenuButton(.clear, image: UIImage(systemName: "qrcode", withConfiguration: buttonImageConfig))
        button.addTarget(self, action: #selector(displayCodeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var buttonImageConfig: UIImage.Configuration = {
        return UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold, scale: .large)
    }()
    
    private lazy var feedbackGenerator: UIImpactFeedbackGenerator = {
        return UIImpactFeedbackGenerator(style: .medium)
    }()
    
    private weak var delegate: FloatingMenuDelegate?
    
    init(delegate: FloatingMenuDelegate?) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        self.delegate = delegate
        setupChildViews()
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func toggleCameraMode(enabled: Bool, animated: Bool = true) {
        let icon = enabled ? "xmark" : "qrcode.viewfinder"
        let image = UIImage(systemName: icon, withConfiguration: buttonImageConfig)
        mbToggleCamera.setImage(image, for: .normal)
        mbFoosballButton.toggle(enabled: !enabled)
        mbTableTennisButton.toggle(enabled: !enabled)
        mbShowQrCode.toggle(enabled: !enabled)
    }
    
    func toggleButtonAtIndex(_ index: Int, enabled: Bool) {
        if let buttons = stackView.arrangedSubviews as? [MenuButton] {
            guard index >= 0 && index < 4 else {
                return
            }
            buttons[index].toggle(enabled: enabled, animated: true)
        }
    }
    
    private func setupChildViews() {
        NSLayoutConstraint.pinToView(self, stackView, padding: 4)
        
        stackView.addArrangedSubview(mbToggleCamera)
        stackView.addArrangedSubview(mbShowQrCode)
        stackView.addArrangedSubview(mbFoosballButton)
        stackView.addArrangedSubview(mbTableTennisButton)
    }
    
    private func configureUI() {
        backgroundColor = .white
        applyMediumDropShadow(UIColor.OS.Text.normal)
        applyCornerRadius(8)
    }
    
    // MARK: - Button Handling
    
    @objc private func foosballButtonTapped(_ sender: MenuButton) {
        feedbackGenerator.impactOccurred()
        delegate?.foosballButtonTapped()
    }
    
    @objc private func tableTennisButtonTapped(_ sender: MenuButton) {
        feedbackGenerator.impactOccurred()
        delegate?.tableTennisButtonTapped()
    }
    
    @objc private func toggleCameraButtonTapped(_ sender: MenuButton) {
        feedbackGenerator.impactOccurred()
        delegate?.toggleCameraButtonTapped()
    }
    
    @objc private func displayCodeButtonTapped(_ sender: MenuButton) {
        feedbackGenerator.impactOccurred()
        delegate?.displayCodeButtonTapped()
    }
}

// MARK: - Menu Button

private final class MenuButton: UIButton {
    
    init(_ backgroundColor: UIColor? = nil, image: UIImage? = nil) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = backgroundColor
        setImage(image, for: .normal)
        tintColor = UIColor.OS.General.main
        applyCornerRadius(5)
    }
    
    init(_ backgroundColor: UIColor?, emoji: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = backgroundColor
        setTitle(emoji, for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: 26)
        applyCornerRadius(5)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func toggle(enabled: Bool, animated: Bool = false) {
        guard isEnabled != enabled else { return }
        isEnabled = enabled
        if enabled {
            tintColor = UIColor.OS.General.main
        } else {
            tintColor = UIColor.OS.Text.disabled
        }
    }
}
