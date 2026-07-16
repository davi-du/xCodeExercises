//
//  Tag.swift
//  MyDiary
//
//  Created by Davide Cidu on 16/07/2026.
//

import Foundation
import SwiftData

@Model
class Tag {
    var name: String

    var entries: [DiaryEntry] = []

    init(name: String) {
        self.name = name
    }
}
