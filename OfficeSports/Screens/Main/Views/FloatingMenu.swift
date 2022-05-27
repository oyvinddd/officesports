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
    
    func scannerButtonTapped()
    
    func foosballButtonTapped()
    
    func tableTennisButtonTapped()
    
    func invitesButtonTapped()
}

final class FloatingMenu: UIView {
    
    private lazy var selectedView: UIView = {
        let wrapper = UIView.createView(.clear)
        let inner = UIView.createView(UIColor.OS.General.main)
        inner.applyCornerRadius(6)
        inner.alpha = 0.2
        NSLayoutConstraint.pinToView(wrapper, inner, padding: 4)
        return wrapper
    }()
    
    private lazy var stackView: UIStackView = {
        return UIStackView.createStackView(.clear, axis: .horizontal, spacing: 4)
    }()
    
    private lazy var mbScanner: MenuButton = {
        let button = MenuButton(.clear, image: UIImage(systemName: "qrcode.viewfinder", withConfiguration: buttonImageConfig))
        button.addTarget(self, action: #selector(scannerButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var mbFoosball: MenuButton = {
        let image = UIImage(named: "Soccer")!.withRenderingMode(.alwaysTemplate)
        let button = MenuButton(.clear, image: image)
        button.addTarget(self, action: #selector(foosballButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var mbTableTennis: MenuButton = {
        let image = UIImage(named: "TableTennis")!.withRenderingMode(.alwaysTemplate)
        let button = MenuButton(.clear, image: image)
        button.addTarget(self, action: #selector(tableTennisButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var mbInvites: MenuButton = {
        let button = MenuButton(.clear, image: UIImage(systemName: "bell.badge", withConfiguration: buttonImageConfig))
        button.addTarget(self, action: #selector(invitesButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var buttonImageConfig: UIImage.Configuration = {
        return UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold, scale: .large)
    }()
    
    private lazy var feedbackGenerator: UIImpactFeedbackGenerator = {
        return UIImpactFeedbackGenerator(style: .medium)
    }()
    
    private var selectedViewLeftConstraint: NSLayoutConstraint?
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
    
    func repositionButtonSelection(_ scrollView: UIScrollView) {
        // get the current content offset in percent whenever users is scrolling the scroll view
        var xOffsetPercent = scrollView.contentOffset.x * 100 / scrollView.contentSize.width
        if xOffsetPercent < 0 {
            xOffsetPercent = 0
        } else if xOffsetPercent > 75 {
            xOffsetPercent = 75
        }
        selectedViewLeftConstraint!.constant = xOffsetPercent * frame.width / 100
    }
    
    private func setupChildViews() {
        addSubview(selectedView)
        
        selectedViewLeftConstraint = selectedView.leftAnchor.constraint(equalTo: leftAnchor)
        NSLayoutConstraint.activate([
            selectedView.topAnchor.constraint(equalTo: topAnchor),
            selectedView.bottomAnchor.constraint(equalTo: bottomAnchor),
            selectedView.widthAnchor.constraint(equalTo: selectedView.heightAnchor),
            selectedViewLeftConstraint!,
            selectedView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        NSLayoutConstraint.pinToView(self, stackView, padding: 4)
        
        stackView.addArrangedSubview(mbScanner)
        stackView.addArrangedSubview(mbFoosball)
        stackView.addArrangedSubview(mbTableTennis)
        stackView.addArrangedSubview(mbInvites)
    }
    
    private func configureUI() {
        backgroundColor = .white
        applyMediumDropShadow(UIColor.OS.Text.normal)
        applyCornerRadius(8)
    }
    
    // MARK: - Menu Button Handling
    
    @objc private func scannerButtonTapped(_ sender: MenuButton) {
        feedbackGenerator.impactOccurred()
        delegate?.scannerButtonTapped()
    }
    
    @objc private func foosballButtonTapped(_ sender: MenuButton) {
        feedbackGenerator.impactOccurred()
        delegate?.foosballButtonTapped()
    }
    
    @objc private func tableTennisButtonTapped(_ sender: MenuButton) {
        feedbackGenerator.impactOccurred()
        delegate?.tableTennisButtonTapped()
    }
    
    @objc private func invitesButtonTapped(_ sender: MenuButton) {
        feedbackGenerator.impactOccurred()
        delegate?.invitesButtonTapped()
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
    }
    
    init(_ backgroundColor: UIColor?, emoji: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = backgroundColor
        setTitle(emoji, for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: 26)
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
