//
//  SearchView.swift
//  MyDiary
//
//  Created by Davide Cidu on 16/07/2026.
//

import SwiftUI
import SwiftData

struct SearchView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Tag.name) private var allTags: [Tag]

    @State private var searchText = ""
    @State private var selectedMood: Mood? = nil
    @State private var selectedTag: Tag? = nil

    @State private var useDateFilter = false
    @State private var startDate = Date.now.addingTimeInterval(-30 * 24 * 3600)
    @State private var endDate = Date.now

    @State private var results: [DiaryEntry] = []

    var body: some View {
        NavigationStack {
            List {
                Section("Testo") {
                    TextField("Cerca in titolo o contenuto", text: $searchText)
                }

                Section("Mood") {
                    Picker("Mood", selection: $selectedMood) {
                        Text("Tutti").tag(Mood?.none)
                        Text("😊 Felice").tag(Mood?.some(.happy))
                        Text("😢 Triste").tag(Mood?.some(.sad))
                        Text("😠 Arrabbiato").tag(Mood?.some(.angry))
                        Text("🤩 Emozionato").tag(Mood?.some(.excited))
                        Text("😐 Annoiato").tag(Mood?.some(.bored))
                    }
                }

                Section("Tag") {
                    Picker("Tag", selection: $selectedTag) {
                        Text("Tutti").tag(Tag?.none)
                        ForEach(allTags) { tag in
                            Text(tag.name).tag(Tag?.some(tag))
                        }
                    }
                }

                Section {
                    Toggle("Filtra per data", isOn: $useDateFilter)
                    if useDateFilter {
                        DatePicker("Da", selection: $startDate, displayedComponents: .date)
                        DatePicker("A", selection: $endDate, displayedComponents: .date)
                    }
                }

                Section {
                    Button("Cerca") {
                        runSearch()
                    }
                }

                Section("Risultati") {
                    if results.isEmpty {
                        Text("Nessuna voce trovata")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(results) { entry in
                            NavigationLink {
                                EntryDetailView(entry: entry)
                            } label: {
                                VStack(alignment: .leading) {
                                    Text(entry.title).font(.headline)
                                    Text(entry.date, format: .dateTime.day().month().year())
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Ricerca")
            .onAppear { runSearch() }
        }
    }

    private func runSearch() {
        // Catturiamo i valori in costanti locali: #Predicate ne ha bisogno
        // per generare codice compilato, non può leggere @State direttamente "al volo"
        let text = searchText
        let dateActive = useDateFilter
        let start = startDate
        let end = endDate

        let predicate = #Predicate<DiaryEntry> { entry in
            (text.isEmpty || entry.title.localizedStandardContains(text) || entry.content.localizedStandardContains(text))
            && (!dateActive || (entry.date >= start && entry.date <= end))
        }

        let descriptor = FetchDescriptor<DiaryEntry>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )

        do {
            var fetched = try modelContext.fetch(descriptor)

            if let mood = selectedMood {
                fetched = fetched.filter { $0.mood == mood }
            }

            if let tag = selectedTag {
                fetched = fetched.filter { entry in
                    entry.tags.contains(where: { $0.persistentModelID == tag.persistentModelID })
                }
            }

            results = fetched
        } catch {
            print("Errore nella ricerca: \(error)")
            results = []
        }
    }
}
