//
//  Player.swift
//  DiceOff
//
//  Created by Michael Brünen on 09.01.22.
//

import SwiftUI

class Player: Equatable, Identifiable, ObservableObject {
    enum PlayerColor {
        case green, red, yellow, blue
    }

    static let defaultPlayers: [Player] = [
        Player(name: "Green", isAI: false, color: .green),
        Player(name: "Red", isAI: true, color: .red)
    ]

    init(name: String, isAI: Bool, color: PlayerColor) {
        self.name = name
        self.isAI = isAI
        playerColor = color
    }

    let id = UUID()
    var name: String
    var isAI: Bool
    @Published var score: Int = 0
    private var playerColor: PlayerColor
    var color: Color {
        switch playerColor {
            case .green:
                return . green
            case .red:
                return .red
            case .yellow:
                return .yellow
            case .blue:
                return .blue
        }
    }

    static func == (lhs: Player, rhs: Player) -> Bool {
        lhs.name == rhs.name
        && lhs.color == rhs.color
    }
}
