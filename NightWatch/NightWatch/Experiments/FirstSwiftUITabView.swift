//
//  FirstSwiftUITabView.swift
//  NightWatch
//
//  Created by Davide Cidu on 23/06/2026.
//

import SwiftUI

struct FirstSwiftUITabView: View {
    var body: some View {
        TabView(selection: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Selection@*/.constant(1)/*@END_MENU_TOKEN@*/) {
            HomeView()
                .tabItem {
                    Image(systemName: "house")
                    Text("House label")
                }
            
            MapView()
                .tabItem {
                    Image(systemName: "map")
                    Text("Map Label")
                }
            Text("Tab Content 3")
                .tabItem {
                    Image(systemName: "gear")
                    Text("Gear Label")
                }
        }
    }
}

struct HomeView: View {
    var body: some View {
        Text("TODO: HomeView")
    }
}

struct MapView: View {
    var body: some View {
        Text("TODO: MapView")
    }
}

struct GearView: View {
    var body: some View {
        Text("TODO: GearView")
    }
}

#Preview {
    FirstSwiftUITabView()
}
