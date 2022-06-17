//
//  MyInvitesViewController.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 19/05/2022.
//

import UIKit
import Combine

final class MyInvitesViewController: UIViewController {
    
    private lazy var emptyContentLabel: UILabel = {
        let message = "Your match invitations will show up here"
        let label = UILabel.createLabel(UIColor.OS.Text.disabled, alignment: .center, text: message)
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView.createTableView(.clear, dataSource: self)
        tableView.registerCell(InviteTableViewCell.self)
        return tableView
    }()
    
    private let viewModel: MyInvitesViewModel
    private var subscribers = Set<AnyCancellable>()
    
    init(viewModel: MyInvitesViewModel) {
        self.viewModel = viewModel
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //viewModel.getActiveInvites()
    }
    
    func applyContentInsetToTableView(_ contentInset: UIEdgeInsets) {
        tableView.contentInset = contentInset
        scrollTableViewToTop(animated: false)
    }
    
    private func scrollTableViewToTop(animated: Bool) {
        // scroll table view all the way to the top, taking
        // into consideration the custom content inset of the table
//        tableView.scrollToTop(animated: animated)
    }
    
    private func setupSubscribers() {
        viewModel.$state.receive(on: DispatchQueue.main).sink { [unowned self] state in
            switch state {
            case .success:
                self.tableView.refreshControl?.endRefreshing()
                if !viewModel.invites.isEmpty {
                    self.emptyContentLabel.isHidden = true
                } else {
                    self.emptyContentLabel.isHidden = false
                }
            case .failure(let error):
                self.tableView.refreshControl?.endRefreshing()
                Coordinator.global.send(error)
            case .loading, .idle:
                break
            }
            self.tableView.reloadData()
        }.store(in: &subscribers)
    }
    
    private func setupChildViews() {
        NSLayoutConstraint.pinToView(view, tableView)
        NSLayoutConstraint.pinToView(view, emptyContentLabel, padding: 32)
    }
    
    private func configureUI() {
        view.backgroundColor = .clear
    }
}

// MARK: - Table View Data Source

extension MyInvitesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.invites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: InviteTableViewCell.self, for: indexPath)
        let isFirst = indexPath.row == 0
        let isLast = indexPath.row == viewModel.invites.count - 1
        cell.configure(with: viewModel.invites[indexPath.row], isFirst, isLast)
        return cell
    }
}
