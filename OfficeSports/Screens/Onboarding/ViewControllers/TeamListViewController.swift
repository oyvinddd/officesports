//
//  TeamPickerViewController.swift
//  OfficeSports
//
//  Created by Øyvind Hauge on 12/07/2022.
//

import UIKit
import Combine

private let imageDiameter: CGFloat = 128
private let imageRadius: CGFloat = imageDiameter / 2

final class TeamListViewController: UIViewController {
    
    private lazy var closeButton: UIButton = {
        let image = UIImage(systemName: "xmark", withConfiguration: nil)
        let button = UIButton.createButton(.white, tintColor: UIColor.OS.General.main, image: image)
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        button.backgroundColor = .white
        button.applyCornerRadius(20)
        button.alpha = 0.7
        return button
    }()
    
    private lazy var imageWrap: UIView = {
        let imageWrap = UIView.createView(.white, cornerRadius: imageRadius)
        imageWrap.applyMediumDropShadow(.black)
        return imageWrap
    }()
    
    private lazy var imageBackground: UIView = {
        let profileImageBackground = UIView.createView(UIColor.OS.Profile.color18)
        profileImageBackground.applyCornerRadius((imageDiameter - 16) / 2)
        return profileImageBackground
    }()
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel.createLabel(.black, alignment: .center, text: "💼")
        label.font = UIFont.systemFont(ofSize: 68, weight: .medium)
        return label
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel.createLabel(.white, alignment: .center, text: "Join a team")
        label.font = UIFont.boldSystemFont(ofSize: 32)
        return label
    }()
    
    private lazy var informationLabel: UILabel = {
        let label = UILabel.createLabel(.white, alignment: .center, text: "When you join a team you will only see members of the same team on the scoreboard.")
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
        return UIView.createView(UIColor.OS.General.main)
    }()
    
    private let viewModel: TeamsViewModel
    private var subscribers = Set<AnyCancellable>()
    private var currentTeamId: String? = OSAccount.current.player?.teamId
    
    init(viewModel: TeamsViewModel) {
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
        view.addSubview(closeButton)
        view.addSubview(imageWrap)
        imageWrap.addSubview(imageBackground)
        view.addSubview(titleLabel)
        view.addSubview(informationLabel)
        view.addSubview(tableView)
        view.addSubview(bottomWrap)
        
        NSLayoutConstraint.pinToView(imageBackground, emojiLabel)
        
        NSLayoutConstraint.activate([
            closeButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalTo: closeButton.widthAnchor),
            imageWrap.widthAnchor.constraint(equalToConstant: imageDiameter),
            imageWrap.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            imageWrap.heightAnchor.constraint(equalTo: imageWrap.widthAnchor),
            imageWrap.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageBackground.leftAnchor.constraint(equalTo: imageWrap.leftAnchor, constant: 8),
            imageBackground.rightAnchor.constraint(equalTo: imageWrap.rightAnchor, constant: -8),
            imageBackground.topAnchor.constraint(equalTo: imageWrap.topAnchor, constant: 8),
            imageBackground.bottomAnchor.constraint(equalTo: imageWrap.bottomAnchor, constant: -8),
            titleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            titleLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: imageWrap.bottomAnchor, constant: 16),
            informationLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            informationLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            informationLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            informationLabel.bottomAnchor.constraint(equalTo: tableView.topAnchor, constant: -32),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func configureUI() {
        view.backgroundColor = UIColor.OS.General.main
    }
    
    @objc private func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

// MARK: - Table View Data Source

extension TeamListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.teams.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: TeamTableViewCell.self, for: indexPath)
        let team = viewModel.teams[indexPath.row]
        let firstElement = indexPath.row == 0
        let lastElement = indexPath.row == viewModel.teams.count - 1
        let isPartOfTeam = currentTeamId == team.id
        cell.configure(with: team, enabled: isPartOfTeam, isFirstElement: firstElement, isLastElement: lastElement)
        return cell
    }
}

// MARK: - Table View Delegate

