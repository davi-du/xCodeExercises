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
}
