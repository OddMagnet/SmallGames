//
//  ContentView.swift
//  DiceOff
//
//  Created by Michael Brünen on 09.01.22.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var settings: Settings
    @StateObject private var game = Game(rows: 3, columns: 5, players: Player.defaultPlayers)
    @State private var showSettings = false

    var body: some View {
        NavigationView {
            VStack(spacing: 5) {
                HStack(spacing: 20) {
                    ForEach(game.players) { player in
                        Text("\(player.name): \(player.score)")
                            .foregroundColor(player.color)
                            .font(game.activePlayer == player ? .title.bold() : .title)
                    }
                }

                ForEach(game.board.indices, id: \.self) { row in    // go over every row
                    HStack(spacing: 5) {                            // create an HStack for the row
                        ForEach(game.board[row]) { dice in          // go over every dice in the row
                            DiceView(dice: dice)                    // create a DiceView for the dice
                                .onTapGesture {
                                    game.increment(dice)
                                }
                        }
                    }
                }
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Dice Off")
                        .font(.largeTitle.bold())
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gear")
//                        Text("Settings")
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
        .sheet(isPresented: $showSettings, onDismiss: updateGame) {
            SettingsView()
        }
    }

    func updateGame() {

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
