//
//  SeasonsViewController.swift
//  OfficeSports
//
//  Created by Øyvind Hauge on 01/07/2022.
//

import UIKit
import Combine

private let imageDiameter: CGFloat = 128
private let imageRadius: CGFloat = imageDiameter / 2

final class SeasonsViewController: UIViewController, SeasonsHeaderDelegate {

    private lazy var seasonsHeader: UIView = {
        return SeasonsHeader(delegate: self)
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView.createTableView(.clear, style: .grouped)
        tableView.registerCell(SportFilterTableViewCell.self)
        tableView.registerCell(SeasonResultTableViewCell.self)
        tableView.sectionHeaderHeight = 8
        tableView.sectionFooterHeight = 8
        tableView.dataSource = self
        return tableView
    }()
    
    private let viewModel: SeasonsViewModel
    private var subscribers: [AnyCancellable] = []
    private let confettiView = ConfettiView(intensity: 0.3)
    private var currentSport: OSSport = .tableTennis
    
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
        view.addSubview(seasonsHeader)
        view.addSubview(tableView)
        
        NSLayoutConstraint.pinToView(view, confettiView)
        
        NSLayoutConstraint.activate([
            seasonsHeader.leftAnchor.constraint(equalTo: view.leftAnchor),
            seasonsHeader.rightAnchor.constraint(equalTo: view.rightAnchor),
            seasonsHeader.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.topAnchor.constraint(equalTo: seasonsHeader.bottomAnchor, constant: 8),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func configureUI() {
        view.backgroundColor = UIColor.OS.General.main
    }
    
    private func reloadData(animated: Bool = true) {
        if animated {
            self.tableView.reloadSections(IndexSet(integer: 1), with: .fade)
        } else {
            tableView.reloadData()
        }
    }
    
    func closeButtonTapped() {
        confettiView.stop()
        dismiss(animated: true)
    }
}

// MARK: - Table View Data Source

extension SeasonsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : viewModel.seasons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(for: SportFilterTableViewCell.self, for: indexPath)
            cell.configure(leftButtonTitle: "Table Tennis", rightButtonTitle: "Foosball")
            cell.toggleLeftButton(enabled: currentSport == .tableTennis)
            cell.isUserInteractionEnabled = false // TODO: remove this whenever foosball filter has been implemented
            return cell
        }
        let cell = tableView.dequeueReusableCell(for: SeasonResultTableViewCell.self, for: indexPath)
        
        let isFirst = indexPath.row == 0
        let isLast = indexPath.row == viewModel.seasons.count - 1
        
        cell.configure(with: viewModel.seasons[indexPath.row], isFirst, isLast)
        return cell
    }
}

// MARK: - Seasons Header

protocol SeasonsHeaderDelegate: AnyObject {
    
    func closeButtonTapped()
}

private final class SeasonsHeader: UIView {
    
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
        let profileImageBackground = UIView.createView(UIColor.OS.Profile.color1)
        profileImageBackground.applyCornerRadius((imageDiameter - 16) / 2)
        return profileImageBackground
    }()
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel.createLabel(.black, alignment: .center, text: "🏆")
        label.font = UIFont.systemFont(ofSize: 68, weight: .medium)
        return label
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel.createLabel(.white, alignment: .center, text: "Season results!")
        label.font = UIFont.boldSystemFont(ofSize: 26)
        return label
    }()
    
    private lazy var informationLabel: UILabel = {
        let label = UILabel.createLabel(.white, alignment: .center, text: "Whoever has the most points at the end of a given month is considered the winner of that season. Good luck! 🤩")
        label.font = UIFont.systemFont(ofSize: 18)
        label.alpha = 0.9
        return label
    }()
    
    weak var delegate: SeasonsHeaderDelegate?
    
    init(delegate: SeasonsHeaderDelegate?) {
        self.delegate = delegate
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setupChildViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupChildViews() {
        addSubview(closeButton)
        addSubview(imageWrap)
        addSubview(titleLabel)
        addSubview(informationLabel)
        imageWrap.addSubview(imageBackground)
        
        NSLayoutConstraint.pinToView(imageBackground, emojiLabel)
        
        NSLayoutConstraint.activate([
            closeButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -20),
            closeButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalTo: closeButton.widthAnchor),
            imageWrap.widthAnchor.constraint(equalToConstant: imageDiameter),
            imageWrap.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 50),
            imageWrap.heightAnchor.constraint(equalTo: imageWrap.widthAnchor),
            imageWrap.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageBackground.leftAnchor.constraint(equalTo: imageWrap.leftAnchor, constant: 8),
            imageBackground.rightAnchor.constraint(equalTo: imageWrap.rightAnchor, constant: -8),
            imageBackground.topAnchor.constraint(equalTo: imageWrap.topAnchor, constant: 8),
            imageBackground.bottomAnchor.constraint(equalTo: imageWrap.bottomAnchor, constant: -8),
            titleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
            titleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: imageWrap.bottomAnchor, constant: 16),
            informationLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
            informationLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -16),
            informationLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            informationLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -32)
        ])
    }
    
    @objc private func closeButtonTapped(_ sender: UIButton) {
        delegate?.closeButtonTapped()
    }
}
