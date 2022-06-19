//
//  SportViewController.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 10/05/2022.
//

import UIKit
import Combine

protocol SportViewControllerDelegate: AnyObject {
    
    func tableViewDidScroll(_ contentOffset: CGPoint)
}

final class SportViewController: UIViewController {
    
    private lazy var tableView: UITableView = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshPulled), for: .valueChanged)
        refreshControl.tintColor = UIColor.OS.Text.subtitle
        let tableView = UITableView.createTableView(.clear, dataSource: self)
        tableView.registerCell(SportFilterTableViewCell.self)
        tableView.registerCell(PlacementTableViewCell.self)
        tableView.registerCell(MatchTableViewCell.self)
        tableView.refreshControl = refreshControl
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.isScrollEnabled = true
        tableView.allowsMultipleSelection = false
        tableView.delegate = self
        tableView.delaysContentTouches = false
        return tableView
    }()
    
    weak var delegate: SportViewControllerDelegate?
    
    private let viewModel: SportViewModel
    private var subscribers: [AnyCancellable] = []
    private var showScoreboard: Bool = true
    
    init(viewModel: SportViewModel, delegate: SportViewControllerDelegate?) {
        self.viewModel = viewModel
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubscribers()
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
    
    private func scrollTableViewToTop(animated: Bool) {
        // scroll table view all the way to the top, taking
        // into consideration the custom content inset of the table
        tableView.scrollToTop(animated: animated)
    }
    
    private func setupChildViews() {
        NSLayoutConstraint.pinToView(view, tableView)
    }
    
    private func setupSubscribers() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [unowned self] state in
                switch state {
                case .scoreboardSuccess, .recentMatchesSuccess:
                    self.tableView.refreshControl?.endRefreshing()
                case .failure(let error):
                    self.tableView.refreshControl?.endRefreshing()
                    Coordinator.global.send(error)
                default:
                    // do nothing
                    break
                }
                self.tableView.reloadData()
            })
            .store(in: &subscribers)
    }
    
    private func configureUI() {
        view.backgroundColor = .clear
    }
    
    private func reloadDataWithAnimation() {
        UIView.transition(with: tableView,
                          duration: 0.35,
                          options: .transitionCrossDissolve,
                          animations: { [unowned self] in
            self.tableView.reloadData()
        }, completion: nil)
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
            cell.configure(with: viewModel.scoreboard[indexPath.row], viewModel.sport, indexPath.row, isFirstElement, isLastElement)
            return cell
        }
        let cell = tableView.dequeueReusableCell(for: MatchTableViewCell.self, for: indexPath)
        cell.applyCornerRadius(isFirstElement: isFirstElement, isLastElement: isLastElement)
        cell.match = viewModel.recentMatches[indexPath.row]
        return cell
    }
}

// MARK: - Scroll View Delegate

extension SportViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.tableViewDidScroll(scrollView.contentOffset)
    }
}

// MARK: - Table View Delegate

extension SportViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if showScoreboard {
            Coordinator.global.presentPlayerDetails(viewModel.scoreboard[indexPath.row], sport: viewModel.sport)
        }
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
