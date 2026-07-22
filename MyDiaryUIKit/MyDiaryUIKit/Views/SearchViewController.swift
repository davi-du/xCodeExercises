//
//  SearchViewController.swift
//  MyDiaryUIKit
//
//  Created by Davide Cidu on 21/07/2026.
//

import UIKit
import SwiftData

private enum Section: Int, CaseIterable {
    case text, mood, date, tags, searchButton, results
}


class HostingCell: UITableViewCell {
    private weak var hostedView: UIView?

    func host(_ view: UIView, insets: UIEdgeInsets = UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16)) {
        hostedView?.removeFromSuperview()

        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)

        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: contentView.topAnchor, constant: insets.top),
            view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -insets.bottom),
            view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: insets.left),
            view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -insets.right)
        ])

        hostedView = view
        selectionStyle = .none
    }
}

class SearchViewController: UIViewController {

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    private let searchField = UITextField()
    private let moodSegmented = UISegmentedControl(items: ["Tutti", "😊", "😢", "😠", "🤩", "😐"])
    private let dateToggle = UISwitch()
    private let startDatePicker = UIDatePicker()
    private let endDatePicker = UIDatePicker()
    private let searchButton = UIButton(type: .system)

    private var allTags: [Tag] = []
    private var selectedTagIDs: Set<PersistentIdentifier> = []
    private var results: [DiaryEntry] = []

    private var modelContext: ModelContext {
        UIApplication.sharedModelContainer.mainContext
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Ricerca"
        setupControls()
        setupTableView()

        fetchTags()
        runSearch()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchTags()
    }

    // MARK: - Setup

    private func setupControls() {
        searchField.placeholder = "Cerca in titolo o contenuto"
        searchField.borderStyle = .none
        searchField.font = .systemFont(ofSize: 16)
        searchField.clearButtonMode = .whileEditing

        moodSegmented.selectedSegmentIndex = 0

        dateToggle.addTarget(self, action: #selector(dateToggleChanged), for: .valueChanged)

        startDatePicker.datePickerMode = .date
        startDatePicker.preferredDatePickerStyle = .compact
        startDatePicker.date = Date.now.addingTimeInterval(-30 * 24 * 3600)

        endDatePicker.datePickerMode = .date
        endDatePicker.preferredDatePickerStyle = .compact

        var config = UIButton.Configuration.filled()
        config.title = "Cerca"
        config.image = UIImage(systemName: "magnifyingglass")
        config.imagePadding = 6
        config.cornerStyle = .medium
        searchButton.configuration = config
        searchButton.addTarget(self, action: #selector(searchTapped), for: .touchUpInside)
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self

        tableView.register(HostingCell.self, forCellReuseIdentifier: "SearchFieldCell")
        tableView.register(HostingCell.self, forCellReuseIdentifier: "MoodCell")
        tableView.register(HostingCell.self, forCellReuseIdentifier: "SearchButtonCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DateRowCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TagCell")
        tableView.register(EntryCell.self, forCellReuseIdentifier: "ResultCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "EmptyResultCell")

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - Data

    private func fetchTags() {
        let descriptor = FetchDescriptor<Tag>(sortBy: [SortDescriptor(\.name)])
        allTags = (try? modelContext.fetch(descriptor)) ?? []
        tableView.reloadSections(IndexSet(integer: Section.tags.rawValue), with: .none)
    }

    @objc private func dateToggleChanged() {
        let section = Section.date.rawValue
        let datePaths = [IndexPath(row: 1, section: section), IndexPath(row: 2, section: section)]

        if dateToggle.isOn {
            tableView.insertRows(at: datePaths, with: .automatic)
        } else {
            tableView.deleteRows(at: datePaths, with: .automatic)
        }
    }

    @objc private func searchTapped() {
        runSearch()
    }

    private func runSearch() {
        let text = searchField.text ?? ""
        let dateActive = dateToggle.isOn
        let start = startDatePicker.date
        let end = endDatePicker.date

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

            if let mood = moodForSegmentIndex(moodSegmented.selectedSegmentIndex) {
                fetched = fetched.filter { $0.mood == mood }
            }

            if !selectedTagIDs.isEmpty {
                fetched = fetched.filter { entry in
                    entry.tags.contains { selectedTagIDs.contains($0.persistentModelID) }
                }
            }

            results = fetched
        } catch {
            print("Errore nella ricerca: \(error)")
            results = []
        }

        tableView.reloadSections(IndexSet(integer: Section.results.rawValue), with: .automatic)
    }

    private func moodForSegmentIndex(_ index: Int) -> Mood? {
        switch index {
        case 1: return .happy
        case 2: return .sad
        case 3: return .angry
        case 4: return .excited
        case 5: return .bored
        default: return nil
        }
    }
}

// MARK: - UITableViewDataSource / Delegate

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .text: return 1
        case .mood: return 1
        case .date: return dateToggle.isOn ? 3 : 1
        case .tags: return allTags.count
        case .searchButton: return 1
        case .results: return results.isEmpty ? 1 : results.count
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Section(rawValue: section)! {
        case .text: return "Testo"
        case .mood: return "Mood"
        case .date: return "Data"
        case .tags: return allTags.isEmpty ? nil : "Tag"
        case .searchButton: return nil
        case .results: return "Risultati"
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Section(rawValue: indexPath.section)! {
        case .text:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SearchFieldCell", for: indexPath) as! HostingCell
            cell.host(searchField)
            return cell

        case .mood:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MoodCell", for: indexPath) as! HostingCell
            cell.host(moodSegmented)
            return cell

        case .date:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DateRowCell", for: indexPath)
            cell.accessoryView = nil
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Filtra per data"
                cell.accessoryView = dateToggle
            case 1:
                cell.textLabel?.text = "Da"
                cell.accessoryView = startDatePicker
            default:
                cell.textLabel?.text = "A"
                cell.accessoryView = endDatePicker
            }
            cell.selectionStyle = .none
            return cell

        case .tags:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TagCell", for: indexPath)
            let tag = allTags[indexPath.row]
            cell.textLabel?.text = tag.name
            cell.accessoryType = selectedTagIDs.contains(tag.persistentModelID) ? .checkmark : .none
            return cell

        case .searchButton:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SearchButtonCell", for: indexPath) as! HostingCell
            cell.host(searchButton, insets: UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16))
            return cell

        case .results:
            if results.isEmpty {
                let cell = tableView.dequeueReusableCell(withIdentifier: "EmptyResultCell", for: indexPath)
                cell.textLabel?.text = "Nessuna voce trovata"
                cell.textLabel?.textColor = .secondaryLabel
                cell.textLabel?.textAlignment = .center
                cell.selectionStyle = .none
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ResultCell", for: indexPath) as! EntryCell
                cell.configure(with: results[indexPath.row])
                return cell
            }
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        switch Section(rawValue: indexPath.section)! {
        case .tags:
            let tag = allTags[indexPath.row]
            if selectedTagIDs.contains(tag.persistentModelID) {
                selectedTagIDs.remove(tag.persistentModelID)
            } else {
                selectedTagIDs.insert(tag.persistentModelID)
            }
            tableView.reloadRows(at: [indexPath], with: .none)

        case .results:
            guard !results.isEmpty else { return }
            let entry = results[indexPath.row]
            let detailVC = EntryDetailViewController(entry: entry)
            navigationController?.pushViewController(detailVC, animated: true)

        default:
            break
        }
    }
}
