//
//  DiceOffApp.swift
//  DiceOff
//
//  Created by Michael Brünen on 09.01.22.
//

import SwiftUI

@main
struct DiceOffApp: App {
    @StateObject var settings = Settings()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(settings)
        }
    }
}
