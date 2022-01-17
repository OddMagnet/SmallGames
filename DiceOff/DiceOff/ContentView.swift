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
    @State private var showSettingsSheet = false

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
                        showSettingsSheet = true
                    } label: {
                        Image(systemName: "gear")
//                        Text("Settings")
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
        // MARK: - Sheets
        .sheet(isPresented: $showSettingsSheet, onDismiss: newGame) {
            SettingsView()
        }
        .alert("Game Over", isPresented: $game.gameOver) {
            Button("Settings") { showSettingsSheet = true }
            Button("New Game") { newGame() }
        }
    }

    func newGame() {
        // create players array
        var players = [Player]()
        switch settings.playerCount {
            case 4:
                players.append(Player(name: settings.bluePlayerName, isAI: settings.bluePlayerisAI, color: .blue))
                fallthrough
            case 3:
                players.append(Player(name: settings.yellowPlayerName, isAI: settings.yellowPlayerisAI, color: .yellow))
                fallthrough
            default:
                players.append(Player(name: settings.redPlayerName, isAI: settings.redPlayerisAI, color: .red))
                players.append(Player(name: settings.greenPlayerName, isAI: settings.greenPlayerisAI, color: .green))
        }

        // create a new game
        game.reset(
            rows: settings.rows,
            columns: settings.columns,
            players: players
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
