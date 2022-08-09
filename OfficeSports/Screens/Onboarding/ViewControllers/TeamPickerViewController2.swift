//
//  TeamPickerViewController2.swift
//  OfficeSports
//
//  Created by Øyvind Hauge on 12/07/2022.
//

import UIKit
import Combine

protocol TeamSelectionDelegate: AnyObject {
    
    func didSelectTeam(_ team: OSTeam)
}

final class TeamPickerViewController2: UIViewController {
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView.createTableView(.clear, dataSource: self)
        tableView.registerCell(TeamTableViewCell.self)
        tableView.delegate = self
        return tableView
    }()
    
    private lazy var bottomWrap: UIView = {
        return UIView.createView(.yellow)
    }()
    
    private lazy var selectButton: OSButton = {
        let button = OSButton("Select", type: .primaryInverted, state: .disabled)
        button.addTarget(self, action: #selector(selectButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let viewModel: TeamsViewModel
    private var subscribers = Set<AnyCancellable>()
    private var selectedTeam: OSTeam?
    
    weak var delegate: TeamSelectionDelegate?
    
    init(viewModel: TeamsViewModel, delegate: TeamSelectionDelegate?) {
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
        viewModel.fetchTeams()
    }
    
    private func setupSubscribers() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] state in
                switch state {
                case .loading, .idle:
                    break
                case .success:
                    self.tableView.reloadData()
                case .failure(let error):
                    Coordinator.global.send(error)
                }
            }.store(in: &subscribers)
    }
    
    private func setupChildViews() {
        view.addSubview(tableView)
        view.addSubview(bottomWrap)
        bottomWrap.addSubview(selectButton)
        
        NSLayoutConstraint.activate([
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            bottomWrap.leftAnchor.constraint(equalTo: view.leftAnchor),
            bottomWrap.rightAnchor.constraint(equalTo: view.rightAnchor),
            bottomWrap.topAnchor.constraint(equalTo: tableView.bottomAnchor),
            bottomWrap.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            selectButton.leftAnchor.constraint(equalTo: bottomWrap.leftAnchor, constant: 16),
            selectButton.rightAnchor.constraint(equalTo: bottomWrap.rightAnchor, constant: -16),
            selectButton.topAnchor.constraint(equalTo: bottomWrap.topAnchor, constant: 16),
            selectButton.bottomAnchor.constraint(equalTo: bottomWrap.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            selectButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func configureUI() {
        view.backgroundColor = .white
    }
    
    @objc private func selectButtonTapped(sender: UIButton) {
        dismiss(animated: true)
        //delegate?.didSelectTeam(<#T##team: OSTeam##OSTeam#>)
    }
}

// MARK: - Table View Data Source

extension TeamPickerViewController2: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.teams.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: TeamTableViewCell.self, for: indexPath)
        cell.configure(with: viewModel.teams[indexPath.row])
        return cell
    }
}

// MARK: - Table View Delegate

extension TeamPickerViewController2: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}

// MARK: - Team Table View Cell

private final class TeamTableViewCell: UITableViewCell {
    
    private lazy var teamLabel: UILabel = {
        return UILabel.createLabel(UIColor.OS.Text.normal)
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupChildViews()
        configureUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configure(with team: OSTeam) {
        teamLabel.text = team.name
    }
    
    private func setupChildViews() {
        contentView.addSubview(teamLabel)
        
        NSLayoutConstraint.activate([
            teamLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
            teamLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16),
            teamLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            teamLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    private func configureUI() {
        backgroundColor = .clear
        selectionStyle = .none
    }
}
