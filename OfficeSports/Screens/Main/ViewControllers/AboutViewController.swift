//
//  AboutViewController.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 24/05/2022.
//

import UIKit

final class AboutViewController: UIViewController {
    
    private lazy var versionLabel: UILabel = {
        let text = "Version \(Bundle.main.appVersionNumber ?? "") (\(Bundle.main.appBuildNumber ?? ""))"
        let label = UILabel.createLabel(.white, alignment: .center, text: text)
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.alpha = 0.5
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupChildViews()
        view.backgroundColor = UIColor.OS.General.main
    }
    
    private func setupChildViews() {
        view.addSubview(versionLabel)
        
        NSLayoutConstraint.activate([
            versionLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            versionLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            versionLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
