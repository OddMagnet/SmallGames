//
//  DiceView.swift
//  DiceOff
//
//  Created by Michael Brünen on 09.01.22.
//

import SwiftUI

struct DiceView: View {
    @ObservedObject var dice: Dice

    var diceImage: some View {
        Image(systemName: "die.face.\(dice.value).fill")
            .resizable()
            .aspectRatio(1, contentMode: .fit)
    }

    var body: some View {
        diceImage
            .foregroundColor(dice.owner?.color ?? Color(white: 0.6))
            .overlay(
                diceImage
                    .foregroundColor(.white)
                    .opacity(dice.changeAmount)
            )
    }
}

struct DiceView_Previews: PreviewProvider {
    static var previews: some View {
        DiceView(
            dice: Dice(
                row: 1,
                col: 1,
                neighbors: 4
            )
        )
    }
}
