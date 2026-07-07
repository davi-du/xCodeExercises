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
    @State private var selectedTab: Int = 0   // <-- nuovo

    var body: some View {
        Group {
            if let costumer {
                TabView(selection: $selectedTab) {   // <-- aggiunto selection
                    HomeView(costumer: costumer, transactionList: transactions)
                        .tabItem { Label("Home", systemImage: "house.fill") }
                        .tag(0)
                    
                    PaymentsView(onPaymentCompleted: {
                        Task {
                            await loadData()   // ricarica dati aggiornati dal server
                        }
                        selectedTab = 0   // torna alla Home
                    })
                        .tabItem { Label("Pay", systemImage: "dollarsign.circle.fill") }
                        .tag(1)
                    
                    ServicesView()
                        .tabItem { Label("Servizi", systemImage: "bag.fill.badge.plus") }
                        .tag(2)
                    
                    ProfileView(costumer: costumer)
                        .tabItem { Label("Profilo", systemImage: "person.circle.fill") }
                        .tag(3)
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
            print("Data loaded")
            costumer = result.customer
            transactions = result.transactions.sorted { $0.date > $1.date }  
        } catch {
            print("Error catched: \(error)")
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}


#Preview {
    ContentView()
}
