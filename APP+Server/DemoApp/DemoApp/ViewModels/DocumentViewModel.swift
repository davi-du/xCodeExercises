//
//  DocumentViewModel.swift
//  DemoApp
//
//  Created by Davide Cidu on 14/07/2026.
//

import Foundation
import Observation

@Observable
class DocumentsViewModel {

    var documents: [DocumentSummary] = []
    var isLoading = false
    var errorMessage: String?

    /// Ritorna false se il token non e piu valido (401): la view decide cosa fare
    /// (tipicamente chiamare session.logout()),  stesso pattern di ContentViewModel.
    func loadDocuments(token: String) async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            documents = try await CustomerService.fetchDocuments(token: token)
                .sorted { $0.date > $1.date }
            isLoading = false
            return true
        } catch APIError.unauthorized {
            isLoading = false
            return false
        } catch {
            errorMessage = "Impossibile caricare i documenti."
            isLoading = false
            return true
        }
    }
}
