//
//  TeamPickerViewController2.swift
//  OfficeSports
//
//  Created by Øyvind Hauge on 12/07/2022.
//

import UIKit

final class TeamPickerViewController2: UIViewController {
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView.createTableView(.clear, dataSource: self)
        tableView.registerCell(TeamTableViewCell.self)
        return tableView
    }()
    
    private lazy var bottomWrap: UIView = {
        return UIView.createView(.white)
    }()
    
    private lazy var selectButton: OSButton = {
        let button = OSButton("Select", type: .primaryInverted)
        return button
    }()
    
    private let viewModel: TeamsViewModel
    
    init(viewModel: TeamsViewModel) {
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchTeams()
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
            selectButton.bottomAnchor.constraint(equalTo: bottomWrap.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            selectButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func configureUI() {
        view.backgroundColor = .white
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
