//
//  Alerts.swift
//  Tic-Tac-Toe
//
//  Created by Ian Hocking on 07/05/2021.
//

import SwiftUI

struct AlertItem: Identifiable {
    let id = UUID()

    var title: Text
    var message: Text
    var buttonField: Text
}

struct AlertContext {
    static let humanWin = AlertItem(
        title:          Text("You win!"),
        message:        Text("You are so smart. You beat your own AI."),
        buttonField:    Text("Hells yeah!"))
    
    static let computerWin = AlertItem(
        title:          Text("You lost!"),
        message:        Text("You programmed a super AI."),
        buttonField:    Text("Rematch"))
    
    static let draw = AlertItem(
        title:          Text("Draw!"),
        message:        Text("What a battle of wits we had here."),
        buttonField:    Text("Try again!"))
}
