//
//  SingleDuoView.swift
//  OfficeSports
//
//  Created by Øyvind Hauge on 16/09/2022.
//

import UIKit

final class SingleDuoView: UIView {
    
    private lazy var blurView: UIView = {
        let view = UIView.createView(.clear)
        let blurEffect = UIBlurEffect(style: .regular)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(blurView, at: 0)
        
        NSLayoutConstraint.activate([
            blurView.leftAnchor.constraint(equalTo: view.leftAnchor),
            blurView.rightAnchor.constraint(equalTo: view.rightAnchor),
            blurView.topAnchor.constraint(equalTo: view.topAnchor),
            blurView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        return view
    }()
    
    private lazy var singleDuoControl: UISegmentedControl = {
        let items = ["Single", "Duo"]
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.addTarget(self, action: #selector(singleDuoControlTapped), for: .valueChanged)
        segmentedControl.selectedSegmentTintColor = .white
        segmentedControl.backgroundColor = .clear
        segmentedControl.setImage(UIImage(systemName: "person.fill"), forSegmentAt: 0)
        segmentedControl.setImage(UIImage(systemName: "person.2.fill"), forSegmentAt: 1)
        
        let attr1 = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18, weight: .bold)]
        let attr2 = [NSAttributedString.Key.foregroundColor: UIColor.OS.Text.normal]
        let attr3 = [NSAttributedString.Key.foregroundColor: UIColor.OS.Text.normal]
        
        segmentedControl.setTitleTextAttributes(attr1, for: .normal)
        segmentedControl.setTitleTextAttributes(attr1, for: .selected)
        segmentedControl.setTitleTextAttributes(attr2, for: .normal)
        segmentedControl.setTitleTextAttributes(attr3, for: .selected)
        segmentedControl.selectedSegmentIndex = 0
        return segmentedControl
    }()
    
    init(singleToggled: Bool) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setupChildViews()
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupChildViews() {
        NSLayoutConstraint.pinToView(self, blurView)
        NSLayoutConstraint.pinToView(blurView, singleDuoControl)
    }
    
    private func configureUI() {
        backgroundColor = .clear
        layer.masksToBounds = true
        layer.cornerRadius = 8
        alpha = 0.9
    }
    
    @objc private func singleDuoControlTapped(_ sender: UISegmentedControl) {
        
    }
}
