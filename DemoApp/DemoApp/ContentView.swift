//
//  ContentView.swift
//  DemoApp
//
//  Created by Davide Cidu on 01/07/2026.
//

import SwiftUI

struct ContentView: View {
    
    let costumer =
        CostumerProfile(
            firstName: "Antonio",
            secondName: "Bianchi",
            birthdate: {
                        let isoDate = "1987-04-14T10:44:00+0000"
                        let dateFormatter = ISO8601DateFormatter()
                        return dateFormatter.date(from: isoDate)!
                    }(),
            email: "antoniobianchi@avanade.com",
            phone: "+39 XXXXXXXXXX",
            costumerCode: "ba1324",
            iban: "ITXXXXXXXXXXXXXXXXXXXXXXXXX",
            address: "Via Roma, 14, 00185 Roma RM, Italia"
        )
    
    var body: some View {
        VStack {
            
            TabView {
                HomeView()
                    .tabItem{
                        Label("Home", systemImage: "house.fill")
                    }
                
                ServicesView()
                    .tabItem{
                        Label("Servizi", systemImage: "bag.fill.badge.plus")
                    }
                
                ProfileView(costumer: costumer)
                    .tabItem{
                        Label("Profilo", systemImage: "person.circle.fill")
                    }
            }
        }
    }
}

#Preview {
    ContentView()
}
