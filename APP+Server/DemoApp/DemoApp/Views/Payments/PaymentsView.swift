//
//  PaymentsView.swift
//  DemoApp
//
//  Created by Davide Cidu on 01/07/2026.
//

import SwiftUI

struct PaymentsView: View {

    @Environment(SessionManager.self) private var session
    @State private var viewModel = PaymentsViewModel()

    var onPaymentCompleted: () -> Void = {}

    var body: some View {
        VStack {
            Text("Nuovo bonifico")
                .font(.largeTitle)
                .bold()
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading)
                .padding()

            Form {
                Section {
                    TextField("Nome e cognome", text: $viewModel.fullName)
                } header: {
                    Text("Beneficiario")
                }

                Section {
                    TextField("IBAN", text: $viewModel.iban)
                } header: {
                    Text("IBAN")
                }

                Section {
                    TextField("Importo", value: $viewModel.amount, format: .currency(code: "EUR"))
                        .keyboardType(.decimalPad)
                } header: {
                    Text("Importo")
                }

                Section {
                    TextField("Causale", text: $viewModel.causale)
                } header: {
                    Text("Causale")
                }

                Section {
                    DatePicker("Data", selection: $viewModel.date, displayedComponents: .date)
                } header: {
                    Text("Emissione")
                }
            }

            Button {
                Task {
                    let esito = await viewModel.invia(token: session.token)
                    switch esito {
                    case .successo:
                        onPaymentCompleted()
                    case .sessioneScaduta:
                        session.logout()
                    case .fallito:
                        break 
                    }
                }
            } label: {
                if viewModel.isSubmitting {
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
            .disabled(viewModel.isSubmitting)

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
                    .padding(.bottom, 16)
            }
        }
    }
}

#Preview {
    NavigationStack {
        PaymentsView()
    }
    .environment(SessionManager())
}
