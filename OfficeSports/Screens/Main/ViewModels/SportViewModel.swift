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
    
    @Published var scoreboard = [OSPlayer]()
    @Published var showLoading = false
    
    var recentMatches = [OSMatch]()
    let sport: OSSport
    
    weak var delegate: SportViewModelDelegate?
    
    private let api: SportsAPI
    
    init(api: SportsAPI, sport: OSSport) {
        self.api = api
        self.sport = sport
    }
    
    func fetchScoreboard() {
        Task {
            do {
                scoreboard = try await api.getScoreboard(sport: sport)
            } catch let error {
                print(error)
            }
        }
        /*
        delegate?.shouldToggleLoading(enabled: true)
        api.getScoreboard(sport: sport) { [unowned self] result in
            self.delegate?.shouldToggleLoading(enabled: false)
            if let error = error {
                self.delegate?.didFetchScoreboard(with: error)
            } else {
                self.scoreboard = scoreboard
                self.delegate?.fetchedScoreboardSuccessfully()
            }
        }
        */
    }
    
    func fetchRecentMatches() {
        Task {
            do {
                recentMatches = try await api.getMatchHistory(sport: sport)
            } catch let error {
                print(error)
            }
        }
        /*
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
         */
    }
}
