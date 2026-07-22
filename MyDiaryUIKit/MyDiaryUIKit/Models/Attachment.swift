//
//  Attachment.swift
//  MyDiary
//
//  Created by Davide Cidu on 16/07/2026.
//

import Foundation
import SwiftData

@Model
class Attachment {
    @Attribute(.externalStorage)
    var imageData: Data

    var entry: DiaryEntry?

    init(imageData: Data) {
        self.imageData = imageData
    }
}
