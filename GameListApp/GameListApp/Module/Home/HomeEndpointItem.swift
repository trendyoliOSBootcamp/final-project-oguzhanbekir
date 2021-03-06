//
//  HomeEndpointItem.swift
//  GameListApp
//
//  Created by Oguzhan Bekir on 23.05.2021.
//

import Foundation
import CoreApi

enum HomeEndpointItem: Endpoint {
    case gamesList(query: String)
    case gameDetail(query: String)
    case filterList
    
    var baseUrl: String { "https://api.rawg.io/api/" }
    var path: String {
        switch self {
        case .gamesList(let query): return "games?key=f7bda52777bd4e4cabb8386fbed8084e\(query)"
        case .filterList: return "platforms/lists/parents?key=f7bda52777bd4e4cabb8386fbed8084e"
        case .gameDetail(let query): return "games/\(query)?key=f7bda52777bd4e4cabb8386fbed8084e"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .gamesList: return .get
        case .filterList: return .get
        case .gameDetail: return .get
        }
    }
}
