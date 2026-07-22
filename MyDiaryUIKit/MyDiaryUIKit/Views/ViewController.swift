//
//  ViewController.swift
//  MyDiaryUIKit
//
//  Created by Davide Cidu on 21/07/2026.
//
//
//  ViewController.swift
//  MyDiaryUIKit
//

import UIKit
import SwiftData

class ViewController: UIViewController {

    private var tableView = UITableView()
    private var entries: [DiaryEntry] = []

    private var modelContext: ModelContext {
        UIApplication.sharedModelContainer.mainContext
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        setupTitleView()
        setupTableView()

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addTapped)
        )

        fetchEntries()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchEntries()
    }

    private func setupTitleView() {
        let icon = UIImageView(image: UIImage(systemName: "book.closed.fill"))
        icon.tintColor = .systemBlue
        icon.contentMode = .scaleAspectFit

        let label = UILabel()
        label.text = "Diario"
        label.font = .systemFont(ofSize: 17, weight: .semibold)

        let stack = UIStackView(arrangedSubviews: [icon, label])
        stack.axis = .horizontal
        stack.spacing = 6
        stack.alignment = .center

        icon.widthAnchor.constraint(equalToConstant: 20).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 20).isActive = true

        navigationItem.titleView = stack
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(EntryCell.self, forCellReuseIdentifier: "EntryCell")

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func fetchEntries() {
        let descriptor = FetchDescriptor<DiaryEntry>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        entries = (try? modelContext.fetch(descriptor)) ?? []
        tableView.reloadData()
    }

    @objc private func addTapped() {
        let addVC = AddEntryViewController()
        addVC.onSave = { [weak self] in
            self?.fetchEntries()
        }
        let nav = UINavigationController(rootViewController: addVC)
        present(nav, animated: true)
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        entries.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EntryCell", for: indexPath) as! EntryCell
        let entry = entries[indexPath.row]
        cell.configure(with: entry)
        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        let entry = entries[indexPath.row]
        modelContext.delete(entry)
        entries.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let entry = entries[indexPath.row]
        let detailVC = EntryDetailViewController(entry: entry)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
