//
//  TransactionDetailView.swift
//  DemoApp
//
//  Created by Davide Cidu on 01/07/2026.
//

import SwiftUI

struct TransactionCellView: View {
    var transaction: Transaction
    
    var body: some View {
        HStack{
            VStack(alignment: .leading){
                Text(transaction.title)
                    .bold()
                    
                Text(transaction.date.formatted(date: .numeric, time: .omitted))
            }
            .padding()
            
            Spacer()
            
            VStack(alignment: .trailing){
                Text(transaction.amount.formatted(.currency(code: "EUR")))
                    .bold()
            }
            .padding()
                
        }
        .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        
        Spacer()
    }
}

#Preview {
    TransactionCellView(transaction:
        Transaction(id: "UUID()", title: "Accredito stipendio", date: Date(), amount: 1456.79, category: "Accredito")
    )
}
