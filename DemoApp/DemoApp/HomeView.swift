//
//  HomeView.swift
//  DemoApp
//
//  Created by Davide Cidu on 01/07/2026.
//

import SwiftUI

struct HomeView: View {
    
    var user = "Mario Rossi"
    var numeroConto = "4236352448"
    var saldo : Decimal = 999.99
    var iban = "BE44 2000 1234 5678"
    var listaMovimenti : [Transaction] = [
        Transaction(
            id: UUID(),
            title: "Spesa supermercato",
            date: Date(),
            amount: -42.80,
            category: "Spesa"
        ),
        
        Transaction(
            id: UUID(),
            title: "Spesa supermercato",
            date: Date(),
            amount: -42.80,
            category: "Spesa"
        ),
        
        Transaction(
            id: UUID(),
            title: "Spesa supermercato",
            date: Date(),
            amount: -42.80,
            category: "Spesa"
        ),
        
        Transaction(
            id: UUID(),
            title: "Spesa supermercato",
            date: Date(),
            amount: -42.80,
            category: "Spesa"
        ),
        
        Transaction(
            id: UUID(),
            title: "Spesa supermercato",
            date: Date(),
            amount: -42.80,
            category: "Spesa"
        ),
        
        Transaction(
            id: UUID(),
            title: "Spesa supermercato",
            date: Date(),
            amount: -42.80,
            category: "Spesa"
        ),
        
        Transaction(
            id: UUID(),
            title: "Spesa supermercato",
            date: Date(),
            amount: -42.80,
            category: "Spesa"
        ),
        
        Transaction(
            id: UUID(),
            title: "Spesa supermercato",
            date: Date(),
            amount: -42.80,
            category: "Spesa"
        ),
        
        Transaction(
            id: UUID(),
            title: "Spesa supermercato",
            date: Date(),
            amount: -42.80,
            category: "Spesa"
        ),
        
        Transaction(
            id: UUID(),
            title: "Spesa supermercato",
            date: Date(),
            amount: -42.80,
            category: "Spesa"
        ),
        
        Transaction(
            id: UUID(),
            title: "Spesa supermercato",
            date: Date(),
            amount: -42.80,
            category: "Spesa"
        ),
        
        Transaction(
            id: UUID(),
            title: "Spesa supermercato",
            date: Date(),
            amount: -42.80,
            category: "Spesa"
        ),
        
        Transaction(
            id: UUID(),
            title: "Spesa supermercato",
            date: Date(),
            amount: -42.80,
            category: "Spesa"
        ),
        
        Transaction(
            id: UUID(),
            title: "Spesa supermercato",
            date: Date(),
            amount: -42.80,
            category: "Spesa"
        ),
        
        Transaction(
            id: UUID(),
            title: "Spesa supermercato",
            date: Date(),
            amount: -42.80,
            category: "Spesa"
        ),
    ]
    
    var data = Date().formatted(date: .numeric, time: .omitted)
    
    var body: some View {
        
            ScrollView{
                VStack {
                    //header messaggio benevuto
                    VStack{
                        Text("Benvenuto")
                        Text(user)
                    }
                    .background(.gray)
                    
                    //card per saldo e iban
                    VStack{
                        //saldo e data
                        VStack{
                            Text(saldo.formatted(.currency(code: "EUR")))
                            Text("Saldo al \(data)")
                        }
                        //IBAN
                        HStack{
                            Text("IBAN: \(iban)")
                            Button {
                                //action copia iban
                                print("IBAN copiato")
                            } label: {
                                Image(systemName: "document.on.document.fill")
                            }
                        }
                    }
                    .background(.green)
                    
                    //lista movimenti
                    LazyVStack{
                        ForEach(listaMovimenti) {
                            movimento in
                            HStack{
                                VStack{
                                    Text(movimento.title)
                                        .bold()
                                    Text(movimento.date.formatted(date: .numeric, time: .omitted))
                                }
                                Text(movimento.amount.formatted(.currency(code: "EUR")))
                            }
                            Spacer()
                        }
                    }
                    .background(.blue)
                    
                }.padding()
            }
        
    }
}

#Preview {
    HomeView()
}
