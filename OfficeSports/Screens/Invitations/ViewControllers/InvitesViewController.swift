//
//  InvitesViewController.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 19/05/2022.
//

import UIKit

final class InvitesViewController: UIViewController {
    
    private lazy var emptyContentLabel: UILabel = {
        let message = "Your match invitations will show up here"
        let label = UILabel.createLabel(UIColor.OS.Text.disabled, alignment: .center, text: message)
        label.font = UIFont.boldSystemFont(ofSize: 24)
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView.createTableView(.clear, dataSource: self)
        tableView.registerCell(InviteTableViewCell.self)
        return tableView
    }()
    
    private let viewModel: InvitesViewModel
    
    init(viewModel: InvitesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupChildViews()
        view.backgroundColor = .clear
    }
    
    private func setupChildViews() {
        NSLayoutConstraint.pinToView(view, tableView)
        NSLayoutConstraint.pinToView(view, emptyContentLabel, padding: 32)
    }
}

// MARK: - Table View Data Source

extension InvitesViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
