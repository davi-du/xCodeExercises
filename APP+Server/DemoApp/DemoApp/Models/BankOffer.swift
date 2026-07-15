//
//  BankService.swift
//  DemoApp
//
//  Created by Davide Cidu on 01/07/2026.
//

import Foundation

struct BankOffer : Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let iconName: String
}
