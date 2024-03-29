//
//  MyInvitesViewController.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 19/05/2022.
//

import UIKit
import Combine

final class MyInvitesViewController: UIViewController {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel.createLabel(.white, text: "My Invitations")
        label.font = UIFont.boldSystemFont(ofSize: 32)
        return label
    }()
    
    private lazy var closeButton: UIButton = {
        let image = UIImage(systemName: "xmark", withConfiguration: nil)
        let button = UIButton.createButton(.white, tintColor: UIColor.OS.General.main, image: image)
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        button.backgroundColor = .white
        button.applyCornerRadius(20)
        button.alpha = 0.7
        return button
    }()
    
    private lazy var emptyContentLabel: UILabel = {
        let message = "Your match invitations will show up here"
        let label = UILabel.createLabel(UIColor.OS.Text.disabled, alignment: .center, text: message)
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView.createTableView(.clear, dataSource: self)
        tableView.registerCell(InviteFilterTableViewCell.self)
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
        viewModel.getActiveInvites()
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
        view.addSubview(titleLabel)
        view.addSubview(closeButton)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            titleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            closeButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalTo: closeButton.widthAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 32),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        NSLayoutConstraint.pinToView(view, emptyContentLabel, padding: 32)
    }
    
    private func configureUI() {
        view.backgroundColor = UIColor.OS.General.main
    }
    
    @objc private func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

// MARK: - Table View Data Source

extension MyInvitesViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : viewModel.invites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(for: InviteFilterTableViewCell.self, for: indexPath)
            cell.delegate = self
            return cell
        }
        let cell = tableView.dequeueReusableCell(for: InviteTableViewCell.self, for: indexPath)
        let isLast = indexPath.row == viewModel.invites.count - 1
        cell.configure(with: viewModel.invites[indexPath.row], isLast)
        return cell
    }
}

// MARK: - Invite Filter Delegate Conformance

extension MyInvitesViewController: InviteFilterDelegate {
    
    func leftButtonTapped() {
        
    }
    
    func rightButtonTapped() {
        
    }
}
