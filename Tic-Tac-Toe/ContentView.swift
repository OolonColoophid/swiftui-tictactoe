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
                            if !squareIsOccupied(
                                in: moves,
                                forIndex: i)
                            {
                                moves[i] = Move(
                                    player: .human,
                                    boardIndex: i)
                            }

                            // Check for win conditon (or draw)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                let computerPosition = determineComputerMovePosition(in: moves)
                                moves[computerPosition] = Move(
                                    player: .computer,
                                    boardIndex: computerPosition)

                            }
                        }
                    }
                }

                Spacer()
            }
            .padding()

        }
    }

    func squareIsOccupied(
        in moves: [Move?],
        forIndex index: Int)
    -> Bool
    {
        return moves.contains(where: { $0?.boardIndex == index })
    }

    func determineComputerMovePosition(
        in moves: [Move?])
    -> Int
    {
        var movePosition = Int.random(in: 0..<9)

        while squareIsOccupied(in: moves, forIndex: movePosition)
        {
            movePosition = Int.random(in: 0..<9)
        }

        return movePosition
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
