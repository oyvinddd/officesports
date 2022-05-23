//
//  EmojiPickerViewController.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 12/05/2022.
//

import UIKit

final class EmojiPickerViewController: UIViewController {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel.createLabel(UIColor.OS.Text.normal, text: "Pick an emoji")
        label.font = UIFont.boldSystemFont(ofSize: 24)
        return label
    }()
    
    private lazy var closeButton: UIButton = {
        let image = UIImage(systemName: "xmark", withConfiguration: nil)
        let button = UIButton.createButton(UIColor.OS.Text.disabled, tintColor: UIColor.OS.Text.normal, image: image)
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        button.backgroundColor = UIColor.OS.Text.disabled
        button.applyCornerRadius(16)
        button.alpha = 0.7
        return button
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView.createCollectionView()
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.registerCell(EmojiCollectionViewCell.self)
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    
    private let viewModel: EmojiViewModel
    
    init(viewModel: EmojiViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupChildViews()
        view.backgroundColor = UIColor.OS.General.background
        collectionView.backgroundColor = UIColor.OS.General.background
    }
    
    private func setupChildViews() {
        view.addSubview(titleLabel)
        view.addSubview(collectionView)
        view.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            titleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            closeButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            closeButton.widthAnchor.constraint(equalToConstant: 32),
            closeButton.heightAnchor.constraint(equalTo: closeButton.widthAnchor),
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            collectionView.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc private func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

extension EmojiPickerViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 6
        return CGSize(width: width, height: width)
    }
}

// MARK: - Collection View Data Source

extension EmojiPickerViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.emojis.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(for: EmojiCollectionViewCell.self, for: indexPath)
        cell.emoji = viewModel.emojis[indexPath.row]
        return cell
    }
}

// MARK: - Collection View Delegate

extension EmojiPickerViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let viewController = presentingViewController as? PlayerProfileViewController {
            viewController.selectedEmoji = viewModel.emojis[indexPath.row]
            dismiss(animated: true)
        }
    }
}
