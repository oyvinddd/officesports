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
        label.font = UIFont.boldSystemFont(ofSize: 26)
        return label
    }()
    
    private lazy var closeButton: UIButton = {
        let image = UIImage(systemName: "xmark", withConfiguration: nil)
        let button = UIButton.createButton(.white, tintColor: UIColor.OS.General.main, image: image)
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        button.backgroundColor = .white
        button.applyCornerRadius(16)
        button.alpha = 0.7
        return button
    }()
    
    private lazy var defaultScreenWrap: UIView = {
        let view = UIView.createView(UIColor.OS.General.mainDark, cornerRadius: 5)
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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupChildViews()
        configureUI()
    }
    
    private func setupChildViews() {
        view.addSubview(titleLabel)
        view.addSubview(closeButton)
        view.addSubview(defaultScreenWrap)
        
        NSLayoutConstraint.activate([
            titleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            closeButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            closeButton.widthAnchor.constraint(equalToConstant: 32),
            closeButton.heightAnchor.constraint(equalTo: closeButton.widthAnchor),
            defaultScreenWrap.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            defaultScreenWrap.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            defaultScreenWrap.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 32)
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
