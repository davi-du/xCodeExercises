//
//  StatsView.swift
//  MyDiary
//
//  Created by Davide Cidu on 16/07/2026.
//

import SwiftUI
import SwiftData
import Charts

struct MoodStat: Identifiable {
    let id = UUID()
    let label: String
    let count: Int
}

struct StatsView: View {
    @Query private var entries: [DiaryEntry]

    @State private var displayedMonth: Date = Date()
    @State private var selectedDate: Date? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading) {
                        Text("Mood")
                            .font(.headline)

                        Chart(moodStats) { stat in
                            BarMark(
                                x: .value("Mood", stat.label),
                                y: .value("Numero", stat.count)
                            )
                            .foregroundStyle(.blue)
                        }
                        .frame(height: 220)
                    }
                    .padding(.horizontal)

                    VStack(alignment: .leading) {
                        HStack {
                            Text(monthTitle)
                                .font(.headline)

                            Spacer()

                            Button {
                                changeMonth(by: -1)
                            } label: {
                                Image(systemName: "chevron.left")
                            }

                            Button {
                                changeMonth(by: 1)
                            } label: {
                                Image(systemName: "chevron.right")
                            }
                        }

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                            ForEach(currentMonthDates, id: \.self) { date in
                                let count = entryCount(for: date)
                                let isSelected = selectedDate.map { Calendar.current.isDate($0, inSameDayAs: date) } ?? false

                                Text("\(Calendar.current.component(.day, from: date))")
                                    .font(.caption)
                                    .foregroundStyle(isSelected ? .white : .primary)
                                    .frame(maxWidth: .infinity, minHeight: 32)
                                    .background(
                                        isSelected
                                        ? Color.blue
                                        : (count > 0 ? Color.blue.opacity(min(0.15 * Double(count), 0.6)) : Color.clear)
                                    )
                                    .clipShape(Circle())
                                    .contentShape(Circle())
                                    .onTapGesture {
                                        if isSelected {
                                            selectedDate = nil
                                        } else {
                                            selectedDate = date
                                        }
                                    }
                            }
                        }

                        if let selectedDate {
                            VStack(alignment: .leading, spacing: 8) {
                                Divider()
                                    .padding(.vertical, 4)

                                Text(selectedDate.formatted(.dateTime.day().month(.wide)))
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)

                                let dayEntries = entries.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }

                                if dayEntries.isEmpty {
                                    Text("Nessuna voce in questo giorno")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                } else {
                                    ForEach(dayEntries) { entry in
                                        NavigationLink {
                                            EntryDetailView(entry: entry)
                                        } label: {
                                            Text(entry.title)
                                                .font(.callout)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Statistiche")
        }
    }

    private var moodStats: [MoodStat] {
        Mood.allCases.map { mood in
            let count = entries.filter { $0.mood == mood }.count
            return MoodStat(label: moodLabel(mood), count: count)
        }
    }

    private func moodLabel(_ mood: Mood) -> String {
        switch mood {
        case .happy: return "😊"
        case .sad: return "😢"
        case .angry: return "😠"
        case .excited: return "🤩"
        case .bored: return "😐"
        }
    }

    private var monthTitle: String {
        displayedMonth.formatted(.dateTime.month(.wide).year())
    }

    private func changeMonth(by value: Int) {
        if let newMonth = Calendar.current.date(byAdding: .month, value: value, to: displayedMonth) {
            displayedMonth = newMonth
            selectedDate = nil
        }
    }

    private var currentMonthDates: [Date] {
        let calendar = Calendar.current
        guard let monthInterval = calendar.dateInterval(of: .month, for: displayedMonth) else { return [] }

        var dates: [Date] = []
        var current = monthInterval.start
        while current < monthInterval.end {
            dates.append(current)
            current = calendar.date(byAdding: .day, value: 1, to: current)!
        }
        return dates
    }

    private func entryCount(for date: Date) -> Int {
        let calendar = Calendar.current
        return entries.filter { calendar.isDate($0.date, inSameDayAs: date) }.count
    }
}

#Preview {
    StatsView()
        .modelContainer(for: DiaryEntry.self, inMemory: true)
}
