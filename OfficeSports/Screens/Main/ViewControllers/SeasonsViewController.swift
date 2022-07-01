//
//  SeasonsViewController.swift
//  OfficeSports
//
//  Created by Øyvind Hauge on 01/07/2022.
//

import UIKit
import Combine

final class SeasonsViewController: UIViewController {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel.createLabel(.white, text: "Season results")
        label.font = UIFont.boldSystemFont(ofSize: 26)
        return label
    }()
    
    private lazy var closeButton: UIButton = {
        let image = UIImage(systemName: "xmark", withConfiguration: nil)
        let button = UIButton.createButton(UIColor.OS.Text.disabled, tintColor: .white, image: image)
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        button.backgroundColor = UIColor.OS.Text.disabled
        button.applyCornerRadius(16)
        button.alpha = 0.7
        return button
    }()
    
    private lazy var comingSoonLabel: UILabel = {
        let message = "This feature is coming soon"
        let label = UILabel.createLabel(.white, alignment: .center, text: message)
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.alpha = 0.5
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView.createTableView(.clear)
        tableView.registerCell(SeasonResultTableViewCell.self)
        tableView.dataSource = self
        return tableView
    }()
    
    private let viewModel: SeasonsViewModel
    private var subscribers: [AnyCancellable] = []
    private let confettiView = ConfettiView(intensity: 0.5)
    
    init(viewModel: SeasonsViewModel) {
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchSeasonStats()
        confettiView.start()
    }
    
    private func setupSubscribers() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [unowned self] state in
                switch state {
                case .success:
                    self.tableView.refreshControl?.endRefreshing()
                case .failure(let error):
                    self.tableView.refreshControl?.endRefreshing()
                    Coordinator.global.send(error)
                default:
                    // do nothing
                    break
                }
                self.reloadData()
            })
            .store(in: &subscribers)
    }
    
    private func setupChildViews() {
        view.addSubview(titleLabel)
        view.addSubview(closeButton)
        
        NSLayoutConstraint.pinToView(view, tableView)
        NSLayoutConstraint.pinToView(view, comingSoonLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            closeButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            closeButton.widthAnchor.constraint(equalToConstant: 32),
            closeButton.heightAnchor.constraint(equalTo: closeButton.widthAnchor)
        ])
    }
    
    private func configureUI() {
        view.backgroundColor = UIColor.OS.General.main
    }
    
    private func reloadData(animated: Bool = true) {
        if animated {
            self.tableView.reloadSections(IndexSet(integer: 0), with: .fade)
        } else {
            tableView.reloadData()
        }
    }
    
    @objc private func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

// MARK: - Table View Data Source

extension SeasonsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.seasons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: SeasonResultTableViewCell.self, for: indexPath)
        cell.season = viewModel.seasons[indexPath.row]
        return cell
    }
}
