//
//  APIResponse.swift
//  DemoApp
//
//  Created by Davide Cidu on 02/07/2026.
//

import Foundation

struct APIResponse: Codable {
    let customer: CostumerProfile
    let transactions: [Transaction]
}
