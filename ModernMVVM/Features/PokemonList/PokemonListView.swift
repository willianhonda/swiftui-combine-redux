//
//  PokemonListView.swift
//  ModernMVVM
//
//  Created by Willian Honda on 08/05/21.
//  Copyright © 2021 Vadym Bulavin. All rights reserved.
//

import Combine
import SwiftUI

struct PokemonListView: View {
    @ObservedObject var viewModel: PokemonListViewModel
    @State private var pokemonList: [PokemonListViewModel.PokemonListItem] = []

    var body: some View {
        NavigationView {
            content
                .navigationBarTitle("Pokemon List")
        }
        .onAppear { self.viewModel.send(event: .onAppear) }
    }

    private func list(state: PokemonListViewModel.State) -> some View {
        VStack(alignment: .leading) {
            List(pokemonList) { item in
                Text(item.name)
                    .onAppear {
                        if pokemonList.last?.id == item.id {
                            viewModel.send(event: .fetchNextPokemons(offset: pokemonList.count))
                        }
                    }
            }
            switch viewModel.state {
            case .idle:
                Color.clear.eraseToAnyView()
            case .loading, .paginating:
                Spinner(isAnimating: true, style: .large).eraseToAnyView()
            case .error(let error):
                Text(error.localizedDescription).eraseToAnyView()
            case .loaded(let pokemons):
                Text("\(pokemons.count)").onAppear {
                    pokemonList.append(contentsOf: pokemons)
                }
            }
        }
    }

    private var content: some View {
        return list(state: viewModel.state)
            .eraseToAnyView()
        //        switch viewModel.state {
        //        case .idle:
        //            return Color.clear.eraseToAnyView()
        //        case .loading, .paginating:
        //            return Spinner(isAnimating: true, style: .large).eraseToAnyView()
        //        case .error(let error):
        //            return Text(error.localizedDescription).eraseToAnyView()
        //        case .loaded(let pokemons):
        //            return list(pokemons: pokemons)
        //                .eraseToAnyView()
        //        }
    }


    //
    //        List(pokemonList) { pokemon in
    //            VStack(alignment: .leading) {
    //                PokemonListItemView(pokemon: pokemon)
    //            }.onAppear {
    //                if pokemonList.last?.id == pokemon.id {
    //                    viewModel.send(event: .fetchNextPokemons)
    //                }
    //            }
    //        }
    //    }
    //
    //
    //    private func list(pokemons: [PokemonListViewModel.PokemonListItem]) -> some View {
    //        return List(pokemonList) { pokemon in
    //            ForEach(pokemons) { pokemon in
    //                PokemonListItemView(pokemon: pokemon)
    //            }
    //            .onAppear {
    //                if pokemons.last?.id == pokemon.id {
    //                    viewModel.send(event: .fetchNextPokemons)
    //                }
    //            }
    //        }
    //        .onAppear {
    //            pokemonList.append(contentsOf: pokemons)
    //        }
    //    }
    //
    //        return List(pokemons) { pokemon in
    //
    //            VStack(alignment: .leading) {
    //                PokemonListItemView(pokemon: pokemon)
    //            }.onAppear {
    //                if pokemons.last?.id == pokemon.id {
    //                    viewModel.send(event: .fetchNextPokemons)
    //                }
    //            }

    //            NavigationLink(
    //                destination: MovieDetailView(viewModel: MovieDetailViewModel(movieID: movie.id)),
    //                label: { MovieListItemView(movie: movie) }
    //            )

    //        }
    //    }
}

struct PokemonListItemView: View {
    let pokemon: PokemonListViewModel.PokemonListItem

    var body: some View {
        VStack {
            title
            //            poster
        }
    }

    private var title: some View {
        Text(pokemon.name)
            .font(.title)
            .frame(idealWidth: .infinity, maxWidth: .infinity, alignment: .center)
    }

    //    private var poster: some View {
    //        movie.poster.map { url in
    //            AsyncImage(
    //                url: url,
    //                cache: cache,
    //                placeholder: spinner,
    //                configuration: { $0.resizable().renderingMode(.original) }
    //            )
    //        }
    //        .aspectRatio(contentMode: .fit)
    //        .frame(idealHeight: UIScreen.main.bounds.width / 2 * 3) // 2:3 aspect ratio
    //    }

    //    private var spinner: some View {
    //        Spinner(isAnimating: true, style: .medium)
    //    }
}
