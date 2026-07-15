//
//  ServicesView.swift
//  DemoApp
//
//  Created by Davide Cidu on 01/07/2026.
//

import SwiftUI

struct ServicesView: View {
    
    var listaServizi: [BankOffer] = [
        BankOffer(
            title: "Bonifici",
            description: "Invia denaro ovunque, in tempo reale.",
            iconName: "arrow.left.arrow.right"),
        
        BankOffer(
            title: "Prestiti",
            description: "Liquidità su misura per i tuoi progetti.",
            iconName: "banknote.fill"),
        
        BankOffer(
            title: "Mutui",
            description: "Realizza la casa dei tuoi sogni.",
            iconName: "house.fill"),
        
        BankOffer(
            title: "Assicurazioni",
            description: "Proteggi te, la famiglia e i tuoi beni.",
            iconName: "shield.fill"),
        
        BankOffer(
            title: "Investimenti",
            description: "Fai crescere i tuoi risparmi nel tempo.",
            iconName: "chart.line.uptrend.xyaxis"),
        
        BankOffer(
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
