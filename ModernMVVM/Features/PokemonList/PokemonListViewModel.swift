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
    @Published private(set) var state = State(viewState: .idle)

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
    struct State {
        var dataSource: [PokemonListItem] = []
        var shouldPaginate: Bool = false
        var offset: Int = 0
        var viewState: ViewState
    }

    enum ViewState {
        case idle
        case loading
        case loaded
        case error(Error)
    }

    enum Event {
        case onAppear
        case onPokemonsLoaded([PokemonListItem])
        case fetchNextPokemons(offset: Int)
        case onFailedToLoadPokemon(Error)
    }

    struct PokemonListItem: Identifiable, Hashable {
        let id: Int
        let name: String
        let url: URL?

        init(pokemon: PokemonDTO) {
            id = Int(pokemon.url!
                        .replacingOccurrences(of: "https://pokeapi.co/api/v2/pokemon/", with: "")
                        .replacingOccurrences(of: "/", with: "")
            )!
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
        var newState = state
        switch state.viewState {
        case .idle:
            switch event {
            case .onAppear:
                newState.viewState = .loading
            default:
                break
            }
        case .loading:
            switch event {
            case let .onFailedToLoadPokemon(error):
                newState.viewState = .error(error)
            case let .onPokemonsLoaded(pokemons):
                newState.dataSource.append(contentsOf: pokemons)
                newState.viewState = .loaded
            default:
                break
            }
        case .loaded:
            switch event {
            case let .fetchNextPokemons(offset):
                newState.shouldPaginate = true
                newState.offset = offset
            case let .onPokemonsLoaded(pokemons):
                newState.shouldPaginate = false
                newState.dataSource.append(contentsOf: pokemons)
            default:
                break
            }
        case .error:
            break
        }
        return newState
    }

    static func whenLoading() -> Feedback<State, Event> {
        Feedback { (state: State) -> AnyPublisher<Event, Never> in
            guard case .loading = state.viewState else { return Empty().eraseToAnyPublisher() }

            return PokemonAPI.fetch()
                .map { $0.results.map(PokemonListItem.init) }
                .map(Event.onPokemonsLoaded)
                .catch { Just(Event.onFailedToLoadPokemon($0)) }
                .eraseToAnyPublisher()
        }
    }

    static func whenPaginating() -> Feedback<State, Event> {
        Feedback { (state: State) -> AnyPublisher<Event, Never> in
            guard state.shouldPaginate else { return Empty().eraseToAnyPublisher() }

            return PokemonAPI.fetch(offset: state.offset)
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
