//
//  ContentView.swift
//  Tic-Tac-Toe
//
//  Created by Ian Hocking on 01/05/2021.
//

import SwiftUI

struct ContentView: View {

    // How many columns will be use?
    let columns: [GridItem] = [GridItem(.flexible()),
                               GridItem(.flexible()),
                               GridItem(.flexible())]

    // Any time a state variable changes, the view is redrawn
    @State private var moves: [Move?] = Array(
        repeating: nil,
        count: 9)
    @State private var isGameboardDisabled = false
    @State private var alertItem: AlertItem?

    var body: some View {
        // The Geometry container gives us access to size and shape info
        GeometryReader { geometry in
            VStack {
                Spacer()

                // The LazyWorld container sticks to the columns provided and
                // then grows rows lazily depending on the items we put in
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

                            // Check for win conditon
                            if checkWinCondition(
                                for: .human,
                                in: moves)
                            {
                                alertItem = AlertContext.humanWin
                                return
                            }

                            // Check for draw condition
                            if checkForDrawCondition(in: moves)
                            {
                                alertItem = AlertContext.draw
                                return
                            }

                            isGameboardDisabled = true

                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                let computerPosition = determineComputerMovePosition(in: moves)
                                moves[computerPosition] = Move(
                                    player: .computer,
                                    boardIndex: computerPosition)
                                isGameboardDisabled = false

                                if checkWinCondition(
                                    for: .computer,
                                    in: moves)
                                {
                                    alertItem = AlertContext.computerWin
                                    return
                                }

                                // Check for draw condition
                                if checkForDrawCondition(in: moves)
                                {
                                    alertItem = AlertContext.draw
                                    return
                                }
                            }
                        }
                    }
                }

                Spacer()
            }
            .disabled(isGameboardDisabled)
            .padding()

            // $alertItem means this function is bound to self.alertItem.
            // When it changes, this function is called. (So it will be
            // game when there is a win, lose or draw.)
            .alert(item: $alertItem, content: { alertItem in
                Alert(title: alertItem.title,
                      message: alertItem.message,
                      dismissButton: .default(
                        alertItem.buttonField,
                        action: resetGame))
            } )

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

    func checkWinCondition(
        for player: Player,
        in moves: [Move?]
    )-> Bool
    {
        // If a player 'owns' these positions, they have won
        let winPatterns: Set<Set<Int>> = [
            [0, 1, 2],
            [3, 4, 5],
            [6, 7, 8],
            [0, 3, 6],
            [1, 4, 7],
            [3, 5, 8],
            [0, 4, 8],
            [2, 4, 6]
        ]

        // Compact map will remove nils from our arry (which might look
        // like [move, nil, nil, move, move, move] etc. Then we filter
        // by which player we're looking at
        let playerMoves = moves.compactMap { $0 }.filter { $0.player == player }

        // For each of the player moves, pull out the board index
        let playerPositions = Set(playerMoves.map { $0.boardIndex })

        // Now we can see if the player moves (in terms of board indexes)
        // contains any of the winning positions subsets. In other words
        // do any player moves include 0, 1, 2? If so, the player
        // has won.
        for pattern in winPatterns where pattern.isSubset(of: playerPositions)
        {
            return true
        }

        return false
    }

    func checkForDrawCondition(
        in moves: [Move?]
    ) -> Bool
    {
        // if all moves have been made (i.e. all nine squares are full) but
        // there is no win condition (this has been checked before this function
        // is called), then it must be a draw
        return moves.compactMap { $0 }.count == 9
    }

    func resetGame()
    {
        moves = Array(
            repeating: nil,
            count: 9)
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
