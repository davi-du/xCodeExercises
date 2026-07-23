//
//  DocumentSummary.swift
//  DemoApp
//
//  Created by Davide Cidu on 14/07/2026.
//

import Foundation

struct DocumentSummary: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let date: Date
    let type: String
}
