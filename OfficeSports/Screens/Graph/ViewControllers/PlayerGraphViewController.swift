//
//  PlayerGraphViewController.swift
//  OfficeSports
//
//  Created by Øyvind Hauge on 05/09/2022.
//

import UIKit

final class PlayerGraphViewController: UIViewController {

    private let viewModel: PlayerGraphViewModel
    
    init(viewModel: PlayerGraphViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
