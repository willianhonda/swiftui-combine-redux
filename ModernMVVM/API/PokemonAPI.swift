//
//  PokemonAPI.swift
//  ModernMVVM
//
//  Created by Willian Honda on 08/05/21.
//  Copyright © 2021 Vadym Bulavin. All rights reserved.
//

import Foundation
import Combine

enum PokemonAPI {
    private static let base = URL(string: "https://pokeapi.co/api/v2/pokemon/")!
    private static let agent = Agent()

    static func fetch(offset: Int = 0) -> AnyPublisher<PokemonPageDTO<PokemonDTO>, Error> {
        let request = URLComponents(url: base, resolvingAgainstBaseURL: true)?
            .addingOffset(offset)
            .request
        return agent.run(request!)
    }
}

private extension URLComponents {
    func addingOffset(_ offset: Int) -> URLComponents {
        var copy = self
        copy.queryItems = [
            URLQueryItem(name: "offset", value: String(offset)),
            URLQueryItem(name: "limit", value: String(20))
        ]
        return copy
    }

    var request: URLRequest? {
        url.map { URLRequest.init(url: $0) }
    }
}

// MARK: - DTOs

struct PokemonDTO: Codable {
    let name: String
    let url: String?
}
//
//struct MovieDetailDTO: Codable {
//    let id: Int
//    let title: String
//    let overview: String?
//    let poster_path: String?
//    let vote_average: Double?
//    let genres: [GenreDTO]
//    let release_date: String?
//    let runtime: Int?
//    let spoken_languages: [LanguageDTO]
//
//    var poster: URL? { poster_path.map { MoviesAPI.imageBase.appendingPathComponent($0) } }
//
//    struct GenreDTO: Codable {
//        let id: Int
//        let name: String
//    }
//
//    struct LanguageDTO: Codable {
//        let name: String
//    }
//}

struct PokemonPageDTO<T: Codable>: Codable {
    let count: Int?
    let next: String?
    let previous: String?
    let results: [T]
}

