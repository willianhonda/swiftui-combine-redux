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

    var body: some View {
        NavigationView {
            content
                .navigationBarTitle("Pokemon List")
        }
        .onAppear { self.viewModel.send(event: .onAppear) }
    }

    private var content: some View {
        switch viewModel.state.viewState {
        case .idle:
            return Color.clear.eraseToAnyView()
        case .loading:
            return Spinner(isAnimating: true, style: .large).eraseToAnyView()
        case .error(let error):
            return Text(error.localizedDescription).eraseToAnyView()
        case .loaded:
            return PokemonList(
                repos: viewModel.state.dataSource) {
                viewModel.send(event: .fetchNextPokemons(offset: viewModel.state.dataSource.count))
            }.eraseToAnyView()
        }
    }
}


struct PokemonList: View {
    let repos: [PokemonListViewModel.PokemonListItem]
    let onScrolledAtBottom: () -> Void

    var body: some View {
        List {
            reposList
        }
    }

    private var reposList: some View {
        ForEach(repos) { repo in
            NavigationLink(
                destination: PokemonDetailView(viewModel: PokemonDetailViewModel(pokemonID: repo.id)),
                label: { PokemonItemRow(pokemon: repo) }
            )
            if self.repos.last == repo {
                ProgressView()
                    .frame(idealWidth: .infinity, maxWidth: .infinity, alignment: .center)
                    .onAppear {
                        self.onScrolledAtBottom()
                    }
            }
        }
    }
}


struct PokemonItemRow: View {
    var pokemon: PokemonListViewModel.PokemonListItem
    var body: some View {
        VStack {
            Text(pokemon.name).font(.title)
        }
        .frame(idealWidth: .infinity, maxWidth: .infinity, alignment: .center)
    }
}
