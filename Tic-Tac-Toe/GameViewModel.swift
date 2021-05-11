//
//  GameViewModel.swift
//  Tic-Tac-Toe
//
//  Created by Ian Hocking on 11/05/2021.
//

import SwiftUI

/// ObservableObject: Any time anything changes here, an update will be published
final class GameViewModel: ObservableObject {

    // How many columns will be use?
    let columns: [GridItem] = [GridItem(.flexible()),
                               GridItem(.flexible()),
                               GridItem(.flexible())]

    // @Published tells Swift to fire off an announcement that this has changed.
    @Published var moves: [Move?] = Array(
        repeating: nil,
        count: 9)
    @Published var isGameboardDisabled = false
    @Published var alertItem: AlertItem?

    func processPlayerMove(for position: Int) {
        if !isSquareOccupied(
            in: moves,
            forIndex: position)
        {
            moves[position] = Move(
                player: .human,
                boardIndex: position)
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

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
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

    func isSquareOccupied(
        in moves: [Move?],
        forIndex index: Int)
    -> Bool
    {
        return moves.contains(where: { $0?.boardIndex == index })
    }

    // If AI can win, then win
    // If AI can't win, then block
    // If AI can't block, then take middle square
    // If AI cn't take middle square, take random available square
    func determineComputerMovePosition(
        in moves: [Move?])
    -> Int
    {
        // If AI can win, then win

        // If there are 2/3 of a win pattern for the computer, then the computer
        // is one step from winning.
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
        let computerMoves = moves.compactMap { $0 }.filter { $0.player == .computer }
        let computerPositions = Set(computerMoves.map { $0.boardIndex })

        for pattern in winPatterns {
            // If we are one move away from winning, our count of moves (e.g. 0, 2)
            // subtracted from a winning set (e.g. 0, 1, 2) will be 1 item
            let winPositions = pattern.subtracting(computerPositions)

            if winPositions.count == 1 {
                let isAvailable = !isSquareOccupied(
                    in: moves,
                    forIndex: winPositions.first!)
                if isAvailable { return winPositions.first! }
            }
        }

        // If AI can't win, then block
        let centerSquare = 4
        if !isSquareOccupied(in: moves, forIndex: centerSquare) {
            return centerSquare
        }

        // If there are 2/3 of a win pattern for the human, then the human
        // is one step from winning.
        let humanMoves = moves.compactMap { $0 }.filter { $0.player == .human }
        let humanPositions = Set(humanMoves.map { $0.boardIndex })

        for pattern in winPatterns {
            // If we are one move away from winning, our count of moves (e.g. 0, 2)
            // subtracted from a winning set (e.g. 0, 1, 2) will be 1 item
            let winPositions = pattern.subtracting(humanPositions)

            if winPositions.count == 1 {
                let isAvailable = !isSquareOccupied(
                    in: moves,
                    forIndex: winPositions.first!)
                if isAvailable { return winPositions.first! }
            }
        }

        // If AI can't block, then take middle square

        // If AI cn't take middle square, take random available square
        var movePosition = Int.random(in: 0..<9)

        while isSquareOccupied(in: moves, forIndex: movePosition)
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
            [2, 5, 8],
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
