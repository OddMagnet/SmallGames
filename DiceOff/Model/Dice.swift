//
//  Dice.swift
//  DiceOff
//
//  Created by Michael Brünen on 09.01.22.
//

import Foundation

class Dice: Equatable, Identifiable, ObservableObject {
    // A dice "knows":
    // - its current value, between 1 and 4
    // - its owner, `Player.none` by default
    // - its row and column on the board
    // - its number of neighbors
    @Published var value = 1
    var owner = Player.none
    let row: Int
    let col: Int
    let neighbors: Int
    let id = UUID()

    // Conform to Equatable
    static func ==(lhs: Dice, rhs: Dice) -> Bool {
        lhs.id == rhs.id
    }

    init(row: Int, col: Int, neighbors: Int) {
        self.row = row
        self.col = col
        self.neighbors = neighbors
    }
}
