//
//  TransactionRequest.swift
//  DemoApp
//
//  Created by Davide Cidu on 13/07/2026.
//

import Foundation

struct TransactionRequest: Encodable {
    let title: String
    let date: String
    let amount: Double
    let category: String
    let beneficiary: String?
    let beneficiaryIban: String?
}
