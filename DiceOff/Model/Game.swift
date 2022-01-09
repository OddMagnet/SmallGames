//
//  Game.swift
//  DiceOff
//
//  Created by Michael Brünen on 09.01.22.
//

import Foundation

class Game: ObservableObject {
    var board: [[Dice]]

    private let numRows: Int
    private let numCols: Int

    @Published var activePlayer: Player = .green
    @Published var state: GameState = .waiting

    @Published var greenScore = 0
    @Published var redScore = 0

    init(rows: Int, columns: Int) {
        numRows = rows
        numCols = columns

        // Create an empty board
        self.board = [[Dice]]()

        // for every row of the board
        for currentRow in 0 ..< numRows {
            // create a new row
            var newRow = [Dice]()

            // for every column in that row
            for currentCol in 0 ..< numCols {
                // create a new dice
                let dice = Dice(
                    row: currentRow,
                    col: currentCol,
                    neighbors: countNeighbors(row: currentRow, col: currentCol)
                )
                // append the dice
                newRow.append(dice)
            }

            // append the new row
            self.board.append(newRow)
        }
    }

    private func countNeighbors(row: Int, col: Int) -> Int {
        var result = 0

        // Check each side for a neighbor
        if col > 0              { result += 1 } // left
        if col < numCols - 1    { result += 1 } // right
        if row > 0              { result += 1 } // above
        if row < numRows - 1    { result += 1 } // below

        return result
    }
}
