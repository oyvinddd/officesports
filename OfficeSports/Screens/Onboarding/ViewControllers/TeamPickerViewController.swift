//
//  TeamPickerViewController.swift
//  OfficeSports
//
//  Created by Øyvind Hauge on 12/07/2022.
//

import UIKit
import Combine

protocol TeamSelectionDelegate: AnyObject {
    
    func didSelectTeam(_ team: OSTeam)
}

final class TeamPickerViewController: UIViewController {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel.createLabel(UIColor.OS.Text.normal, alignment: .center, text: "Join a team! 🌈")
        label.font = UIFont.boldSystemFont(ofSize: 32)
        return label
    }()
    
    private lazy var informationLabel: UILabel = {
        let label = UILabel.createLabel(UIColor.OS.Text.normal, alignment: .center, text: "If you join a team you will only see members of the same team on the scoreboard.")
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView.createTableView(.clear, dataSource: self)
        tableView.registerCell(TeamTableViewCell.self)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 50
        tableView.delegate = self
        return tableView
    }()
    
    private lazy var bottomWrap: UIView = {
        return UIView.createView(.white)
    }()
    
    private lazy var selectButton: OSButton = {
        let button = OSButton("Select", type: .primaryInverted, state: .disabled)
        button.addTarget(self, action: #selector(selectButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var closeButton: OSButton = {
        let button = OSButton("Close", type: .secondaryInverted, state: .normal)
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let viewModel: TeamsViewModel
    private var subscribers = Set<AnyCancellable>()
    private var currentTeam: OSTeam? = OSAccount.current.player?.team ?? OSTeam.noTeam
    
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
        view.addSubview(titleLabel)
        view.addSubview(informationLabel)
        view.addSubview(tableView)
        view.addSubview(bottomWrap)
        bottomWrap.addSubview(selectButton)
        bottomWrap.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            titleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            titleLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 64),
            informationLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            informationLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            informationLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            informationLabel.bottomAnchor.constraint(equalTo: tableView.topAnchor, constant: -32),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            bottomWrap.leftAnchor.constraint(equalTo: view.leftAnchor),
            bottomWrap.rightAnchor.constraint(equalTo: view.rightAnchor),
            bottomWrap.topAnchor.constraint(equalTo: tableView.bottomAnchor),
            bottomWrap.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            selectButton.leftAnchor.constraint(equalTo: bottomWrap.leftAnchor, constant: 16),
            selectButton.rightAnchor.constraint(equalTo: bottomWrap.rightAnchor, constant: -16),
            selectButton.topAnchor.constraint(equalTo: bottomWrap.topAnchor, constant: 32),
            selectButton.bottomAnchor.constraint(equalTo: closeButton.topAnchor, constant: -16),
            selectButton.heightAnchor.constraint(equalToConstant: 50),
            closeButton.leftAnchor.constraint(equalTo: bottomWrap.leftAnchor, constant: 16),
            closeButton.rightAnchor.constraint(equalTo: bottomWrap.rightAnchor, constant: -16),
            closeButton.bottomAnchor.constraint(equalTo: bottomWrap.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            closeButton.heightAnchor.constraint(equalTo: selectButton.heightAnchor)
        ])
    }
    
    private func configureUI() {
        view.backgroundColor = .white
    }
    
    @objc private func selectButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
        if let team = currentTeam {
            delegate?.didSelectTeam(team)
        }
    }
    
    @objc private func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

// MARK: - Table View Data Source

extension TeamPickerViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.teams.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: TeamTableViewCell.self, for: indexPath)
        let team = viewModel.teams[indexPath.row]
        cell.configure(with: team, enabled: team == currentTeam)
        return cell
    }
}

// MARK: - Table View Delegate

extension TeamPickerViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentTeam = viewModel.teams[indexPath.row]
        let selectedCell = tableView.cellForRow(at: indexPath) as? TeamTableViewCell
        for cell in tableView.visibleCells {
            (cell as? TeamTableViewCell)?.toggle(false)
        }
        selectedCell?.toggle(true)
        selectButton.buttonState = .normal
    }
}

// MARK: - Team Table View Cell

private final class TeamTableViewCell: UITableViewCell {
    
    private lazy var teamLabel: UILabel = {
        let label = UILabel.createLabel(UIColor.OS.Text.normal)
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()
    
    private lazy var radioButton: RadioButton = {
        return RadioButton(enabled: false)
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupChildViews()
        configureUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configure(with team: OSTeam, enabled: Bool) {
        teamLabel.text = team.name
        toggle(enabled)
    }
    
    func toggle(_ enabled: Bool) {
        radioButton.toggle(enabled: enabled)
    }
    
    private func setupChildViews() {
        contentView.addSubview(teamLabel)
        contentView.addSubview(radioButton)
        
        NSLayoutConstraint.activate([
            teamLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
            teamLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16),
            teamLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            teamLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            radioButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            radioButton.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16),
            radioButton.heightAnchor.constraint(equalToConstant: 20),
            radioButton.widthAnchor.constraint(equalTo: radioButton.heightAnchor)
        ])
    }
    
    private func configureUI() {
        backgroundColor = .clear
        selectionStyle = .none
    }
}

private final class RadioButton: UIView {
    
    private lazy var separatorView: UIView = {
        let view = UIView.createView(.white)
        view.applyCornerRadius(7)
        return view
    }()
    
    private lazy var innerView: UIView = {
        let view = UIView.createView(.white)
        view.applyCornerRadius(4)
        return view
    }()
    
    init(enabled: Bool) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setupChildViews()
        applyCornerRadius(10)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func toggle(enabled: Bool) {
        if enabled {
            backgroundColor = UIColor.OS.General.main
            innerView.backgroundColor = UIColor.OS.General.main
        } else {
            backgroundColor = UIColor.OS.Text.disabled
            innerView.backgroundColor = .white
        }
    }
    
    private func setupChildViews() {
        NSLayoutConstraint.pinToView(self, separatorView, padding: 3)
        NSLayoutConstraint.pinToView(separatorView, innerView, padding: 3)
    }
}
