//
//  Item.swift
//  MyDiary
//
//  Created by Davide Cidu on 16/07/2026.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
