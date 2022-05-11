//
//  SportViewController.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 10/05/2022.
//

import UIKit

final class SportViewController: UIViewController {

    private lazy var tableView: UITableView = {
        let tableView = UITableView.createTableView(.clear)
        tableView.registerCell(PlacementTableViewCell.self)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        tableView.dataSource = self
        return tableView
    }()
    
    private var viewModel: ScoreboardViewModel
    
    init(viewModel: ScoreboardViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupChildViews()
        configureUI()
    }
    
    func applyContentInsetToTableView(_ contentInset: UIEdgeInsets) {
        tableView.contentInset = contentInset
    }
    
    private func setupChildViews() {
        NSLayoutConstraint.pinToView(view, tableView)
    }
    
    private func configureUI() {
        view.backgroundColor = .clear
    }
}

// MARK: - Table View Data Source

extension SportViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: PlacementTableViewCell.self, for: indexPath)
        cell.setPlayerAndPlacement(viewModel.results[indexPath.row], indexPath.row)
        cell.applyCornerRadius(isFirstElement: indexPath.row == 0, isLastElement: indexPath.row == viewModel.results.count - 1)
        return cell
    }
}

// MARK: - Table View Delegate

extension SportViewController: UITableViewDelegate {
}
