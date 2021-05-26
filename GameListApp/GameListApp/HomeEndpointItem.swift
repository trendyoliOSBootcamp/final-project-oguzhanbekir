//
//  HomeEndpointItem.swift
//  GameListApp
//
//  Created by Oguzhan Bekir on 23.05.2021.
//

import Foundation
import CoreApi

enum HomeEndpointItem: Endpoint {
    case nextPage(query: String)
    case gamesList
    case filterList
    case filterItem(query: String)
    case gameDetail(query: String)
    
    var baseUrl: String { "https://api.rawg.io/api/" }
    var path: String {
        switch self {
        case .nextPage(let query): return "games?\(query)"
        case .gamesList: return "games?key=f7bda52777bd4e4cabb8386fbed8084e"
        case .filterList: return "platforms/lists/parents?key=f7bda52777bd4e4cabb8386fbed8084e"
        case .filterItem(let query): return "games?key=f7bda52777bd4e4cabb8386fbed8084e\(query)"
        case .gameDetail(let query): return "games/\(query)?key=f7bda52777bd4e4cabb8386fbed8084e"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .nextPage: return .get
        case .gamesList: return .get
        case .filterList: return .get
        case .filterItem: return .get
        case .gameDetail: return .get
        }
    }
}
