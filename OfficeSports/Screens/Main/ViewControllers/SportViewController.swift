//
//  SportViewController.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 10/05/2022.
//

import UIKit

final class SportViewController: UIViewController {
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView.createTableView(.clear, dataSource: self)
        tableView.registerCell(SportFilterTableViewCell.self)
        tableView.registerCell(PlacementTableViewCell.self)
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
        scrollTableViewToTop(animated: false)
    }
    
    func scrollTableViewToTop(animated: Bool) {
        // scroll table view all the way to the top, taking
        // into consideration the custom content inset of the table view
        let customOffset = CGPoint(x: 0, y: -tableView.contentInset.top)
        tableView.setContentOffset(customOffset, animated: animated)
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : viewModel.leaderboard.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(for: SportFilterTableViewCell.self, for: indexPath)
            cell.delegate = self
            return cell
        }
        let cell = tableView.dequeueReusableCell(for: PlacementTableViewCell.self, for: indexPath)
        cell.setPlayerAndPlacement(viewModel.leaderboard[indexPath.row], indexPath.row)
        
        let isFirstElement = indexPath.row == 0
        let isLastElement = indexPath.row == viewModel.leaderboard.count - 1
        cell.applyCornerRadius(isFirstElement: isFirstElement, isLastElement: isLastElement)
        return cell
    }
}

// MARK: - Table View Delegate

extension SportViewController: UITableViewDelegate {
}

// MARK: - Sport Filter Delegate

extension SportViewController: SportFilterDelegate {
    
    func leftButtonTapped() {
    }
    
    func rightButtonTapped() {
    }
}
