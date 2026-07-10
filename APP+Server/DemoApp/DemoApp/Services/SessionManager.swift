//
//  SessionManager.swift
//  DemoApp
//
//  Created by Davide Cidu on 10/07/2026.
//

import Foundation

@Observable
class SessionManager {

    private let keychainService = "com.demoapp.auth"
    private let keychainAccount = "authToken"

    private(set) var token: String?

    var isAuthenticated: Bool {
        token != nil
    }

    init() {
        // all'avvio provo a recuperare un token salvato da una sessione precedente
        if let data = KeychainHelper.read(service: keychainService, account: keychainAccount),
           let savedToken = String(data: data, encoding: .utf8) {
            token = savedToken
        }
    }

    @MainActor
    func login(username: String, password: String) async throws {
        let response = try await CustomerService.login(username: username, password: password)

        token = response.token

        if let data = response.token.data(using: .utf8) {
            KeychainHelper.save(data, service: keychainService, account: keychainAccount)
        }
    }

    func logout() {
        token = nil
        KeychainHelper.delete(service: keychainService, account: keychainAccount)
    }
}
