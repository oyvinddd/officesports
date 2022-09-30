//
//  JoinTeamViewController.swift
//  OfficeSports
//
//  Created by Øyvind Hauge on 29/09/2022.
//

import UIKit

final class JoinTeamViewController: UIViewController {

    private let viewModel: JoinTeamViewModel
    
    init(viewModel: JoinTeamViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applySheetPresentation()
        setupChildViews()
        configureUI()
    }
    
    private func setupChildViews() {
        
    }
    
    private func configureUI() {
        view.backgroundColor = .white
    }
}

// MARK: - Input Field

private final class InputField: UIView {
    
}
