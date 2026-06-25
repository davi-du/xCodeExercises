//
//  NightWatchTask.swift
//  NightWatch
//
//  Created by Davide Cidu on 23/06/2026.
//

import Foundation

struct NightWatchTask: Identifiable {
    let id: UUID  // ← tipo esplicito, senza inizializzazione inline
    let name: String
    var isCompleted: Bool
    var lastCompleted: Date?

    init(name: String, isCompleted: Bool, lastCompleted: Date? = nil) {
        self.id = UUID()  // ← generato una volta sola nell'init
        self.name = name
        self.isCompleted = isCompleted
        self.lastCompleted = lastCompleted
    }
}
