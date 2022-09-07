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
    
    func tableTennisButtonTapped()
    
    func foosballButtonTapped()
    
    func poolButtonTapped()
    
    func tableTennisButtonDoubleTapped()
    
    func foosballButtonDoubleTapped()
}

final class FloatingMenu: UIView {
    
    private lazy var selectedView: UIView = {
        let wrapper = UIView.createView(.clear)
        let inner = UIView.createView(UIColor.OS.General.main, cornerRadius: 6)
        inner.alpha = 0.2
        NSLayoutConstraint.pinToView(wrapper, inner, padding: 4)
        return wrapper
    }()
    
    private lazy var stackView: UIStackView = {
        return UIStackView.createStackView(.clear, axis: .horizontal)
    }()
    
    private lazy var mbScanner: MenuButton = {
        let button = MenuButton(.clear, image: UIImage(systemName: "qrcode.viewfinder", withConfiguration: buttonImageConfig))
        button.addTarget(self, action: #selector(scannerButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var mbTableTennis: MenuButton = {
        let button = MenuButton(.clear, image: UIImage(named: "TableTennis")!.withRenderingMode(.alwaysTemplate))
        button.addTarget(self, action: #selector(tableTennisButtonTapped), for: .touchUpInside)
        button.addTarget(self, action: #selector(tableTennisButtonDoubleTapped), for: .touchDownRepeat)
        return button
    }()
    
    private lazy var mbFoosball: MenuButton = {
        let button = MenuButton(.clear, image: UIImage(named: "Soccer")!.withRenderingMode(.alwaysTemplate))
        button.addTarget(self, action: #selector(foosballButtonTapped), for: .touchUpInside)
        button.addTarget(self, action: #selector(foosballButtonDoubleTapped), for: .touchDownRepeat)
        return button
    }()
    
    private lazy var mbPool: MenuButton = {
        let button = MenuButton(.clear, image: UIImage(named: "Pool")!.withRenderingMode(.alwaysTemplate))
        button.addTarget(self, action: #selector(poolButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var buttonImageConfig: UIImage.Configuration = {
        return UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold, scale: .large)
    }()
    
    private lazy var feedbackGenerator: UIImpactFeedbackGenerator = {
        return UIImpactFeedbackGenerator(style: .medium)
    }()
    
    private var selectedViewLeftConstraint: NSLayoutConstraint?
    private var noOfButtons = 1
    
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
    
    func adjustSelectionFromOuterScrollView(_ scrollView: UIScrollView) {
        let buttonWidth: CGFloat = 60
        let menuWidth: CGFloat = frame.width
        let noOfSports: CGFloat = CGFloat(noOfButtons - 1)
        
        var xOffsetPercent = scrollView.contentOffset.x * 100 / scrollView.contentSize.width
        if xOffsetPercent < 0 {
            xOffsetPercent = 0
        }
        let xOffsetInMenu = (menuWidth - buttonWidth * (noOfSports - 1)) * xOffsetPercent / 100
        selectedViewLeftConstraint!.constant = xOffsetInMenu
    }
    
    func adjustselectionFromInnerScrollView(_ scrollView: UIScrollView) {
        let buttonWidth: CGFloat = 60
        
        // get the current content offset in percent whenever users is scrolling the scroll view
        let xOffsetPercent = scrollView.contentOffset.x * 100 / scrollView.contentSize.width
        let xOffsetInMenu = (frame.width - buttonWidth) * xOffsetPercent / 100
        selectedViewLeftConstraint!.constant = xOffsetInMenu + buttonWidth
    }
    
    private func setupChildViews() {
        addSubview(selectedView)
        
        NSLayoutConstraint.pinToView(self, stackView)
        
        let showTableTennis = UserDefaultsHelper.loadToggledStateFor(sport: .tableTennis)
        let showFoosball = UserDefaultsHelper.loadToggledStateFor(sport: .foosball)
        let showPool = UserDefaultsHelper.loadToggledStateFor(sport: .pool)
        
        stackView.addArrangedSubview(mbScanner)
        
        if showTableTennis {
            stackView.addArrangedSubview(mbTableTennis)
            mbTableTennis.widthAnchor.constraint(equalTo: heightAnchor).isActive = true
            noOfButtons += 1
        }
        if showFoosball {
            stackView.addArrangedSubview(mbFoosball)
            mbFoosball.widthAnchor.constraint(equalTo: heightAnchor).isActive = true
            noOfButtons += 1
        }
        if showPool {
            stackView.addArrangedSubview(mbPool)
            mbPool.widthAnchor.constraint(equalTo: heightAnchor).isActive = true
            noOfButtons += 1
        }
        
        selectedViewLeftConstraint = selectedView.leftAnchor.constraint(equalTo: leftAnchor)
        
        NSLayoutConstraint.activate([
            selectedView.topAnchor.constraint(equalTo: topAnchor),
            selectedView.bottomAnchor.constraint(equalTo: bottomAnchor),
            selectedView.widthAnchor.constraint(equalTo: mbScanner.widthAnchor),
            selectedViewLeftConstraint!,
            selectedView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
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
    
    @objc private func tableTennisButtonTapped(_ sender: MenuButton) {
        feedbackGenerator.impactOccurred()
        delegate?.tableTennisButtonTapped()
    }
    
    @objc private func foosballButtonTapped(_ sender: MenuButton) {
        feedbackGenerator.impactOccurred()
        delegate?.foosballButtonTapped()
    }
    
    @objc private func poolButtonTapped(_ sender: MenuButton) {
        feedbackGenerator.impactOccurred()
        delegate?.poolButtonTapped()
    }
    
    @objc private func tableTennisButtonDoubleTapped(_ sender: MenuButton) {
        delegate?.tableTennisButtonDoubleTapped()
    }
    
    @objc private func foosballButtonDoubleTapped(_ sender: MenuButton) {
        delegate?.foosballButtonDoubleTapped()
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
