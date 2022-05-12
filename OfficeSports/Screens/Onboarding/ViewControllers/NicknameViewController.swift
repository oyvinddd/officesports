//
//  NicknameViewController.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 11/05/2022.
//

import UIKit

final class NicknameViewController: UIViewController {

    private lazy var titleLabel: UILabel = {
        let label = UILabel.createLabel(.white)
        label.font = UIFont.boldSystemFont(ofSize: 32)
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel.createLabel(.white)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func setupChildViews() {
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
    }
}
