//
//  NightWatchApp.swift
//  NightWatch
//
//  Created by Davide Cidu on 22/06/2026.
//

import SwiftUI
//@main è l'entry point dell'app senza Xcode manco builda
@main
struct NightWatchApp: App {
    @State private var nightWatchViewModel = NightWatchViewModel()
    var body: some Scene {
        WindowGroup {
            ContentView(nightWatchViewModel: self.nightWatchViewModel)
        }
    }
}
