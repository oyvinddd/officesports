//
//  SeasonsViewModel.swift
//  OfficeSports
//
//  Created by Øyvind Hauge on 01/07/2022.
//

import Foundation
import Combine

final class SeasonsViewModel {
    
    enum State {
        case idle
        
        case loading
        
        case success([OSSeasonStats])
        
        case failure(Error)
    }
    
    @Published private(set) var state: State = .idle
    
    private(set) var seasons = [OSSeasonStats]()
    private let api: SportsAPI
    
    init(api: SportsAPI) {
        self.api = api
    }
    
    func fetchSeasonStats() {
        state = .loading
        
        Task {
            do {
                let stats = try await api.getSeasonStats()
                self.seasons = stats
                state = .success(stats)
            } catch let error {
                state = .failure(error)
            }
        }
    }
}
