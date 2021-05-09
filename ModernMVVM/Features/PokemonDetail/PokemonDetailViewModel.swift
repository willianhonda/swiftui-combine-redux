//
//  PokemonDetailViewModel.swift
//  ModernMVVM
//
//  Created by Willian Honda on 09/05/21.
//  Copyright © 2021 Vadym Bulavin. All rights reserved.
//

import Foundation
import Combine

final class PokemonDetailViewModel: ObservableObject {
    @Published private(set) var state: State

    private var bag = Set<AnyCancellable>()

    private let input = PassthroughSubject<Event, Never>()

    init(pokemonID: Int) {
        state = .idle(pokemonID)

        Publishers.system(
            initial: state,
            reduce: Self.reduce,
            scheduler: RunLoop.main,
            feedbacks: [
                Self.whenLoading(),
                Self.userInput(input: input.eraseToAnyPublisher())
            ]
        )
        .assign(to: \.state, on: self)
        .store(in: &bag)
    }

    func send(event: Event) {
        input.send(event)
    }
}

// MARK: - Inner Types

extension PokemonDetailViewModel {
    enum State {
        case idle(Int)
        case loading(Int)
        case loaded(PokemonDetail)
        case error(Error)
    }

    enum Event {
        case onAppear
        case onLoaded(PokemonDetail)
        case onFailedToLoad(Error)
    }

    struct PokemonDetail {
        let officialArtwork: String?
        
        init(pokemon: PokemonDetailDTO) {
            officialArtwork = pokemon.sprites?.other?.officialArtwork?.front_default
        }
    }
}

// MARK: - State Machine

extension PokemonDetailViewModel {
    static func reduce(_ state: State, _ event: Event) -> State {
        switch state {
        case .idle(let id):
            switch event {
            case .onAppear:
                return .loading(id)
            default:
                return state
            }
        case .loading:
            switch event {
            case .onFailedToLoad(let error):
                return .error(error)
            case .onLoaded(let movie):
                return .loaded(movie)
            default:
                return state
            }
        case .loaded:
            return state
        case .error:
            return state
        }
    }

    static func whenLoading() -> Feedback<State, Event> {
        Feedback { (state: State) -> AnyPublisher<Event, Never> in
            guard case .loading(let id) = state else { return Empty().eraseToAnyPublisher() }
            return PokemonAPI.fetchDetail(id: id)
                .map(PokemonDetail.init)
                .map(Event.onLoaded)
                .catch { Just(Event.onFailedToLoad($0)) }
                .eraseToAnyPublisher()
        }
    }

    static func userInput(input: AnyPublisher<Event, Never>) -> Feedback<State, Event> {
        Feedback(run: { _ in
            return input
        })
    }
}
