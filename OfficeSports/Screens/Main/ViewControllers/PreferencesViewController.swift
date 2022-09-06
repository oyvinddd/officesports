//
//  PreferencesViewController.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 24/05/2022.
//

import UIKit

final class PreferencesViewController: UIViewController {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel.createLabel(.white, text: "Preferences")
        label.font = UIFont.boldSystemFont(ofSize: 30)
        return label
    }()
    
    private lazy var closeButton: UIButton = {
        let image = UIImage(systemName: "xmark", withConfiguration: nil)
        let button = UIButton.createButton(.white, tintColor: UIColor.OS.General.main, image: image)
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        button.backgroundColor = .white
        button.applyCornerRadius(20)
        button.alpha = 0.7
        return button
    }()
    
    private lazy var defaultScreenWrap: UIView = {
        let view = UIView.createView(UIColor.OS.General.mainDark, cornerRadius: 8)
        let titleLabel = UILabel.createLabel(.white, alignment: .left, text: "Default screen")
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        let descriptionLabel = UILabel.createLabel(.white, alignment: .left)
        descriptionLabel.text = "Choose what screen should be shown when you first open the app."
        
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(defaultScreenControl)
        
        NSLayoutConstraint.activate([
            titleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8),
            titleLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            descriptionLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8),
            descriptionLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            defaultScreenControl.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8),
            defaultScreenControl.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8),
            defaultScreenControl.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 16),
            defaultScreenControl.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8),
            defaultScreenControl.heightAnchor.constraint(equalToConstant: 44)
        ])
        return view
    }()
    
    private lazy var defaultScreenControl: UISegmentedControl = {
        let items = ["📸", "🏓", "⚽️", "🎱"]
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.addTarget(self, action: #selector(screenControlTapped), for: .valueChanged)
        segmentedControl.selectedSegmentIndex = UserDefaultsHelper.loadDefaultScreen()
        segmentedControl.selectedSegmentTintColor = .white
        segmentedControl.backgroundColor = UIColor.OS.General.mainDark
        let attr1 = [NSAttributedString.Key.foregroundColor: UIColor.OS.Text.normal]
        let attr2 = [NSAttributedString.Key.foregroundColor: UIColor.OS.General.main]
        segmentedControl.setTitleTextAttributes(attr1, for: .normal)
        segmentedControl.setTitleTextAttributes(attr2, for: .selected)
        return segmentedControl
    }()
    
    private lazy var sportToggleView: UIView = {
        let view = UIView.createView(UIColor.OS.General.mainDark, cornerRadius: 8)
        let titleLabel = UILabel.createLabel(.white, alignment: .left, text: "Toggle sports")
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        let descriptionLabel = UILabel.createLabel(.white, alignment: .left)
        descriptionLabel.text = "Choose what sports to show in the main menu. Note that the app needs to be restarted in order for the changes to take effect."
        
        let tableTennisView = SportView(sport: .tableTennis)
        let foosballView = SportView(sport: .foosball)
        let poolView = SportView(sport: .pool)
        
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(tableTennisView)
        view.addSubview(foosballView)
        view.addSubview(poolView)
        
        NSLayoutConstraint.activate([
            titleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8),
            titleLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            descriptionLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8),
            descriptionLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            tableTennisView.leftAnchor.constraint(equalTo: descriptionLabel.leftAnchor),
            tableTennisView.rightAnchor.constraint(equalTo: descriptionLabel.rightAnchor),
            tableTennisView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 16),
            foosballView.leftAnchor.constraint(equalTo: descriptionLabel.leftAnchor),
            foosballView.rightAnchor.constraint(equalTo: descriptionLabel.rightAnchor),
            foosballView.topAnchor.constraint(equalTo: tableTennisView.bottomAnchor, constant: 8),
            poolView.leftAnchor.constraint(equalTo: descriptionLabel.leftAnchor),
            poolView.rightAnchor.constraint(equalTo: descriptionLabel.rightAnchor),
            poolView.topAnchor.constraint(equalTo: foosballView.bottomAnchor, constant: 8),
            poolView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8)
        ])
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupChildViews()
        configureUI()
    }
    
    private func setupChildViews() {
        view.addSubview(titleLabel)
        view.addSubview(closeButton)
        view.addSubview(defaultScreenWrap)
        view.addSubview(sportToggleView)
        
        NSLayoutConstraint.activate([
            titleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            closeButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalTo: closeButton.widthAnchor),
            defaultScreenWrap.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            defaultScreenWrap.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            defaultScreenWrap.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 32),
            sportToggleView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            sportToggleView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            sportToggleView.topAnchor.constraint(equalTo: defaultScreenWrap.bottomAnchor, constant: 16)
        ])
    }
    
    private func configureUI() {
        view.backgroundColor = UIColor.OS.General.main
    }
    
    @objc private func screenControlTapped(_ sender: UISegmentedControl) {
        UserDefaultsHelper.saveDefaultScreen(index: sender.selectedSegmentIndex)
    }
    
    @objc private func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

// MARK: - Sport View

private final class SportView: UIView {
    
    private lazy var sportImageWrap: UIView = {
        return UIView.createView(.white, cornerRadius: 18)
    }()
    
    private lazy var sportEmojiLabel: UILabel = {
        let label = UILabel.createLabel(.black, alignment: .center)
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()
    
    private lazy var sportLabel: UILabel = {
        let label = UILabel.createLabel(.white)
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    private lazy var sportSwitch: UISwitch = {
        let sportSwitch = UISwitch(frame: .zero)
        sportSwitch.translatesAutoresizingMaskIntoConstraints = false
        sportSwitch.onTintColor = UIColor.OS.Status.success
        sportSwitch.tintColor = UIColor.OS.Status.failure
        return sportSwitch
    }()
    
    init(sport: OSSport) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        sportImageWrap.backgroundColor = UIColor.OS.colorForSport(sport)
        sportEmojiLabel.text = sport.emoji
        sportLabel.text = sport.humanReadableName.capitalized
        setupChildViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupChildViews() {
        addSubview(sportImageWrap)
        addSubview(sportLabel)
        addSubview(sportSwitch)
        
        NSLayoutConstraint.pinToView(sportImageWrap, sportEmojiLabel)
        
        NSLayoutConstraint.activate([
            sportImageWrap.leftAnchor.constraint(equalTo: leftAnchor, constant: 8),
            sportImageWrap.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            sportImageWrap.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            sportImageWrap.heightAnchor.constraint(equalToConstant: 36),
            sportImageWrap.widthAnchor.constraint(equalTo: sportImageWrap.heightAnchor),
            sportLabel.leftAnchor.constraint(equalTo: sportImageWrap.rightAnchor, constant: 12),
            sportLabel.topAnchor.constraint(equalTo: sportImageWrap.topAnchor),
            sportLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            sportSwitch.leftAnchor.constraint(equalTo: sportLabel.rightAnchor, constant: 8),
            sportSwitch.rightAnchor.constraint(equalTo: rightAnchor, constant: -8),
            sportSwitch.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
