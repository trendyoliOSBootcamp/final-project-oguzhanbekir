//
//  Filter.swift
//  GameListApp
//
//  Created by Oguzhan Bekir on 25.05.2021.
//

import Foundation

// MARK: - Filter
struct Filter: Decodable {
    let count: Int?
    let next, previous: String?
    let results: [ResultFilter]?
}

// MARK: - Result
struct ResultFilter: Decodable {
    let id: Int?
    let name, slug: String?
    let platforms: [Platform]?
}

// MARK: - Platform
struct Platform: Decodable {
    let id: Int?
    let name, slug: String?
    let gamesCount: Int?
    let imageBackground: String?
    let image: String?
    let yearStart: Int?
    let yearEnd: String?

    enum CodingKeys: String, CodingKey {
        case id, name, slug
        case gamesCount = "games_count"
        case imageBackground = "image_background"
        case image
        case yearStart = "year_start"
        case yearEnd = "year_end"
    }
}
