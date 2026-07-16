//
//  AddEntryView.swift
//  MyDiary
//
//  Created by Davide Cidu on 16/07/2026.
//

import SwiftUI
import SwiftData
import PhotosUI

struct AddEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \Tag.name) private var allTags: [Tag]

    @State private var title: String = ""
    @State private var content: String = ""
    @State private var mood: Mood = .bored
    @State private var date: Date = Date()

    @State private var selectedTags: Set<Tag> = []
    @State private var newTagName: String = ""

    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var selectedImagesData: [Data] = []

    var body: some View {
        NavigationStack {
            Form {
                Section("Dettagli") {
                    TextField("Titolo", text: $title)
                    DatePicker("Data", selection: $date)
                }

                Section("Come ti senti?") {
                    Picker("Mood", selection: $mood) {
                        Text("Felice").tag(Mood.happy)
                        Text("Triste").tag(Mood.sad)
                        Text("Arrabbiato").tag(Mood.angry)
                        Text("Emozionato").tag(Mood.excited)
                        Text("Annoiato").tag(Mood.bored)
                    }
                }

                Section("Tag") {
                    ForEach(allTags) { tag in
                        Button {
                            toggleTag(tag)
                        } label: {
                            HStack {
                                Text(tag.name)
                                Spacer()
                                if selectedTags.contains(tag) {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                        .foregroundStyle(.primary)
                    }

                    HStack {
                        TextField("Nuovo tag", text: $newTagName)
                        Button("Aggiungi") {
                            addNewTag()
                        }
                        .disabled(newTagName.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }

                Section("Foto") {
                    PhotosPicker(selection: $selectedPhotos, matching: .images) {
                        Label("Aggiungi foto", systemImage: "photo.on.rectangle.angled")
                    }

                    if !selectedImagesData.isEmpty {
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(selectedImagesData, id: \.self) { data in
                                    if let uiImage = UIImage(data: data) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 80, height: 80)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                    }
                                }
                            }
                        }
                    }
                }

                Section("Racconta") {
                    TextEditor(text: $content)
                        .frame(minHeight: 150)
                }
            }
            .navigationTitle("Nuova voce")
            .onChange(of: selectedPhotos) { _, newItems in
                Task {
                    selectedImagesData = []
                    for item in newItems {
                        if let data = try? await item.loadTransferable(type: Data.self) {
                            selectedImagesData.append(data)
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salva") {
                        saveEntry()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }

    private func toggleTag(_ tag: Tag) {
        if selectedTags.contains(tag) {
            selectedTags.remove(tag)
        } else {
            selectedTags.insert(tag)
        }
    }

    private func addNewTag() {
        let trimmed = newTagName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        let tag = Tag(name: trimmed)
        modelContext.insert(tag)
        selectedTags.insert(tag)
        newTagName = ""
    }

    private func saveEntry() {
        let newEntry = DiaryEntry(title: title, date: date, content: content, mood: mood)
        newEntry.tags = Array(selectedTags)

        for data in selectedImagesData {
            let attachment = Attachment(imageData: data)
            attachment.entry = newEntry
            newEntry.attachments.append(attachment)
            modelContext.insert(attachment)
        }

        modelContext.insert(newEntry)
        dismiss()
    }
}

#Preview {
    AddEntryView()
        .modelContainer(for: DiaryEntry.self, inMemory: true)
}
