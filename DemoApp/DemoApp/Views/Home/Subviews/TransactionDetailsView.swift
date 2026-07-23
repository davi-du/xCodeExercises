//
//  TransactionDetailsView.swift
//  DemoApp
//
//  Created by Davide Cidu on 01/07/2026.
//
import SwiftUI

struct TransactionDetailsView: View {
    var transaction: Transaction
    
    var body: some View {
        
        VStack{
            Image(systemName: "dollarsign.circle.fill")
                .foregroundColor(.blue)
                .font(.system(size: 60))
                .frame(alignment: .topLeading)
                .padding(.top)
            
            VStack(alignment: .center){
                Text(transaction.title)
                    .bold()
                    .padding(.bottom)
                
                HStack{
                    Text("Data \(transaction.date.formatted(date: .numeric, time: .omitted))")
                    
                    Spacer()
                    
                    Text("Importo \(transaction.amount.formatted(.currency(code: "EUR")))")
                }

                if let beneficiary = transaction.beneficiary, !beneficiary.isEmpty {
                    HStack {
                        Text("Beneficiario \(beneficiary)")
                        Spacer()
                    }
                    .padding(.top, 6)
                }

                if let iban = transaction.beneficiaryIban, !iban.isEmpty {
                    HStack {
                        Text("IBAN \(iban)")
                            .font(.caption)
                        Spacer()
                    }
                }

            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    TransactionDetailsView(transaction:
        Transaction(id: UUID().uuidString, title: "Accredito stipendio", date: Date(), amount: 1456.79, category: "Accredito")
    )
}

#Preview("Bonifico con beneficiario") {
    TransactionDetailsView(transaction:
        Transaction(
            id: UUID().uuidString,
            title: "Affitto luglio",
            date: Date(),
            amount: -650.00,
            category: "Bonifico",
            beneficiary: "Mario Rossi",
            beneficiaryIban: "IT60X0542811101000000123456"
        )
    )
}
