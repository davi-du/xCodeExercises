//
//  DiaryEntry.swift
//  MyDiary
//
//  Created by Davide Cidu on 16/07/2026.
//

import Foundation
import SwiftData

nonisolated enum Mood: Codable, CaseIterable {
    case happy, sad, angry, excited, bored
}

@Model
class DiaryEntry {
    var title: String
    var date: Date
    var content: String
    var mood: Mood

    @Relationship(inverse: \Tag.entries)
    var tags: [Tag] = []
    
    @Relationship(deleteRule: .cascade, inverse: \Attachment.entry)
    var attachments: [Attachment] = []

    init(title: String, date: Date, content: String, mood: Mood) {
        self.title = title
        self.date = date
        self.content = content
        self.mood = mood
    }
}
