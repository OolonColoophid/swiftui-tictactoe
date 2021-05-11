//
//  GameView.swift
//  Tic-Tac-Toe
//
//  Created by Ian Hocking on 01/05/2021.
//

import SwiftUI

/// In the original form of this code, we had lots of game logic here. This is now in the GameViewModel.
struct GameView: View {

    // @StateObject tells Swift UI this is a class (i.e. persistent, not
    // updated and destroyed like a struct). When this changes via @Published
    // properties, it will trigger a redrawing of the view.
    @StateObject private var viewModel = GameViewModel()

    var body: some View {
        // The Geometry container gives us access to size and shape info
        GeometryReader { geometry in
            VStack {
                Spacer()

                // The LazyWorld container sticks to the columns provided and
                // then grows rows lazily depending on the items we put in
                LazyVGrid(
                    columns: viewModel.columns,
                    spacing: 5
                ) {
                    ForEach(0..<9) { i in
                        ZStack {
                            GameSquareView(proxy: geometry)
                            PlayerIndicator(
                                systemImageName: viewModel.moves[i]?.indicator
                                    ?? "")
                        }
                        .onTapGesture {
                            viewModel.processPlayerMove(for: i)
                        }
                    }
                }
                Spacer()
            }
            .disabled(viewModel.isGameboardDisabled)
            .padding()

            // $alertItem means this function is bound to self.alertItem.
            // When it changes, this function is called. (So it will be
            // game when there is a win, lose or draw.)
            .alert(item: $viewModel.alertItem, content: { alertItem in
                Alert(title: alertItem.title,
                      message: alertItem.message,
                      dismissButton: .default(
                        alertItem.buttonField,
                        action: viewModel.resetGame))
            } )
        }
    }
}

enum Player {
    case human, computer
}

struct Move {
    let player: Player
    let boardIndex: Int

    var indicator: String {
        return player == .human ? "xmark" : "circle"
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}

/// We've created this by command-clicking the Circle() content view and selecting 'Extract Subview'
/// (this only works when the live preview ('canvas') is showing).
struct GameSquareView: View {
    var proxy: GeometryProxy

    var body: some View {
        Circle()
            .foregroundColor(.red).opacity(0.5)
            .frame(
                width: proxy.size.width/3 - 15,
                height:  proxy.size.width/3 - 15,
                alignment: .center)
    }
}

struct PlayerIndicator: View {
    var systemImageName: String

    var body: some View {
        Image(systemName: systemImageName)
            .resizable()
            .frame(
                width: 40,
                height: 40,
                alignment: .center)
            .foregroundColor(.white)
    }
}
