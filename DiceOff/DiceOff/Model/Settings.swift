//
//  Ssettings.swift
//  DiceOff
//
//  Created by Michael Brünen on 17.01.22.
//

import Foundation

class Settings: ObservableObject {
    // Player
    @Published var playerCount = 1
    @Published var greenPlayerName = "Green"
    @Published var redPlayerName = "Red"
    @Published var yellowPlayerName = "Yellow"
    @Published var bluePlayerName = "Blue"

    // Game
    @Published var rows = 8
    @Published var columns = 11
    @Published var vsAI = true
}
