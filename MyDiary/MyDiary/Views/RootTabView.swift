//
//  RootTabView.swift
//  MyDiary
//
//  Created by Davide Cidu on 16/07/2026.
//


import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            ContentView()
                .tabItem { Label("Diario", systemImage: "book") }

            SearchView()
                .tabItem { Label("Ricerca", systemImage: "magnifyingglass") }

            StatsView()
                .tabItem { Label("Statistiche", systemImage: "chart.bar") }
        }
    }
}
