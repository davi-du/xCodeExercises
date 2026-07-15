//
//  HomeView.swift
//  DemoApp
//
//  Created by Davide Cidu on 01/07/2026.
//

import SwiftUI

struct HomeView: View {
    
    let costumer: CostumerProfile
    
    var transactionList : [Transaction]
    
    var data = Date().formatted(date: .numeric, time: .omitted)
    
    @State private var isBalanceVisible = true
    @State private var selectedTransaction: Transaction? = nil
    
    var body: some View {
        
        NavigationStack{
            VStack{
                /// header messaggio benevuto
                HStack{
                    VStack(alignment: .leading){
                        Text("Benvenuto")
                            .font(.title3)
                            
                        Text(costumer.fullName)
                            .font(.title)
                            .bold()
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Image(systemName: "dollarsign.bank.building")
                        .padding(.trailing)
                        .foregroundColor(.white)
                        .font(.system(size: 50))
                }
        
                
                /// card per saldo
                VStack{
                    /// saldo e data
                    VStack(alignment: .leading){
                        HStack {
                            if isBalanceVisible {
                                Text(costumer.accountBalance.formatted(.currency(code: "EUR")))
                                    .font(.title)
                                    .bold()
                            } else {
                                Text("••••••")
                                    .font(.title)
                                    .bold()
                            }
                            
                            Button(action: {
                                isBalanceVisible.toggle()
                            }) {
                                Image(systemName: isBalanceVisible ? "eye" : "eye.slash")
                            }
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .padding(.bottom, 10)
                        
                        Text("Saldo al:")
                            .font(.caption2)
                        Text(data)
                            .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    
                }
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                )
                .padding(.horizontal, 35)
                .padding(.bottom)
            }
            .frame(maxWidth: .infinity)
            .background(
                Color.blue
                    .cornerRadius(12)
                    .ignoresSafeArea(edges: .top)
            )
            
            ScrollView {
                LazyVStack {
                    ForEach(transactionList) { transaction in
                        Button {
                            selectedTransaction = transaction
                        } label: {
                            TransactionCellView(transaction: transaction)
                                .foregroundColor(.black)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .sheet(item: $selectedTransaction) { transaction in
                TransactionDetailsView(transaction: transaction)
                    .presentationDetents([.height(200)])
                    .presentationCornerRadius(24)
            }
        }
    }
}

#Preview {
    HomeView(costumer:
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
            address: "Via Roma, 14, 00185 Roma RM, Italia",
            accountBalance: 1456.12
        ),
             transactionList: [
                Transaction(
                    id: UUID().uuidString,
                    title: "Spesa supermercato",
                    date: Date(),
                    amount: -42.80,
                    category: "Spesa"
                ),
                
                Transaction(
                    id: UUID().uuidString,
                    title: "Spesa supermercato",
                    date: Date(),
                    amount: -42.80,
                    category: "Spesa"
                ),
                
                Transaction(
                    id: UUID().uuidString,
                    title: "Spesa supermercato",
                    date: Date(),
                    amount: -42.80,
                    category: "Spesa"
                ),
                
                Transaction(
                    id: UUID().uuidString,
                    title: "Spesa supermercato",
                    date: Date(),
                    amount: -42.80,
                    category: "Spesa"
                ),
                
                Transaction(
                    id: UUID().uuidString,
                    title: "Spesa supermercato",
                    date: Date(),
                    amount: -42.80,
                    category: "Spesa"
                ),
                
                Transaction(
                    id: UUID().uuidString,
                    title: "Spesa supermercato",
                    date: Date(),
                    amount: -42.80,
                    category: "Spesa"
                ),
                
                Transaction(
                    id: UUID().uuidString,
                    title: "Spesa supermercato",
                    date: Date(),
                    amount: -42.80,
                    category: "Spesa"
                ),
                
                Transaction(
                    id: UUID().uuidString,
                    title: "Spesa supermercato",
                    date: Date(),
                    amount: -42.80,
                    category: "Spesa"
                ),
                
                Transaction(
                    id: UUID().uuidString,
                    title: "Spesa supermercato",
                    date: Date(),
                    amount: -42.80,
                    category: "Spesa"
                ),
                
                Transaction(
                    id: UUID().uuidString,
                    title: "Spesa supermercato",
                    date: Date(),
                    amount: -42.80,
                    category: "Spesa"
                ),
                
                
            ]
    )
}
