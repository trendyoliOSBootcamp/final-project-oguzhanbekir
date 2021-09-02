//
//  GameListInteractor.swift
//  GameListApp
//
//  Created by Oguzhan Bekir on 3.06.2021.
//

import Foundation
import CoreApi

protocol GameListInteractorInterface {
    func fetchGameListData(_ endpoint : HomeEndpointItem)
    func fetchFilterListData()
    
}

protocol GameListInteractorOutput: AnyObject {
    func handleGameListResult(_ result: GameListResult)
    func handleFilterListResult(_ result: FilterResult)
}

typealias GameListResult = Result<GameListResponse, APIClientError>
typealias FilterResult = Result<Filter, APIClientError>

final class GameListInteractor {
    private let networkManager: NetworkManager<HomeEndpointItem>
    weak var output: GameListInteractorOutput?
    
    init(networkManager: NetworkManager<HomeEndpointItem> = NetworkManager()) {
        self.networkManager = networkManager
    }
}

extension GameListInteractor: GameListInteractorInterface {
    func fetchFilterListData() {
        networkManager.request(endpoint: .filterList, type: Filter.self) { [weak self] result in
            self?.output?.handleFilterListResult(result)
        }
    }
    
    func fetchGameListData(_ endpoint: HomeEndpointItem) {
         networkManager.request(endpoint: endpoint, type: GameListResponse.self) { [weak self] result in
            self?.output?.handleGameListResult(result)
         }
    }  
}
