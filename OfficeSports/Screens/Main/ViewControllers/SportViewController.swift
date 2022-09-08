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
    
    func didFetchSportsData()
}

final class SportViewController: UIViewController {
    
    private lazy var tableView: UITableView = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshPulled), for: .valueChanged)
        refreshControl.tintColor = UIColor.OS.Text.subtitle
        let tableView = UITableView.createTableView(.clear, dataSource: self, style: .grouped)
        tableView.registerCell(SportFilterTableViewCell.self)
        tableView.registerCell(PlacementTableViewCell.self)
        tableView.registerCell(MatchTableViewCell.self)
        tableView.refreshControl = refreshControl
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.isScrollEnabled = true
        tableView.allowsMultipleSelection = false
        tableView.delegate = self
        tableView.delaysContentTouches = false
        tableView.sectionHeaderHeight = 8
        tableView.sectionFooterHeight = 8
        return tableView
    }()
    
    private lazy var feedbackGenerator: UIImpactFeedbackGenerator = {
        return UIImpactFeedbackGenerator(style: .medium)
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
        viewModel.fetchSportData()
    }
    
    func applyContentInsetToTableView(_ contentInset: UIEdgeInsets) {
        tableView.contentInset = contentInset
        scrollTableViewToTop(animated: false)
    }
    
    func reloadSportData() {
        viewModel.fetchSportData()
    }
    
    func scrollTableViewToTop(animated: Bool) {
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
                case .scoreboardSuccess:
                    self.tableView.refreshControl?.endRefreshing()
                    self.delegate?.didFetchSportsData()
                case .recentMatchesSuccess:
                    self.tableView.refreshControl?.endRefreshing()
                case .failure(let error):
                    self.tableView.refreshControl?.endRefreshing()
                    Coordinator.global.send(error)
                default:
                    // do nothing
                    break
                }
                self.reloadData(in: [1, 2])
            })
            .store(in: &subscribers)
    }
    
    private func configureUI() {
        view.backgroundColor = .clear
    }
    
    private func reloadData(in sections: [Int], animated: Bool = true) {
        if animated {
            self.tableView.reloadSections(IndexSet(sections), with: .fade)
        } else {
            tableView.reloadData()
        }
    }
    
    @objc private func refreshPulled(_ sender: UIRefreshControl) {
        viewModel.fetchSportData()
    }
}

// MARK: - Table View Data Source

extension SportViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            if showScoreboard {
                return viewModel.scoreboard.count
            }
            return viewModel.recentMatches.count
        default:
            return showScoreboard ? viewModel.idlePlayers.count : 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(for: SportFilterTableViewCell.self, for: indexPath)
            cell.configure(leftButtonTitle: "Scoreboard", rightButtonTitle: "Recent matches", delegate: self)
            cell.toggleLeftButton(enabled: showScoreboard)
            return cell
        }
        
        if indexPath.section == 1 {
            let isFirstElement = indexPath.row == 0
            let isLastElement = indexPath.row == (showScoreboard ? viewModel.scoreboard.count - 1 : viewModel.recentMatches.count - 1)
            
            if showScoreboard {
                let player = viewModel.scoreboard[indexPath.row]
                let isFanatic = player == viewModel.fanatic
                let isBoring = player == viewModel.boring
                let cell = tableView.dequeueReusableCell(for: PlacementTableViewCell.self, for: indexPath)
                
                cell.configure(with: player, viewModel.sport, indexPath.row, isFanatic, isBoring, isFirstElement, isLastElement)
                return cell
            }
            let cell = tableView.dequeueReusableCell(for: MatchTableViewCell.self, for: indexPath)
            cell.applyCornerRadius(isFirstElement: isFirstElement, isLastElement: isLastElement)
            cell.match = viewModel.recentMatches[indexPath.row]
            return cell
        }
        
        let player = viewModel.idlePlayers[indexPath.row]
        let cell = tableView.dequeueReusableCell(for: PlacementTableViewCell.self, for: indexPath)
        cell.configure(with: player, viewModel.sport, indexPath.row == 0, indexPath.row == viewModel.idlePlayers.count - 1)
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
        feedbackGenerator.impactOccurred()
        if showScoreboard {
            let player = indexPath.section == 1 ? viewModel.scoreboard[indexPath.row] : viewModel.idlePlayers[indexPath.row]
            Coordinator.global.presentPlayerDetails(player, sport: viewModel.sport)
        }
    }
}

// MARK: - Sport Filter Delegate

extension SportViewController: SportFilterDelegate {
    
    func leftButtonTapped() {
        showScoreboard = true
        reloadData(in: [1, 2])
    }
    
    func rightButtonTapped() {
        showScoreboard = false
        reloadData(in: [1, 2])
    }
}
