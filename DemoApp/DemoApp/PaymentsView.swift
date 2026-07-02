//
//  PaymentsView.swift
//  DemoApp
//
//  Created by Davide Cidu on 01/07/2026.
//

import SwiftUI

struct PaymentsView: View {
    
    @State private var fullName = ""
    @State private var iban = ""
    @State private var amount: Decimal = 0
    @State private var causale = ""
    @State private var date = Date()
    
    var onSubmit: (PaymentRequest) -> Void = { _ in } // mi serve dopo
        
    
    var body: some View {
        VStack{
            Text("Nuovo bonifico")
                .font(.largeTitle)
                .bold()
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading)
                .padding()
            
            Form {
                //beneciciario
                Section {
                    TextField("Nome e cognome", text: $fullName)
                } header: {
                    Text("Beneficiario")
                }
                //iban
                Section {
                    TextField("IBAN", text: $iban)
                } header: {
                    Text("IBAN")
                }
                //importo
                Section {
                    TextField("Importo", value: $amount, format: .currency(code: "EUR"))
                        .keyboardType(.decimalPad)
                } header: {
                    Text("Importo")
                }
                //causale
                Section {
                    TextField("Causale", text: $causale)
                } header: {
                    Text("Causale")
                }
                //data
                Section {
                    DatePicker("Data ", selection: $date, displayedComponents: .date)
                } header: {
                    Text("Emissione")
                }
            }
            
            Button {
                onSubmit(
                    PaymentRequest(
                        fullName: fullName,
                        iban: iban,
                        amount: amount,
                        causale: causale,
                        date: date
                    )
                )
            } label: {
                Text("Paga")
                    .font(.title3)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 50)
            .padding(.bottom, 24)
    
        }
    }
}

struct PaymentRequest {
    let fullName: String
    let iban: String
    let amount: Decimal
    let causale: String
    let date: Date
}

#Preview {
    NavigationStack {
        PaymentsView()
    }
}
