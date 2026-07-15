//
//  PaymentsViewModel.swift
//  DemoApp
//

import Foundation
import Observation

enum EsitoPagamento {
    case successo
    case sessioneScaduta
    case fallito
}

@Observable
class PaymentsViewModel {

    var fullName = ""
    var iban = ""
    var amount: Decimal = 0
    var causale = ""
    var date = Date()

    var isSubmitting = false
    var errorMessage: String?

    private func valida() -> String? {
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

    func invia(token: String?) async -> EsitoPagamento {
        errorMessage = nil

        if let messaggio = valida() {
            errorMessage = messaggio
            return .fallito
        }

        guard let token else {
            errorMessage = "Sessione scaduta, accedi di nuovo."
            return .sessioneScaduta
        }

        isSubmitting = true

        do {
            let amountDouble = -(NSDecimalNumber(decimal: amount).doubleValue)

            _ = try await CustomerService.addTransaction(
                title: causale,
                date: date,
                amount: amountDouble,
                category: "Bonifico",
                beneficiary: fullName,
                beneficiaryIban: iban,
                token: token
            )

            resetForm()
            isSubmitting = false
            return .successo

        } catch APIError.unauthorized {
            errorMessage = "Sessione scaduta, accedi di nuovo."
            isSubmitting = false
            return .sessioneScaduta
        } catch {
            errorMessage = "Invio non riuscito, riprova."
            isSubmitting = false
            return .fallito
        }
    }

    private func resetForm() {
        fullName = ""
        iban = ""
        amount = 0
        causale = ""
        date = Date()
    }
}
