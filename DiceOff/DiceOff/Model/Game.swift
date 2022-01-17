//
//  Game.swift
//  DiceOff
//
//  Created by Michael Brünen on 09.01.22.
//

import SwiftUI

class Game: ObservableObject {
    var board: [[Dice]]
    var changeList = [Dice]()   // contains dice that are waiting to change

    private let numRows: Int
    private let numCols: Int
    var gameOverScore: Int

    @Published var gameOver = false
    @Published var players: [Player]
    @Published var activePlayer: Player
    @Published var state: GameState = .waiting

    private var aiClosedList = [Dice]()

    init(rows: Int, columns: Int, players: [Player]) {
        numRows = rows
        numCols = columns
        gameOverScore = numRows * numCols

        self.players = players

        // Create an empty board
        self.board = [[Dice]]()

        // set the first player (who is not AI)
        guard let firstPlayer = players.shuffled().first(where: {
            $0.isAI == false
        }) else { fatalError("The Game can't be initialised with an empty Players array") }

        // set the active player
        activePlayer = firstPlayer

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

    // MARK: - Player helper methods
    func nextPlayer() -> Player {
        // ensure the players array is not empty
        guard let currentIndex = players.firstIndex(of: activePlayer) else { fatalError("Players array empty") }

        // for the next players index, check that the current index isn't the last, if it is reset it to 0, otherwise just increase by 1
        let nextPlayerIndex = currentIndex >= (players.count - 1) ? 0 : currentIndex + 1

        // return the player at the next index
        return players[nextPlayerIndex]
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
    /// Checks and increases the scores for the players
    private func updateScores() {
        for player in players {
            player.score = 0
        }

        for row in board {
            for col in row {
                guard let color = col.owner?.color else { continue }

                for player in players {
                    if color == player.color { player.score += 1 }
                }
            }
        }
    }

    func increment(_ dice: Dice) {
        guard state == .waiting else { return }
        guard dice.owner == nil || dice.owner == activePlayer else { return }

        state = .changing
        changeList.append(dice)
        runChanges()
    }

    private func runChanges() {
        // ensure there are changes to be made
        guard changeList.isEmpty == false else {
            nextTurn()
            return
        }

        // update the scores
        updateScores()

        // check if the game is over
        if activePlayer.score == gameOverScore {
            gameOver = true
            print("GAME OVER")
        }

        // make a copy of the changeList, then empty it
        let toChange = changeList
        changeList.removeAll()

        // bump every dice in the list
        for dice in toChange {
            bump(dice)
        }

        // recall this method with a small delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.runChanges()
        }
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

    private func nextTurn() {
        activePlayer = nextPlayer()

        if activePlayer.isAI {
            state = .thinking

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.executeAITurn()
            }
        }

        state = .waiting
    }

    // MARK: - AI methods
    private func executeAITurn() {
        if let dice = getBestMove() {
            changeList.append(dice)
            state = .changing
            runChanges()
        } else {
            // TODO: actually handle this scenario (Player won)
            print("No moves left!")
        }
    }

    private func getBestMove() -> Dice? {
        // set up some variables
        let aiPlayer = activePlayer // to track the ai player
        var bestDice = [Dice]()     // what are the best dice to select
        var bestScore = -9999       // how good a move they are

        // check all dices
        for row in board {
            for dice in row {
                // only check possible dice
                if dice.owner == .none || dice.owner == aiPlayer {

                    // reset the list, then check the move on the dice
                    aiClosedList.removeAll()
                    checkMove(for: dice)

                    // get the score for the move
                    let baseScore = checkBaseDiceScore(for: aiPlayer)
                    let totalMoveScore = checkNeighborDiceScore(for: aiPlayer, with: dice, baseScore: baseScore)

                    // set new best score if needed
                    if totalMoveScore > bestScore {
                    // if it beats the current score
                        bestScore = totalMoveScore
                        bestDice.removeAll()
                        bestDice.append(dice)
                    } else if totalMoveScore == bestScore {
                    // if it matches the current sore
                        bestDice.append(dice)
                    }

                } else {
                // can't act on the players dice
                    continue
                }
            }
        }

        // return a move
        // no move possible
        if bestDice.isEmpty {
            return nil
        }
        // 50/50 chance to either fortify or make a random move
        if Bool.random() {
            // to fortify, select the dice with the highest value
            var highestValue = 0
            var selection = [Dice]()

            for dice in bestDice {
                if dice.value > highestValue {
                    highestValue = dice.value
                    selection.removeAll()
                    selection.append(dice)
                } else if dice.value == highestValue {
                    selection.append(dice)
                }
            }

            return selection.randomElement()

        } else {
            // otherwise just take a random one
            return bestDice.randomElement()
        }
    }

    /// Recursively adds all dies that would be affected by a move to a list
    /// - Parameter dice: The dice that is being checked
    private func checkMove(for dice: Dice) {
        // ensure the dice that is being checked wasn't checked already
        guard aiClosedList.contains(dice) == false else { return }
        // make sure it won't be checked in future recursive calls
        aiClosedList.append(dice)

        // check if it would cause a split
        if dice.value + 1 > dice.neighbors {
            for neighbor in getNeighbors(row: dice.row, col: dice.col) {
                checkMove(for: neighbor)
            }
        }
    }

    private func checkBaseDiceScore(for player: Player) -> Int {
        var score = 0

        // increasing a dice is worth less than "capturing" a dice
        // from the other player
        for checkDice in aiClosedList {
            if checkDice.owner == .none || checkDice.owner == player {
                score += 1
            } else {
                score += 10
            }
        }

        return score
    }

    private func checkNeighborDiceScore(for player: Player, with dice: Dice, baseScore: Int) -> Int {
        var score = baseScore

        // then check if the other player has a higher scoring dice
        // next to the current dice, that lowers the moves score
        // if the dice is equal or lower, then it adds to the score
        let neighborList = getNeighbors(row: dice.row, col: dice.col)
        for neighborDice in neighborList {
            if neighborDice.owner == player { continue }

            if neighborDice.value > dice.value {
                score -= 50
            } else {
                if neighborDice.owner != .none {
                    // dice is next to opponents dice with lower value
                    score += 10
                }
            }
        }

        return score
    }
}
