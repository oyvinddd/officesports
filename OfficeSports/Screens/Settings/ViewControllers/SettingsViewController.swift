//
//  SettingsViewController.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 12/05/2022.
//

import UIKit

private let kDialogMinHeight: CGFloat = 150
private let kBackgroundMaxFade: CGFloat = 0.7
private let kBackgroundMinFade: CGFloat = 0
private let kAnimDuration: TimeInterval = 0.15
private let kAnimDelay: TimeInterval = 0

final class SettingsViewController: UIViewController {
    
    private lazy var backgroundView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addGestureRecognizer(tapRecognizer)
        view.backgroundColor = .black
        view.alpha = 0
        return view
    }()
    
    private lazy var dialogView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var contentWrapView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        label.textColor = .lightGray
        label.text = "No Content"
        return label
    }()
    
    private lazy var signOutButton: UIButton = {
        let button = UIButton.createButton(.black, .white, title: "Sign Out")
        button.addTarget(self, action: #selector(signOutButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var tapRecognizer: UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
    }()
    
    private lazy var dialogBottomConstraint: NSLayoutConstraint = {
        let constraint = dialogView.topAnchor.constraint(equalTo: view.bottomAnchor)
        constraint.constant = dialogHideConstant
        return constraint
    }()
    
    private let dialogHideConstant: CGFloat = 0
    private var dialogShowConstant: CGFloat {
        return -dialogView.frame.height
    }
    
    init(with contentView: UIView? = nil, cornerRadius: CGFloat = 20) {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        dialogView.layer.cornerRadius = cornerRadius
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupChildViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        toggleDialog(enabled: true)
    }
    
    private func setupChildViews() {
        view.addSubview(backgroundView)
        view.addSubview(dialogView)
        dialogView.addSubview(contentWrapView)
        contentWrapView.addSubview(placeholderLabel)
        
        NSLayoutConstraint.activate([
            // background view (low opacity)
            backgroundView.leftAnchor.constraint(equalTo: view.leftAnchor),
            backgroundView.rightAnchor.constraint(equalTo: view.rightAnchor),
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            // bottom dialog view (white)
            dialogView.leftAnchor.constraint(equalTo: view.leftAnchor),
            dialogView.rightAnchor.constraint(equalTo: view.rightAnchor),
            dialogBottomConstraint,
            // content wrap view
            contentWrapView.leftAnchor.constraint(equalTo: dialogView.leftAnchor, constant: 8),
            contentWrapView.rightAnchor.constraint(equalTo: dialogView.rightAnchor, constant: -8),
            contentWrapView.topAnchor.constraint(equalTo: dialogView.topAnchor, constant: 8),
            contentWrapView.bottomAnchor.constraint(equalTo: dialogView.safeAreaLayoutGuide.bottomAnchor),
            contentWrapView.heightAnchor.constraint(greaterThanOrEqualToConstant: kDialogMinHeight),
            // no content label
            placeholderLabel.leftAnchor.constraint(equalTo: contentWrapView.leftAnchor),
            placeholderLabel.rightAnchor.constraint(equalTo: contentWrapView.rightAnchor),
            placeholderLabel.topAnchor.constraint(equalTo: contentWrapView.topAnchor),
            placeholderLabel.bottomAnchor.constraint(equalTo: contentWrapView.bottomAnchor)
        ])
    }
    
    private func toggleDialog(enabled: Bool) {
        if enabled {
            dialogBottomConstraint.constant = dialogShowConstant
        } else {
            dialogBottomConstraint.constant = dialogHideConstant
        }
        toggleBackgroundView(enabled: enabled)
        UIView.animate(
            withDuration: kAnimDuration,
            delay: kAnimDelay,
            options: [.curveEaseOut]) {
            self.view.layoutIfNeeded()
        } completion: {_ in
            if !enabled {
                self.dismiss()
            }
        }

    }
    
    private func toggleBackgroundView(enabled: Bool) {
        UIView.animate(withDuration: kAnimDuration) {
            self.backgroundView.alpha = enabled ? kBackgroundMaxFade : kBackgroundMinFade
        }
    }
    
    private func dismiss() {
        dismiss(animated: false, completion: nil)
    }
    
    @objc private func backgroundTapped(sender: UITapGestureRecognizer) {
        toggleDialog(enabled: false)
    }
    
    @objc private func signOutButtonTapped(_ sender: UIButton) {
        
    }
}
