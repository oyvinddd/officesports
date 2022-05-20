//
//  ResultListViewModel.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 10/05/2022.
//

import Foundation

protocol SportViewModelDelegate: AnyObject {
    
    func fetchedScoreboardSuccessfully()
    
    func didFetchScoreboard(with error: Error)
    
    func fetchedRecentMatchesSuccessfully()
    
    func didFetchRecentMatches(with error: Error)
    
    func shouldToggleLoading(enabled: Bool)
}

final class SportViewModel {
    
    var scoreboard = [OSPlayer]()
    var recentMatches = [OSMatch]()
    
    weak var delegate: SportViewModelDelegate?
    
    private let api: SportsAPI
    private let sport: OSSport
    
    init(api: SportsAPI, sport: OSSport) {
        self.api = api
        self.sport = sport
    }
    
    func fetchScoreboard() {
        delegate?.shouldToggleLoading(enabled: true)
        api.getScoreboard(sport: sport) { [unowned self] (scoreboard, error) in
            self.delegate?.shouldToggleLoading(enabled: false)
            if let error = error {
                self.delegate?.didFetchScoreboard(with: error)
            } else {
                self.scoreboard = scoreboard
                self.delegate?.fetchedScoreboardSuccessfully()
            }
        }
    }
    
    func fetchRecentMatches() {
        delegate?.shouldToggleLoading(enabled: true)
        api.getMatchHistory(sport: sport) { [unowned self] (matchHistory, error) in
            self.delegate?.shouldToggleLoading(enabled: false)
            if let error = error {
                self.delegate?.didFetchRecentMatches(with: error)
            } else {
                self.recentMatches = matchHistory
                self.delegate?.fetchedRecentMatchesSuccessfully()
            }
        }
    }
}
