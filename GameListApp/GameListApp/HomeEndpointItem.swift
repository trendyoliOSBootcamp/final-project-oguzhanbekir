//
//  HomeEndpointItem.swift
//  GameListApp
//
//  Created by Oguzhan Bekir on 23.05.2021.
//

import Foundation
import CoreApi

enum HomeEndpointItem: Endpoint {
    case homepage(query: String)
    case gamesList
    
    var baseUrl: String { "https://api.rawg.io/api/games?key=f7bda52777bd4e4cabb8386fbed8084e" }
    var path: String {
        switch self {
        case .homepage(let query): return "homepage?\(query)"
        case .gamesList: return ""
            
        }
    }

    var method: HTTPMethod {
        switch self {
        case .homepage: return .get
        case .gamesList: return .get
        }
    }
}
