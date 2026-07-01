//
//  CostumerProfile.swift
//  DemoApp
//
//  Created by Davide Cidu on 01/07/2026.
//

import Foundation

struct CostumerProfile {
    let firstName: String
    let secondName: String
    let birthdate: Date
    let email: String
    let phone: String
    let costumerCode: String
    let iban: String
    let address: String
    
    var fullName: String {
        return "\(firstName) \(secondName)"
    }
}
