//
//  DiceView.swift
//  DiceOff
//
//  Created by Michael Brünen on 09.01.22.
//

import SwiftUI

struct DiceView: View {
    @ObservedObject var dice: Dice

    var body: some View {
        Image(systemName: "die.face.\(dice.value).fill")
            .resizable()
            .aspectRatio(1, contentMode: .fit)
            .foregroundColor(dice.owner.color)
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
