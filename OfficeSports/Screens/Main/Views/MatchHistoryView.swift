//
//  MatchHistoryView.swift
//  OfficeSports
//
//  Created by Øyvind Hauge on 06/09/2022.
//

import UIKit

private let noMatchHistory = "No match history against yourself"

final class MatchHistoryView: UIView {
    
    private lazy var historyLabel: UILabel = {
        let label = UILabel.createLabel(UIColor.OS.Text.normal, alignment: .left)
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView.createStackView(.clear, axis: .horizontal)
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    private lazy var lineView: UIView = {
        return UIView.createView(UIColor.OS.Text.subtitle)
    }()
    
    private let matchViews = [
        MatchView(), MatchView(), MatchView(), MatchView(),
        MatchView(), MatchView(), MatchView()
    ]
    
    init(title: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setupChildViews()
        historyLabel.text = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupChildViews() {
        addSubview(historyLabel)
        addSubview(lineView)
        addSubview(stackView)
        
        for view in matchViews {
            stackView.addArrangedSubview(view)
        }
        
        NSLayoutConstraint.activate([
            historyLabel.leftAnchor.constraint(equalTo: leftAnchor),
            historyLabel.rightAnchor.constraint(equalTo: rightAnchor),
            historyLabel.topAnchor.constraint(equalTo: topAnchor),
            lineView.leftAnchor.constraint(equalTo: leftAnchor),
            lineView.rightAnchor.constraint(equalTo: rightAnchor),
            lineView.centerYAnchor.constraint(equalTo: stackView.centerYAnchor),
            lineView.heightAnchor.constraint(equalToConstant: 3),
            stackView.leftAnchor.constraint(equalTo: leftAnchor),
            stackView.rightAnchor.constraint(equalTo: rightAnchor),
            stackView.topAnchor.constraint(equalTo: historyLabel.bottomAnchor, constant: 20),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func updateHistoryView(results: [Bool?], animated: Bool = false) {
        var mutableResults: [Bool?] = results
        for matchView in matchViews {
            let status = mutableResults.popLast() ?? nil
            matchView.updateMatchStatus(didWin: status, animated: animated)
        }
    }
    
    func disable() {
        historyLabel.text = noMatchHistory
        
        for matchView in matchViews {
            matchView.updateMatchStatus(didWin: nil)
        }
    }
}

// MARK: - Match Circle View

let circleDiameter: CGFloat = 24
let circleRadius: CGFloat = circleDiameter / 2
let middleDiameter: CGFloat = 18
let middleRadius: CGFloat = middleDiameter / 2
let innerDiameter: CGFloat = 12
let innerRadius: CGFloat = innerDiameter / 2

private final class MatchView: UIView {
    
    private lazy var circleView: UIView = {
        return UIView.createView(UIColor.OS.Text.subtitle, cornerRadius: circleRadius)
    }()
    
    private lazy var middleView: UIView = {
        return UIView.createView(.white, cornerRadius: middleRadius)
    }()
    
    private lazy var innerView: UIView = {
        let view = UIView.createView(UIColor.OS.Status.success, cornerRadius: innerRadius)
        view.alpha = 0.8
        return view
    }()
    
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setupChildViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupChildViews() {
        NSLayoutConstraint.pinToView(self, circleView)
        NSLayoutConstraint.pinToView(circleView, middleView, padding: 3)
        NSLayoutConstraint.pinToView(middleView, innerView, padding: 3)
        
        NSLayoutConstraint.activate([
            circleView.widthAnchor.constraint(equalToConstant: circleDiameter),
            circleView.heightAnchor.constraint(equalTo: circleView.widthAnchor)
        ])
    }
    
    func updateMatchStatus(didWin: Bool?, animated: Bool = false) {
        guard let didWin = didWin else {
            innerView.isHidden = true
            return
        }
        if didWin {
            innerView.backgroundColor = UIColor.OS.Status.success
        } else {
            innerView.backgroundColor = UIColor.OS.Status.failure
        }
    }
}
