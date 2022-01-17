//
//  Ssettings.swift
//  DiceOff
//
//  Created by Michael Brünen on 17.01.22.
//

import Foundation

class Settings: ObservableObject {
    // Player
    @Published var playerCount = 2
    @Published var greenPlayerName = "Green"
    @Published var greenPlayerisAI = false

    @Published var redPlayerName = "Red"
    @Published var redPlayerisAI = true

    @Published var yellowPlayerName = "Yellow"
    @Published var yellowPlayerisAI = true

    @Published var bluePlayerName = "Blue"
    @Published var bluePlayerisAI = true

    // Game
    @Published var rows = 8
    @Published var columns = 11
    @Published var vsAI = true
}
