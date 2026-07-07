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
    
    @State private var isSubmitting = false
    @State private var errorMessage: String?
    
    private func validaForm() -> String? {
        if fullName.trimmingCharacters(in: .whitespaces).isEmpty {
            return "Inserisci nome e cognome del beneficiario."
        }
        if iban.trimmingCharacters(in: .whitespaces).isEmpty {
            return "Inserisci l'IBAN."
        }
        if amount <= 0 {
            return "Inserisci un importo maggiore di zero."
        }
        if causale.trimmingCharacters(in: .whitespaces).isEmpty {
            return "Inserisci una causale."
        }
        return nil
    }
    
    var onPaymentCompleted: () -> Void = {}
    
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
                // Validazione PRIMA di avviare la richiesta di rete
                if let messaggioErrore = validaForm() {
                    errorMessage = messaggioErrore
                    return
                }

                Task {
                    isSubmitting = true
                    errorMessage = nil
                    do {
                        let amountDouble = -(NSDecimalNumber(decimal: amount).doubleValue)

                        _ = try await CustomerService.addTransaction(
                            title: causale,
                            date: date,
                            amount: amountDouble,
                            category: "Bonifico"
                        )

                        fullName = ""
                        iban = ""
                        amount = 0
                        causale = ""
                        date = Date()

                        isSubmitting = false
                        onPaymentCompleted()

                    } catch {
                        print("Errore invio pagamento: \(error)")
                        errorMessage = "Invio non riuscito, riprova."
                        isSubmitting = false
                    }
                }
            } label: {
                if isSubmitting {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                } else {
                    Text("Paga")
                        .font(.title3)
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 50)
            .padding(.bottom, 8)
            .disabled(isSubmitting)

            if let errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
                    .padding(.bottom, 16)
            }
            
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
