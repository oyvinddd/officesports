//
//  ResultListViewModel.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 10/05/2022.
//

import Foundation

protocol ScoreboardViewModelDelegate: AnyObject {
    func fetchedScoreboardSuccessfully(_ scoreboard: [OSPlayer])
    
    func didFetchScoreboard(with error: Error)
}

final class ScoreboardViewModel {
    
    weak var delegate: ScoreboardViewModelDelegate?
    
    var scoreboard: [OSPlayer] = []
    var recentMatches: [OSMatchResult] = []
    
    private var api: SportsAPI
    private var sport: OSSport
    
    init(api: SportsAPI, sport: OSSport) {
        self.api = api
        self.sport = sport
    }
    
    func fetchScoreboard() {
        api.getScoreboard(sport: sport) { [weak self] (players, error) in
            if let error = error {
                self?.delegate?.didFetchScoreboard(with: error)
            } else {
                self?.delegate?.fetchedScoreboardSuccessfully(players)
            }
        }
    }
    
    func fetchRecentMatches() {
        
    }
}
