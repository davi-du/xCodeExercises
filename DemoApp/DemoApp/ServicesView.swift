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
            description: "Descrizione del servizio",
            iconName: "1.circle.fill"),
        
        BankService(
            title: "Prestiti",
            description: "Descrizione del servizio",
            iconName: "2.circle.fill"),
        
        BankService(
            title: "Mutui",
            description: "Descrizione del servizio",
            iconName: "3.circle.fill"),
        
        BankService(
            title: "Assicurazioni",
            description: "Descrizione del servizio",
            iconName: "4.circle.fill"),
        
        BankService(
            title: "Investimenti",
            description: "Descrizione del servizio",
            iconName: "5.circle.fill"),
        
        BankService(
            title: "Carte",
            description: "Descrizione del servizio",
            iconName: "6.circle.fill"),
    ]
    
    
    var body: some View {
        ScrollView{
            VStack{
                Text("Scopri i nostri servizi")
                    .background(.green)
                
                LazyVGrid(columns: [
                    GridItem(.fixed(200)),
                    GridItem(.fixed(200))
                ]){
                    //non serve binda
                    ForEach(listaServizi) {
                        servizio in
                            ServiceCardView(bankService: servizio)
                    }
                }
            }
        }
    }
}

#Preview {
    ServicesView()
}
