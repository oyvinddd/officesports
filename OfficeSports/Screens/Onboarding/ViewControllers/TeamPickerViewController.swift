//
//  TeamPickerViewController.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 12/05/2022.
//

import UIKit
import Combine

private let kBackgroundMaxFade: CGFloat = 0.6
private let kBackgroundMinFade: CGFloat = 0
private let kAnimDuration: TimeInterval = 0.15
private let kAnimDelay: TimeInterval = 0

final class TeamPickerViewController: UIViewController {
    
    private lazy var backgroundView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addGestureRecognizer(tapRecognizer)
        view.backgroundColor = .black
        view.alpha = 0
        return view
    }()
    
    private lazy var dialogView: UIView = {
        let view = UIView.createView(.white)
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        return view
    }()
    
    private lazy var dialogHandle: UIView = {
        let view = UIView.createView(UIColor.OS.Text.subtitle, cornerRadius: 3)
        view.alpha = 0.8
        return view
    }()
    
    private lazy var contentWrapView: UIView = {
        return UIView.createView(.white)
    }()
    
    private lazy var stackView: UIStackView = {
        return UIStackView.createStackView(.clear, axis: .vertical, spacing: 0)
    }()
    
    private lazy var tapRecognizer: UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
    }()
    
    private lazy var dialogBottomConstraint: NSLayoutConstraint = {
        let constraint = dialogView.topAnchor.constraint(equalTo: view.bottomAnchor)
        constraint.constant = dialogHideConstant
        return constraint
    }()
    
    private lazy var selectButton: OSButton = {
        let button = OSButton("Select team", type: .primary, state: .normal)
        return button
    }()
    
    private let dialogHideConstant: CGFloat = 0
    private var dialogShowConstant: CGFloat {
        return -dialogView.frame.height
    }
    
    private var subscribers: [AnyCancellable] = []
    private let viewModel: TeamsViewModel
    
    init(viewModel: TeamsViewModel, cornerRadius: CGFloat = 20) {
        self.viewModel = viewModel
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
        setupSubscribers()
        setupChildViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        toggleDialog(enabled: true)
    }
    
    private func setupSubscribers() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { state in
                switch state {
                case .loading:
                    return
                case .success:
                    
                    return
                case .failure(let error):
                    Coordinator.global.send(error)
                default:
                    // do nothing
                    break
                }
            }
            .store(in: &subscribers)
    }
    
    private func setupChildViews() {
        view.addSubview(backgroundView)
        view.addSubview(dialogView)
        view.addSubview(dialogHandle)
        dialogView.addSubview(contentWrapView)
        contentWrapView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            backgroundView.leftAnchor.constraint(equalTo: view.leftAnchor),
            backgroundView.rightAnchor.constraint(equalTo: view.rightAnchor),
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dialogView.leftAnchor.constraint(equalTo: view.leftAnchor),
            dialogView.rightAnchor.constraint(equalTo: view.rightAnchor),
            dialogBottomConstraint,
            dialogHandle.centerXAnchor.constraint(equalTo: dialogView.centerXAnchor),
            dialogHandle.topAnchor.constraint(equalTo: dialogView.topAnchor, constant: 10),
            dialogHandle.widthAnchor.constraint(equalToConstant: 40),
            dialogHandle.heightAnchor.constraint(equalToConstant: 6),
            contentWrapView.leftAnchor.constraint(equalTo: dialogView.leftAnchor, constant: 8),
            contentWrapView.rightAnchor.constraint(equalTo: dialogView.rightAnchor, constant: -8),
            contentWrapView.topAnchor.constraint(equalTo: dialogHandle.topAnchor, constant: 8),
            contentWrapView.bottomAnchor.constraint(equalTo: dialogView.safeAreaLayoutGuide.bottomAnchor),
            stackView.leftAnchor.constraint(equalTo: contentWrapView.leftAnchor),
            stackView.rightAnchor.constraint(equalTo: contentWrapView.rightAnchor),
            stackView.topAnchor.constraint(equalTo: contentWrapView.topAnchor, constant: 16),
            stackView.bottomAnchor.constraint(equalTo: contentWrapView.safeAreaLayoutGuide.bottomAnchor, constant: -16)
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
    
    // MARK: - Button Handling
    
    @objc private func backgroundTapped(_ sender: UITapGestureRecognizer) {
        toggleDialog(enabled: false)
    }
}
