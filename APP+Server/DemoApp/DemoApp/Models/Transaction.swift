//
//  Transaction.swift
//  DemoApp
//
//  Created by Davide Cidu on 01/07/2026.
//

import Foundation

struct Transaction: Decodable, Identifiable {
    //let id : UUID
    let id: String
    let title: String
    let date: Date
    let amount: Double
    let category: String

    let beneficiary: String?
    let beneficiaryIban: String?

    init(
        id: String,
        title: String,
        date: Date,
        amount: Double,
        category: String,
        beneficiary: String? = nil,
        beneficiaryIban: String? = nil
    ) {
        self.id = id
        self.title = title
        self.date = date
        self.amount = amount
        self.category = category
        self.beneficiary = beneficiary
        self.beneficiaryIban = beneficiaryIban
    }
}
