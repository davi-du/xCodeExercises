//
//  ServicesView.swift
//  DemoApp
//
//  Created by Davide Cidu on 01/07/2026.
//

import SwiftUI

struct ServicesView: View {
    
    var listaServizi: [BankService] = [
        BankService(
            title: "Bonifici",
            description: "Invia denaro ovunque, in tempo reale.",
            iconName: "arrow.left.arrow.right"),
        
        BankService(
            title: "Prestiti",
            description: "Liquidità su misura per i tuoi progetti.",
            iconName: "banknote.fill"),
        
        BankService(
            title: "Mutui",
            description: "Realizza la casa dei tuoi sogni.",
            iconName: "house.fill"),
        
        BankService(
            title: "Assicurazioni",
            description: "Proteggi te, la famiglia e i tuoi beni.",
            iconName: "shield.fill"),
        
        BankService(
            title: "Investimenti",
            description: "Fai crescere i tuoi risparmi nel tempo.",
            iconName: "chart.line.uptrend.xyaxis"),
        
        BankService(
            title: "Carte",
            description: "Carte di debito e credito su misura.",
            iconName: "creditcard.fill"),
    ]
    
    var body: some View {
    
        VStack {
            Text("Scopri i nostri servizi")
                .font(.title)
                .padding(.bottom)
                .padding(.leading)
                .padding(.trailing)
                .bold()
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ], spacing: 16) {
                ForEach(listaServizi) { servizio in
                    ServiceCardView(bankService: servizio)
                }
            }
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity)
    }

    
}

#Preview {
    ServicesView()
}
