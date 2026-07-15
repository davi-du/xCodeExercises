//
//  ContentView.swift
//  DemoApp
//
//  Created by Davide Cidu on 01/07/2026.
//

import SwiftUI

struct ContentView: View {

    @State private var session = SessionManager()
    @State private var viewModel = ContentViewModel()

    var body: some View {
        Group {
            if session.isAuthenticated {
                Group {
                    if let costumer = viewModel.costumer {
                        TabView(selection: $viewModel.selectedTab) {
                            HomeView(costumer: costumer, transactionList: viewModel.transactions)
                                .tabItem { Label("Home", systemImage: "house.fill") }
                                .tag(0)

                            PaymentsView(onPaymentCompleted: {
                                Task {
                                    if let token = session.token {
                                        let ancoraValido = await viewModel.loadData(token: token)
                                        if !ancoraValido {
                                            session.logout()
                                        }
                                    }
                                    viewModel.selectedTab = 0
                                }
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
                    } else if viewModel.isLoading {
                        ProgressView("Caricamento...")
                    } else if let errorMessage = viewModel.errorMessage {
                        Text("Errore: \(errorMessage)")
                    }
                }
            } else {
                LoginView()
            }
        }
        .environment(session)
        .task(id: session.isAuthenticated) {
            if session.isAuthenticated {
                guard let token = session.token else { return }
                let ancoraValido = await viewModel.loadData(token: token)
                if !ancoraValido {
                    session.logout()
                }
            } else {
                viewModel.reset()
            }
        }
    }
}

#Preview {
    ContentView()
}
