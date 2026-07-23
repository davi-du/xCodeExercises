//
//  SessionManager.swift
//  DemoApp
//

import Foundation
import Observation

@Observable
class SessionManager {

    private let keychainService = "com.demoapp.auth"
    private let tokenAccount = "authToken"
    private let usernameAccount = "authUsername"

    private(set) var token: String?
    private(set) var username: String?

    var isAuthenticated: Bool {
        token != nil
    }

    init() {
        ///all'avvio provo a recuperare token e username salvati da una sessione precedente.
        if let tokenData = KeychainHelper.read(service: keychainService, account: tokenAccount),
           let savedToken = String(data: tokenData, encoding: .utf8) {
            token = savedToken
        }
        if let usernameData = KeychainHelper.read(service: keychainService, account: usernameAccount),
           let savedUsername = String(data: usernameData, encoding: .utf8) {
            username = savedUsername
        }
    }

    @MainActor
    func login(username: String, password: String) async throws {
        let response = try await CustomerService.login(username: username, password: password)

        token = response.token
        self.username = username

        if let tokenData = response.token.data(using: .utf8) {
            KeychainHelper.save(tokenData, service: keychainService, account: tokenAccount)
        }
        if let usernameData = username.data(using: .utf8) {
            KeychainHelper.save(usernameData, service: keychainService, account: usernameAccount)
        }
    }

    func logout() {
        token = nil
        username = nil
        KeychainHelper.delete(service: keychainService, account: tokenAccount)
        KeychainHelper.delete(service: keychainService, account: usernameAccount)
    }
}
