//
//  GameDetail.swift
//  GameListApp
//
//  Created by Oguzhan Bekir on 26.05.2021.
//

import Foundation

// MARK: - GameDetailList
struct GameDetailList: Decodable {
    let id: Int?
    let slug, name, nameOriginal, description: String?
    let metacritic: Int?
    let released: String?
    let backgroundImage: String?
    let website: String?
    let playtime: Int?
    let redditURL: String?
    let redditName, redditDescription: String?
    let redditLogo: String?
    let metacriticURL: String?
    let parentsCount, additionsCount, gameSeriesCount, reviewsCount: Int?
    let genres, publishers: [GenreList]?
    let descriptionRaw: String?

    enum CodingKeys: String, CodingKey {
        case id, slug, name
        case nameOriginal = "name_original"
        case description 
        case metacritic, released
        case backgroundImage = "background_image"
        case website, playtime
        case redditURL = "reddit_url"
        case redditName = "reddit_name"
        case redditDescription = "reddit_description"
        case redditLogo = "reddit_logo"
        case metacriticURL = "metacritic_url"
        case parentsCount = "parents_count"
        case additionsCount = "additions_count"
        case gameSeriesCount = "game_series_count"
        case reviewsCount = "reviews_count"
        case genres, publishers
        case descriptionRaw = "description_raw"
    }
}

// MARK: - GenreList
struct GenreList: Decodable {
    let id: Int?
    let name, slug: String?
    let gamesCount: Int?
    let imageBackground: String?

    enum CodingKeys: String, CodingKey {
        case id, name, slug
        case gamesCount = "games_count"
        case imageBackground = "image_background"
    }
}
