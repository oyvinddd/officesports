//
//  SportViewController.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 10/05/2022.
//

import UIKit

final class SportViewController: UIViewController {
    
    private lazy var tableView: UITableView = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshPulled), for: .valueChanged)
        let tableView = UITableView.createTableView(.clear, dataSource: self)
        tableView.registerCell(SportFilterTableViewCell.self)
        tableView.registerCell(PlacementTableViewCell.self)
        tableView.registerCell(MatchTableViewCell.self)
        tableView.refreshControl = refreshControl
        return tableView
    }()
    
    private let viewModel: SportViewModel
    private var showScoreboard: Bool = true
    
    init(viewModel: SportViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        viewModel.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupChildViews()
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchRecentMatches()
        viewModel.fetchScoreboard()
    }
    
    func applyContentInsetToTableView(_ contentInset: UIEdgeInsets) {
        tableView.contentInset = contentInset
        scrollTableViewToTop(animated: false)
    }
    
    func scrollTableViewToTop(animated: Bool) {
        // scroll table view all the way to the top, taking
        // into consideration the custom content inset of the table
        tableView.scrollToTop(animated: animated)
    }
    
    private func setupChildViews() {
        NSLayoutConstraint.pinToView(view, tableView)
    }
    
    private func configureUI() {
        view.backgroundColor = .clear
    }
    
    @objc private func refreshPulled(_ sender: UIRefreshControl) {
        viewModel.fetchRecentMatches()
        viewModel.fetchScoreboard()
    }
}

// MARK: - Table View Data Source

extension SportViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : (showScoreboard ? viewModel.scoreboard.count : viewModel.recentMatches.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(for: SportFilterTableViewCell.self, for: indexPath)
            cell.toggleLeftButton(enabled: showScoreboard)
            cell.delegate = self
            return cell
        }
        
        let isFirstElement = indexPath.row == 0
        let isLastElement = indexPath.row == (showScoreboard ? viewModel.scoreboard.count - 1 : viewModel.recentMatches.count - 1)
        
        if showScoreboard {
            let cell = tableView.dequeueReusableCell(for: PlacementTableViewCell.self, for: indexPath)
            cell.setPlayerAndPlacement(viewModel.scoreboard[indexPath.row], indexPath.row)
            cell.applyCornerRadius(isFirstElement: isFirstElement, isLastElement: isLastElement)
            return cell
        }
        let cell = tableView.dequeueReusableCell(for: MatchTableViewCell.self, for: indexPath)
        cell.applyCornerRadius(isFirstElement: isFirstElement, isLastElement: isLastElement)
        cell.match = viewModel.recentMatches[indexPath.row]
        return cell
    }
}

// MARK: - Table View Delegate

extension SportViewController: UITableViewDelegate {
}

// MARK: - Sport View Model Delegate

extension SportViewController: SportViewModelDelegate {
    
    func fetchedScoreboardSuccessfully() {
        tableView.reloadData()
    }
    
    func didFetchScoreboard(with error: Error) {
        Coordinator.global.showMessage(OSMessage(error.localizedDescription, .failure))
    }
    
    func fetchedRecentMatchesSuccessfully() {
        // tableView.reloadData()
    }
    
    func didFetchRecentMatches(with error: Error) {
        Coordinator.global.showMessage(OSMessage(error.localizedDescription, .failure))
    }
    
    func shouldToggleLoading(enabled: Bool) {
        tableView.refreshControl?.endRefreshing()
    }
}

// MARK: - Sport Filter Delegate

extension SportViewController: SportFilterDelegate {
    
    func leftButtonTapped() {
        showScoreboard = true
        tableView.reloadData()
    }
    
    func rightButtonTapped() {
        showScoreboard = false
        tableView.reloadData()
    }
}
