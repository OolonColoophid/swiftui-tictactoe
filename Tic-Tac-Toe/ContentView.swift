//
//  ContentView.swift
//  Tic-Tac-Toe
//
//  Created by Ian Hocking on 01/05/2021.
//

import SwiftUI

struct ContentView: View {

    let columns: [GridItem] = [GridItem(.flexible()),
                               GridItem(.flexible()),
                               GridItem(.flexible())]

    @State private var moves: [Move?] = Array(
        repeating: nil,
        count: 9)

    @State private var isHumansTurn = true



    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()

                LazyVGrid(
                    columns: columns,
                    spacing: 5
                ) {
                    ForEach(0..<9) { i in
                        ZStack {
                            Circle()
                                .foregroundColor(.red).opacity(0.5)
                                .frame(
                                    width: geometry.size.width/3 - 15,
                                    height:  geometry.size.width/3 - 15,
                                    alignment: .center)

                            Image(systemName: moves[i]?.indicator ?? "")
                                .resizable()
                                .frame(
                                    width: 40,
                                    height: 40,
                                    alignment: .center)
                                .foregroundColor(.white)
                        }
                        .onTapGesture {
                            moves[i] = Move(
                                player: isHumansTurn ? .human : .computer,
                                boardIndex: i)
                            isHumansTurn.toggle()
                        }
                    }
                }

                Spacer()
            }
            .padding()

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
        ContentView()
    }
}
