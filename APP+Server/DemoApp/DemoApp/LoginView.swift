//
//  LoginView.swift
//  DemoApp
//
//  Created by Davide Cidu on 10/07/2026.
//

import SwiftUI

// la pw è Demo1234!
struct LoginView: View {

    @Environment(SessionManager.self) private var session

    @State private var username = ""
    @State private var password = ""
    @State private var isLoggingIn = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "building.columns.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
                .padding(.top, 60)

            Text("Accedi")
                .font(.largeTitle)
                .bold()

            VStack(spacing: 16) {
                TextField("Nome utente", text: $username)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color(white: 0.95)))

                SecureField("Password", text: $password)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color(white: 0.95)))
            }
            .padding(.horizontal, 30)

            if let errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
            }

            Button {
                Task { await effettuaLogin() }
            } label: {
                if isLoggingIn {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                } else {
                    Text("Accedi")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isLoggingIn || username.trimmingCharacters(in: .whitespaces).isEmpty || password.isEmpty)
            .padding(.horizontal, 30)

            Spacer()
        }
    }

    private func effettuaLogin() async {
        errorMessage = nil
        isLoggingIn = true

        do {
            try await session.login(username: username, password: password)
        } catch APIError.unauthorized {
            errorMessage = "Nome utente o password non corretti."
        } catch {
            errorMessage = "Accesso non riuscito, riprova."
        }

        isLoggingIn = false
    }
}

#Preview {
    LoginView()
        .environment(SessionManager())
}
