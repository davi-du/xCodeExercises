//
//  ContentViewModel.swift
//  DemoApp
//

import Foundation
import Observation

@Observable
class ContentViewModel {

    var costumer: CostumerProfile?
    var transactions: [Transaction] = []
    var isLoading = false
    var errorMessage: String?
    var selectedTab: Int = 0

    /// Carica i dati del cliente autenticato.
    /// Ritorna `false` se il token non e piu valido (401)
    func loadData(token: String) async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            let result = try await CustomerService.fetchCustomerData(token: token)
            costumer = result.customer
            transactions = result.transactions.sorted { $0.date > $1.date }
            isLoading = false
            return true
        } catch APIError.unauthorized {
            isLoading = false
            return false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return true
        }
    }

    func reset() {
        costumer = nil
        transactions = []
        errorMessage = nil
    }
}
