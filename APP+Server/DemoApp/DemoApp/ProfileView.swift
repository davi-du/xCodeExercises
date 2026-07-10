//
//  ProfileView.swift
//  DemoApp
//
//  Created by Davide Cidu on 01/07/2026.
//

import SwiftUI
import UIKit

struct ProfileView: View {

    @Environment(SessionManager.self) private var session

    let costumer: CostumerProfile

    @State private var ibanCopiato = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Image(systemName: "person.circle.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 100))

                    Text(costumer.fullName)
                        .font(.title2)
                        .bold()
                }
                .padding(.top)

                // Dati personali
                VStack(spacing: 0) {
                    ProfileInfoRow(label: "Data di nascita", value: costumer.birthdate.formatted(date: .numeric, time: .omitted))
                    Divider().padding(.leading)
                    ProfileInfoRow(label: "Email", value: costumer.email)
                    Divider().padding(.leading)
                    ProfileInfoRow(label: "Telefono", value: costumer.phone)
                    Divider().padding(.leading)
                    ProfileInfoRow(label: "Codice cliente", value: costumer.costumerCode)
                    Divider().padding(.leading)
                    ProfileInfoRow(label: "Indirizzo", value: costumer.address)
                }
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
                )
                .padding(.horizontal)

                // Dati conto: saldo e IBAN
                VStack(spacing: 0) {
                    ProfileInfoRow(label: "Saldo disponibile", value: costumer.accountBalance.formatted(.currency(code: "EUR")))

                    Divider().padding(.leading)

                    HStack(alignment: .center) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("IBAN")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(costumer.iban)
                                .font(.subheadline)
                        }

                        Spacer()

                        Button {
                            copiaIban()
                        } label: {
                            Image(systemName: ibanCopiato ? "checkmark" : "document.on.document.fill")
                                .foregroundColor(ibanCopiato ? .green : .blue)
                        }
                        .accessibilityLabel("Copia IBAN")
                    }
                    .padding()
                }
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
                )
                .padding(.horizontal)

                Button(role: .destructive) {
                    session.logout()
                } label: {
                    Text("Esci")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.bordered)
                .padding(.horizontal)

                Spacer(minLength: 20)
            }
        }
        .background(Color(white: 0.95).ignoresSafeArea())
    }

    private func copiaIban() {
        UIPasteboard.general.string = costumer.iban
        ibanCopiato = true

        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            ibanCopiato = false
        }
    }
}

private struct ProfileInfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .top) {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .multilineTextAlignment(.trailing)
        }
        .padding()
    }
}

#Preview {
    ProfileView(costumer:
        CostumerProfile(
            firstName: "Antonio",
            secondName: "Bianchi",
            birthdate: {
                let isoDate = "1987-04-14T10:44:00+0000"
                let dateFormatter = ISO8601DateFormatter()
                return dateFormatter.date(from: isoDate)!
            }(),
            email: "antoniobianchi@avanade.com",
            phone: "+39 xxxxxxxxxx",
            costumerCode: "ba1324",
            iban: "ITXXXXXXXXXXXXXXXXXXXXXXXXX",
            address: "Via Roma, 14, 00185 Roma RM, Italia",
            accountBalance: 999.99
        )
    )
    .environment(SessionManager())
}
