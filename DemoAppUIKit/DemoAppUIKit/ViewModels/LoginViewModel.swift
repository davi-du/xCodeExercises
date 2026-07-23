//
//  LoginViewModel.swift
//  DemoApp
//

import Foundation
import Observation

@Observable
class LoginViewModel {

    var username = ""
    var password = ""
    var isLoggingIn = false
    var errorMessage: String?

    func login(session: SessionManager) async {
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
