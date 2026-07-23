//
//  LoginView.swift
//  DemoApp
//

import SwiftUI

struct LoginView: View {

    @Environment(SessionManager.self) private var session
    @State private var viewModel = LoginViewModel()

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
                TextField("Nome utente", text: $viewModel.username)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color(white: 0.95)))

                SecureField("Password", text: $viewModel.password)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color(white: 0.95)))
            }
            .padding(.horizontal, 30)

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
            }

            Button {
                Task { await viewModel.login(session: session) }
            } label: {
                if viewModel.isLoggingIn {
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
            .disabled(viewModel.isLoggingIn || viewModel.username.trimmingCharacters(in: .whitespaces).isEmpty || viewModel.password.isEmpty)
            .padding(.horizontal, 30)

            Spacer()
        }
    }
}

#Preview {
    LoginView()
        .environment(SessionManager())
}
