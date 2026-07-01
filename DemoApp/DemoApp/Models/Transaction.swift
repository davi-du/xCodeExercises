//
//  Transaction.swift
//  DemoApp
//
//  Created by Davide Cidu on 01/07/2026.
//

import Foundation

struct Transaction : Identifiable {
    let id : UUID
    let title : String
    let date : Date
    let amount : Decimal
    let category : String
}
