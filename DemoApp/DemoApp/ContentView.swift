//
//  ContentView.swift
//  DemoApp
//
//  Created by Davide Cidu on 01/07/2026.
//

import SwiftUI

struct ContentView: View {
    
    @State private var costumer: CostumerProfile?
    @State private var transactions: [Transaction] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        Group {
            if let costumer {
                TabView {
                    HomeView(costumer: costumer, transactionList: transactions)
                        .tabItem { Label("Home", systemImage: "house.fill") }
                    
                    PaymentsView()
                        .tabItem { Label("Pay", systemImage: "dollarsign.circle.fill") }
                    
                    ServicesView()
                        .tabItem { Label("Servizi", systemImage: "bag.fill.badge.plus") }
                    
                    ProfileView(costumer: costumer)
                        .tabItem { Label("Profilo", systemImage: "person.circle.fill") }
                }
            } else if isLoading {
                ProgressView("Caricamento...")
            } else if let errorMessage {
                Text("Errore: \(errorMessage)")
            }
        }
        .task {
            await loadData()
        }
    }
    
    private func loadData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await CustomerService.fetchCustomerData()
            print("Dati ricevuti con successo")
            costumer = result.customer
            transactions = result.transactions
        } catch {
            print("Errore catturato: \(error)")
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}


#Preview {
    ContentView()
}
