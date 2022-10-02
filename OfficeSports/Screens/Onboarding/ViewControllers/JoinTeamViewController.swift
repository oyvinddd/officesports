//
//  JoinTeamViewController.swift
//  OfficeSports
//
//  Created by Øyvind Hauge on 29/09/2022.
//

import UIKit

final class JoinTeamViewController: UIViewController {
    
    private lazy var contentWrap: UIView = {
        let view = UIView.createView(.white)
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        view.layer.cornerRadius = 8
        return view
    }()
    
    private lazy var shadowView: UIView = {
        let view = UIView.createView(.black)
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(shadowViewTapped))
        view.addGestureRecognizer(tapRecognizer)
        view.alpha = 0.6
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel.createLabel(UIColor.OS.Text.normal)
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        return label
    }()
    
    private lazy var codeInputView: CodeInputView = {
        return CodeInputView()
    }()
    
    private var dialogBottomConstraint: NSLayoutConstraint?

    private let viewModel: JoinTeamViewModel
    private let team: OSTeam
    
    init(viewModel: JoinTeamViewModel, team: OSTeam) {
        self.viewModel = viewModel
        self.team = team
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overCurrentContext
        titleLabel.text = "Insert password for the team \(team.name)"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupChildViews()
        configureUI()
    }
    
    private func setupChildViews() {
        NSLayoutConstraint.pinToView(view, shadowView)
        
        view.addSubview(contentWrap)
        contentWrap.addSubview(titleLabel)
        contentWrap.addSubview(codeInputView)
        
        dialogBottomConstraint = contentWrap.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        
        NSLayoutConstraint.activate([
            contentWrap.leftAnchor.constraint(equalTo: view.leftAnchor),
            contentWrap.rightAnchor.constraint(equalTo: view.rightAnchor),
            dialogBottomConstraint!,
            titleLabel.leftAnchor.constraint(equalTo: contentWrap.leftAnchor, constant: 16),
            titleLabel.rightAnchor.constraint(equalTo: contentWrap.rightAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: contentWrap.topAnchor, constant: 22),
            codeInputView.leftAnchor.constraint(equalTo: contentWrap.leftAnchor, constant: 16),
            codeInputView.rightAnchor.constraint(equalTo: contentWrap.rightAnchor, constant: -16),
            codeInputView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 22),
            codeInputView.bottomAnchor.constraint(equalTo: contentWrap.safeAreaLayoutGuide.bottomAnchor, constant: -32),
            codeInputView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func configureUI() {
        view.backgroundColor = .clear
    }
    
    @objc private func shadowViewTapped() {
        dismiss(animated: false)
    }
}
