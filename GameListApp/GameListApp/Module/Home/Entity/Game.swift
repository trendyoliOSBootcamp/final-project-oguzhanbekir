//
//  Game.swift
//  GameListApp
//
//  Created by Oguzhan Bekir on 23.05.2021.
//

import Foundation

// MARK: - GameList
struct GameListResponse: Decodable {
    let count: Int?
    let next: String?
    let previous: String?
    let results: [GameDetail]?
    let gameDescription: String?
    let nofollowCollections: [String]?
    let userPlatforms: Bool?
    
    enum CodingKeys: String, CodingKey {
        case count, next, previous, results
        case gameDescription = "description"
        case nofollowCollections = "nofollow_collections"
        case userPlatforms = "user_platforms"
    }
}


// MARK: - Result
struct GameDetail: Decodable {
    let id: Int?
    let slug, name, released: String?
    let tba: Bool?
    let backgroundImage: String?
    let rating: Double?
    let ratingTop: Int?
    let ratingsCount, reviewsTextCount, added: Int?
    let metacritic, playtime, suggestionsCount: Int?
    let updated: String?
    let userGame: String?
    let reviewsCount: Int?
    let saturatedColor, dominantColor: Color?
    let parentPlatforms: [ParentPlatform]?
    let genres: [Genre]?
    let stores: [Store]?
    let clip: String?
    let esrbRating: EsrbRating?

    enum CodingKeys: String, CodingKey {
        case id, slug, name, released, tba
        case backgroundImage = "background_image"
        case rating
        case ratingTop = "rating_top"
        case ratingsCount = "ratings_count"
        case reviewsTextCount = "reviews_text_count"
        case added
        case metacritic, playtime
        case suggestionsCount = "suggestions_count"
        case updated
        case userGame = "user_game"
        case reviewsCount = "reviews_count"
        case saturatedColor = "saturated_color"
        case dominantColor = "dominant_color"
        case parentPlatforms = "parent_platforms"
        case genres, stores, clip
        case esrbRating = "esrb_rating"
    }
}

enum Color: String, Decodable {
    case the0F0F0F = "0f0f0f"
}

// MARK: - EsrbRating
struct EsrbRating: Decodable {
    let id: Int?
    let name, slug, nameEn, nameRu: String?
       enum CodingKeys: String, CodingKey {
           case id, name, slug
           case nameEn = "name_en"
           case nameRu = "name_ru"
       }
}

// MARK: - Genre
struct Genre: Decodable {
    let id: Int?
    let name, slug: String?
    let gamesCount: Int?
    let imageBackground: String?
    let language: Language?

    enum CodingKeys: String, CodingKey {
        case id, name, slug
        case gamesCount = "games_count"
        case imageBackground = "image_background"
        case language
    }
}

enum Language: String, Decodable {
    case eng = "eng"
}

// MARK: - ParentPlatform
struct ParentPlatform: Decodable {
    let platform: EsrbRating?
}


// MARK: - Store
struct Store: Decodable {
    let id: Int?
    let store: Genre?
}
