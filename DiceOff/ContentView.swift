//
//  ContentView.swift
//  DiceOff
//
//  Created by Michael Brünen on 09.01.22.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var game = Game(rows: 8, columns: 11)

    var body: some View {
        VStack(spacing: 5) {
            Text("Dice Off")
                .font(.largeTitle.bold())

            HStack(spacing: 20) {
                Text("Green: \(game.greenScore)")
                    .foregroundColor(.green)
                    .font(game.activePlayer == .green ? .title.bold() : .title)

                Text("Red: \(game.redScore)")
                    .foregroundColor(.red)
                    .font(game.activePlayer == .red ? .title.bold() : .title)
            }

            ForEach(game.board.indices, id: \.self) { row in    // go over every row
                HStack(spacing: 5) {                            // create an HStack for the row
                    ForEach(game.board[row]) { dice in          // go over every dice in the row
                        DiceView(dice: dice)                    // create a DiceView for the dice
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
