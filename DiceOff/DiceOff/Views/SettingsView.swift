//
//  SettingsView.swift
//  DiceOff
//
//  Created by Michael Brünen on 17.01.22.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: Settings
    @Environment(\.dismiss) var dismiss

    @State private var count = 1

    var body: some View {
        Form {
            Section("Player count") {
                Picker("Player count", selection: $settings.playerCount) {
                    ForEach(1 ... 4, id: \.self) {
                        Text("\($0)")
                    }
                }
                .pickerStyle(.segmented)
            }

            Section("Player settings") {
                HStack {
                    
                }
            }

            Button("Dismiss") { dismiss() }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
