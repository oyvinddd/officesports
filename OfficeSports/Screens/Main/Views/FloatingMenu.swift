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
    
    func changeSportsButtonTapped()
}

final class FloatingMenu: UIView {
    
    private lazy var stackView: UIStackView = {
        return UIStackView.createStackView(.clear, axis: .horizontal, spacing: 4)
    }()
    
    private lazy var mbSettings: MenuButton = {
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .bold, scale: .large)
        let button = MenuButton(.clear, image: UIImage(systemName: "gearshape", withConfiguration: buttonImageConfig))
        button.addTarget(self, action: #selector(settingsButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var mbChangeSports: MenuButton = {
        let button = MenuButton(.clear, image: UIImage(systemName: "arrow.left.arrow.right.square", withConfiguration: buttonImageConfig))
        button.addTarget(self, action: #selector(changeSportsButtonTapped), for: .touchUpInside)
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
        mbSettings.toggle(enabled: !enabled)
        mbChangeSports.toggle(enabled: !enabled)
        mbShowQrCode.toggle(enabled: !enabled)
    }
    
    private func setupChildViews() {
        NSLayoutConstraint.pinToView(self, stackView, padding: 4)
        
        stackView.addArrangedSubview(mbSettings)
        stackView.addArrangedSubview(mbToggleCamera)
        stackView.addArrangedSubview(mbShowQrCode)
        stackView.addArrangedSubview(mbChangeSports)
    }
    
    private func configureUI() {
        backgroundColor = .white
        applyMediumDropShadow(.black)
        applyCornerRadius(8)
    }
    
    // MARK: - Button Handling
    
    @objc private func settingsButtonTapped(_ sender: MenuButton) {
        //feedbackGenerator.impactOccurred()
        //delegate?.settingsButtonTapped()
    }
    
    @objc private func changeSportsButtonTapped(_ sender: MenuButton) {
        feedbackGenerator.impactOccurred()
        delegate?.changeSportsButtonTapped()
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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func toggle(enabled: Bool) {
        isEnabled = enabled
        if enabled {
            tintColor = UIColor.OS.General.main
        } else {
            tintColor = UIColor.OS.Text.disabled
        }
    }
}
