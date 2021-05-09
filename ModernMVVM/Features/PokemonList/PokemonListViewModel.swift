//
//  PokemonListViewModel.swift
//  ModernMVVM
//
//  Created by Willian Honda on 08/05/21.
//  Copyright © 2021 Vadym Bulavin. All rights reserved.
//

import Foundation
import Combine

final class PokemonListViewModel: ObservableObject {
    @Published private(set) var state = State.idle

    private var bag = Set<AnyCancellable>()

    private let input = PassthroughSubject<Event, Never>()

    init() {
        Publishers.system(
            initial: state,
            reduce: Self.reduce,
            scheduler: RunLoop.main,
            feedbacks: [
                Self.whenLoading(),
                Self.whenPaginating(),
                Self.userInput(input: input.eraseToAnyPublisher())
            ]
        )
        .assign(to: \.state, on: self)
        .store(in: &bag)
    }

    deinit {
        bag.removeAll()
    }

    func send(event: Event) {
        input.send(event)
    }
}

// MARK: - Inner Types

extension PokemonListViewModel {
    enum State {
        case idle
        case loading
        case loaded([PokemonListItem])
        case paginating(offset: Int)
        case error(Error)
    }

    enum Event {
        case onAppear
        case onPokemonsLoaded([PokemonListItem])
//        case onNewPokemonsLoaded([PokemonListItem])
        case fetchNextPokemons(offset: Int)
        case onFailedToLoadPokemon(Error)
    }

    struct PokemonListItem: Identifiable, Hashable {
        let id: String
        let name: String
        let url: URL?

        init(pokemon: PokemonDTO) {
            id = pokemon.name
            name = pokemon.name
            if let pokemonUrl = pokemon.url {
                url = URL(string: pokemonUrl)
            } else {
                url = nil
            }
        }
    }
}

// MARK: - State Machine

extension PokemonListViewModel {
    static func reduce(_ state: State, _ event: Event) -> State {
        switch state {
        case .idle:
            switch event {
            case .onAppear:
                return .loading
            default:
                return state
            }
        case .loading, .paginating:
            switch event {
            case let .onFailedToLoadPokemon(error):
                return .error(error)
            case let .onPokemonsLoaded(pokemons):
                return .loaded(pokemons)
            default:
                return state
            }
        case .loaded:
            switch event {
            case let .fetchNextPokemons(offset):
                return .paginating(offset: offset)
            default:
                return state
            }
        case .error:
            return state
        }
    }

    static func whenLoading() -> Feedback<State, Event> {
        Feedback { (state: State) -> AnyPublisher<Event, Never> in
            guard case .loading = state else { return Empty().eraseToAnyPublisher() }

            return PokemonAPI.fetch()
                .map { $0.results.map(PokemonListItem.init) }
                .map(Event.onPokemonsLoaded)
                .catch { Just(Event.onFailedToLoadPokemon($0)) }
                .eraseToAnyPublisher()
        }
    }

    static func whenPaginating() -> Feedback<State, Event> {
        Feedback { (state: State) -> AnyPublisher<Event, Never> in
            guard case let .paginating(offset) = state else { return Empty().eraseToAnyPublisher() }

            return PokemonAPI.fetch(offset: offset)
                .map { $0.results.map(PokemonListItem.init) }
                .map(Event.onPokemonsLoaded)
                .catch { Just(Event.onFailedToLoadPokemon($0)) }
                .eraseToAnyPublisher()
        }
    }

    static func userInput(input: AnyPublisher<Event, Never>) -> Feedback<State, Event> {
        Feedback { _ in input }
    }
}
