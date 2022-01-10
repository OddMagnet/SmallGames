//
//  Game.swift
//  DiceOff
//
//  Created by Michael Brünen on 09.01.22.
//

import SwiftUI

class Game: ObservableObject {
    var board: [[Dice]]
    var changeList = [Dice]() // contains dice that are waiting to change

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

    // MARK: - Neighbor helper methods
    private func countNeighbors(row: Int, col: Int) -> Int {
        var result = 0

        // Check each side for a neighbor
        if col > 0              { result += 1 } // left
        if col < numCols - 1    { result += 1 } // right
        if row > 0              { result += 1 } // above
        if row < numRows - 1    { result += 1 } // below

        return result
    }

    private func getNeighbors(row: Int, col: Int) -> [Dice] {
        var result = [Dice]()

        // Check each side for a neighbor
        if col > 0              { result.append(board[row][col - 1]) }  // left
        if col < numCols - 1    { result.append(board[row][col + 1]) } // right
        if row > 0              { result.append(board[row - 1][col]) } // above
        if row < numRows - 1    { result.append(board[row + 1][col]) } // below

        return result
    }

    // MARK: - Game methods
    /// Returns a tuple of scores
    /// - Returns: The tuple of scores, as `(.green, .red)`
    private func scores() -> (Int, Int) {
        var green = 0
        var red = 0

        for row in board {
            for col in row {
                if col.owner == .green { green += 1 }
                if col.owner == .red { red += 1 }
            }
        }

        return (green, red)
    }

    private func bump(_ dice: Dice) {
        // 1. Increase the value of the dice by 1
        dice.value += 1

        // 2. The current player becomes its owner
        dice.owner = activePlayer

        // ensure the player can see the change by flashing the current dice
        dice.changeAmount = 1
        withAnimation {
            dice.changeAmount = 0
        }

        // 3. Split if necessary
        if dice.value > dice.neighbors {
            // reset value
            dice.value = 1

            // Add neighbors to changeList to bump them
            for neighbor in getNeighbors(row: dice.row, col: dice.col) {
                changeList.append(neighbor)
            }
        }
    }

    private func runChanges() {
        // ensure there are changes to be made
        guard changeList.isEmpty == false else {
            nextTurn()
            return
        }

        // make a copy of the changeList, then empty it
        let toChange = changeList
        changeList.removeAll()

        // bump every dice in the list
        for dice in toChange {
            bump(dice)
        }

        // update the scores
        (greenScore, redScore) = scores()

        // recall this method with a small delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.runChanges()
        }
    }

    private func nextTurn() {
        if activePlayer == .green {
            activePlayer = .red
        } else {
            activePlayer = .green
        }

        state = .waiting
    }

    func increment(_ dice: Dice) {
        guard state == .waiting else { return }
        guard dice.owner == .none || dice.owner == activePlayer else { return }

        state = .changing
        changeList.append(dice)
        runChanges()
    }
}