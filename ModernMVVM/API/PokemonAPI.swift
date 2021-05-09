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

    static func fetchDetail(id: Int) -> AnyPublisher<PokemonDetailDTO, Error> {
        let request = URLComponents(url: base.appendingPathComponent("/\(id)"), resolvingAgainstBaseURL: true)?.request
        return agent.run(request!)
    }
}

private extension URLComponents {
    func addingOffset(_ offset: Int) -> URLComponents {
        var copy = self
        copy.queryItems = [
            URLQueryItem(name: "offset", value: String(offset)),
            URLQueryItem(name: "limit", value: String(75))
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

struct PokemonPageDTO<T: Codable>: Codable {
    let count: Int?
    let next: String?
    let previous: String?
    let results: [T]
}

struct PokemonDetailDTO: Codable {
    let sprites: SpritesDTO?

    struct SpritesDTO: Codable {
        let front_default: String?
        let other: SpritesOtherDTO?

        struct SpritesOtherDTO: Codable {
            let officialArtwork: SpritesOfficialArtworkDTO?

            enum CodingKeys: String, CodingKey {
                case officialArtwork = "official-artwork"
            }

            struct SpritesOfficialArtworkDTO: Codable {
                let front_default: String?
            }
        }
    }
}