extension TeamListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let team = viewModel.teams[indexPath.row]
        let selectedCell = tableView.cellForRow(at: indexPath) as? TeamTableViewCell
        for cell in tableView.visibleCells {
            (cell as? TeamTableViewCell)?.toggle(false)
        }
        selectedCell?.toggle(true)
        presentJoinTeamViewController(team: team)
    }
    
    private func presentJoinTeamViewController(team: OSTeam) {
        let viewModel = JoinTeamViewModel(api: FirebaseSportsAPI())
        let viewController = JoinTeamViewController(viewModel: viewModel, team: team)
        present(viewController, animated: false)
    }
}

// MARK: - Team Table View Cell

private final class TeamTableViewCell: UITableViewCell {
    
    private lazy var contentWrap: UIView = {
        return UIView.createView(.white)
    }()
    
    private lazy var teamLabel: UILabel = {
        let label = UILabel.createLabel(UIColor.OS.Text.normal)
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()
    
    private lazy var radioButton: RadioButton = {
        return RadioButton(enabled: false)
    }()
    
    private lazy var separator: UIView = {
        return UIView.createView(UIColor.OS.General.separator)
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupChildViews()
        configureUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configure(with team: OSTeam, enabled: Bool, isFirstElement: Bool, isLastElement: Bool) {
        applyCornerRadius(isFirstElement: isFirstElement, isLastElement: isLastElement)
        separator.isHidden = isLastElement
        teamLabel.text = team.name
        toggle(enabled)
    }
    
    func toggle(_ enabled: Bool) {
        radioButton.toggle(enabled: enabled)
    }
    
    private func setupChildViews() {
        contentView.addSubview(contentWrap)
        contentWrap.addSubview(teamLabel)
        contentWrap.addSubview(radioButton)
        contentWrap.addSubview(separator)
        
        NSLayoutConstraint.activate([
            contentWrap.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
            contentWrap.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16),
            contentWrap.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentWrap.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            teamLabel.leftAnchor.constraint(equalTo: contentWrap.leftAnchor, constant: 16),
            teamLabel.rightAnchor.constraint(equalTo: contentWrap.rightAnchor, constant: -16),
            teamLabel.topAnchor.constraint(equalTo: contentWrap.topAnchor, constant: 24),
            teamLabel.bottomAnchor.constraint(equalTo: contentWrap.bottomAnchor, constant: -24),
            radioButton.centerYAnchor.constraint(equalTo: contentWrap.centerYAnchor),
            radioButton.rightAnchor.constraint(equalTo: contentWrap.rightAnchor, constant: -16),
            radioButton.heightAnchor.constraint(equalToConstant: 20),
            radioButton.widthAnchor.constraint(equalTo: radioButton.heightAnchor),
            separator.leftAnchor.constraint(equalTo: contentWrap.leftAnchor),
            separator.rightAnchor.constraint(equalTo: contentWrap.rightAnchor),
            separator.bottomAnchor.constraint(equalTo: contentWrap.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    private func configureUI() {
        backgroundColor = .clear
        selectionStyle = .none
    }
    
    private func applyCornerRadius(isFirstElement: Bool, isLastElement: Bool) {
        guard isFirstElement || isLastElement else {
            contentWrap.layer.maskedCorners = []
            return
        }
        var mask = CACornerMask()
        
        if isFirstElement {
            mask.insert(.layerMinXMinYCorner)
            mask.insert(.layerMaxXMinYCorner)
        } else {
            mask.insert(.layerMinXMaxYCorner)
            mask.insert(.layerMaxXMaxYCorner)
        }
        contentWrap.layer.cornerRadius = 15
        contentWrap.layer.maskedCorners = mask
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
            backgroundColor = UIColor.OS.General.main
            innerView.backgroundColor = .white
        }
    }
    
    private func setupChildViews() {
        NSLayoutConstraint.pinToView(self, separatorView, padding: 3)
        NSLayoutConstraint.pinToView(separatorView, innerView, padding: 3)
    }
}
