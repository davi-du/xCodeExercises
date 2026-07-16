//
//  EntryDetailView.swift
//  MyDiary
//
//  Created by Davide Cidu on 16/07/2026.
//

import SwiftUI
import SwiftData

struct EntryDetailView: View {
    let entry: DiaryEntry

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(entry.title)
                    .font(.largeTitle)
                    .bold()

                Text(entry.date, format: Date.FormatStyle(date: .complete, time: .shortened))
                    .foregroundStyle(.secondary)

                Text(moodLabel(entry.mood))
                    .font(.subheadline)
                    .padding(.vertical, 4)

                if !entry.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(entry.tags) { tag in
                                Text(tag.name)
                                    .font(.caption)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color.blue.opacity(0.15))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }

                if !entry.attachments.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(entry.attachments) { attachment in
                                if let uiImage = UIImage(data: attachment.imageData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 120, height: 120)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                            }
                        }
                    }
                }

                Divider()

                Text(entry.content)
                    .font(.body)
            }
            .padding()
        }
        .navigationTitle("Dettaglio")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func moodLabel(_ mood: Mood) -> String {
        switch mood {
        case .happy: return "😊 Felice"
        case .sad: return "😢 Triste"
        case .angry: return "😠 Arrabbiato"
        case .excited: return "🤩 Emozionato"
        case .bored: return "😐 Annoiato"
        }
    }
}

#Preview {
    NavigationStack {
        EntryDetailView(entry: DiaryEntry(title: "Prova", date: .now, content: "Contenuto di esempio", mood: .happy))
    }
}
