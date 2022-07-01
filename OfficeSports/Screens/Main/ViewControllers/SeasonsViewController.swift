//
//  SeasonsViewController.swift
//  OfficeSports
//
//  Created by Øyvind Hauge on 01/07/2022.
//

import UIKit

final class SeasonsViewController: UIViewController {
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView.createTableView(.clear)
        tableView.registerCell(SeasonTableViewCell.self)
        tableView.dataSource = self
        return tableView
    }()
    
    private let viewModel: SeasonsViewModel
    
    init(viewModel: SeasonsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupChildViews()
    }
    
    private func setupChildViews() {
        NSLayoutConstraint.pinToView(view, tableView)
    }
}

extension SeasonsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: SeasonTableViewCell.self, for: indexPath)
        
        return cell
    }
}

private final class SeasonTableViewCell: UITableViewCell {
    
    private lazy var contentWrap: UIView = {
        return UIView.createView(.white)
    }()
    
    private lazy var nicknameLabel: UILabel = {
        return UILabel.createLabel(UIColor.OS.Text.normal)
    }()
    
    var season: OSSeasonStats?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupChildViews()
        configureUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setupChildViews() {
        
    }
    
    private func configureUI() {
        
    }
}
