//
//  PokemonDetailView.swift
//  ModernMVVM
//
//  Created by Willian Honda on 09/05/21.
//  Copyright © 2021 Vadym Bulavin. All rights reserved.
//

import SwiftUI
import Combine

struct PokemonDetailView: View {
    @ObservedObject var viewModel: PokemonDetailViewModel
    @Environment(\.imageCache) var cache: ImageCache

    var body: some View {
        content
            .onAppear { self.viewModel.send(event: .onAppear) }
    }

    private var content: some View {
        switch viewModel.state {
        case .idle:
            return Color.clear.eraseToAnyView()
        case .loading:
            return spinner.eraseToAnyView()
        case .error(let error):
            return Text(error.localizedDescription).eraseToAnyView()
        case .loaded(let pokemon):
            return self.pokemon(pokemon).eraseToAnyView()
        }
    }

    private func pokemon(_ pokemon: PokemonDetailViewModel.PokemonDetail) -> some View {
        ScrollView {
            VStack {
                fillWidth
                AsyncImage(
                    url: URL(string: pokemon.officialArtwork!)!,
                    cache: cache,
                    placeholder: self.spinner,
                    configuration: { $0.resizable() }
                )
                .aspectRatio(contentMode: .fit)
            }
        }
    }

    private var fillWidth: some View {
        HStack {
            Spacer()
        }
    }

    private var spinner: Spinner { Spinner(isAnimating: true, style: .large) }
}
