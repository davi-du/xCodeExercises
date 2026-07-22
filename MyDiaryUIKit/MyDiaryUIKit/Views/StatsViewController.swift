//
//  StatsViewController.swift
//  MyDiaryUIKit
//
//  Created by Davide Cidu on 22/07/2026.
//

import UIKit
import SwiftData

class StatsViewController: UIViewController {

    private let chartContainerView = UIView()
    private let monthLabel = UILabel()
    private let calendarCollectionView: UICollectionView
    private let selectedDayStack = UIStackView()

    private var entries: [DiaryEntry] = []
    private var displayedMonth = Date()
    private var selectedDate: Date?
    private var currentMonthDates: [Date] = []

    private var modelContext: ModelContext {
        UIApplication.sharedModelContainer.mainContext
    }

    init() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 4
        layout.minimumLineSpacing = 4
        calendarCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Statistiche"
        view.backgroundColor = .systemGroupedBackground

        setupLayout()
        refreshData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let layout = calendarCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let width = (calendarCollectionView.bounds.width - 6 * 4) / 7
            layout.itemSize = CGSize(width: width, height: 38)
        }
    }

    // MARK: - Layout helpers

    private func sectionLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text.uppercased()
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .secondaryLabel
        return label
    }

    private func cardContainer(for content: UIView, insets: CGFloat = 14) -> UIView {
        let card = UIView()
        card.backgroundColor = .secondarySystemGroupedBackground
        card.layer.cornerRadius = 14
        card.translatesAutoresizingMaskIntoConstraints = false

        content.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(content)

        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: card.topAnchor, constant: insets),
            content.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -insets),
            content.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: insets),
            content.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -insets)
        ])

        return card
    }

    // MARK: - Setup

    private func setupLayout() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        let mainStack = UIStackView()
        mainStack.axis = .vertical
        mainStack.spacing = 20
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        // Chart card
        chartContainerView.translatesAutoresizingMaskIntoConstraints = false
        chartContainerView.heightAnchor.constraint(equalToConstant: 160).isActive = true
        let chartCard = cardContainer(for: chartContainerView)

        let chartSection = UIStackView(arrangedSubviews: [sectionLabel("Distribuzione mood"), chartCard])
        chartSection.axis = .vertical
        chartSection.spacing = 6

        // Calendar card
        let prevButton = UIButton(type: .system)
        prevButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        prevButton.addTarget(self, action: #selector(previousMonthTapped), for: .touchUpInside)

        let nextButton = UIButton(type: .system)
        nextButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        nextButton.addTarget(self, action: #selector(nextMonthTapped), for: .touchUpInside)

        monthLabel.font = .systemFont(ofSize: 16, weight: .semibold)

        let headerStack = UIStackView(arrangedSubviews: [monthLabel, UIView(), prevButton, nextButton])
        headerStack.axis = .horizontal
        headerStack.alignment = .center

        calendarCollectionView.translatesAutoresizingMaskIntoConstraints = false
        calendarCollectionView.backgroundColor = .clear
        calendarCollectionView.isScrollEnabled = false
        calendarCollectionView.dataSource = self
        calendarCollectionView.delegate = self
        calendarCollectionView.register(DayCell.self, forCellWithReuseIdentifier: "DayCell")
        calendarCollectionView.heightAnchor.constraint(equalToConstant: 270).isActive = true

        selectedDayStack.axis = .vertical
        selectedDayStack.spacing = 8

        let calendarContent = UIStackView(arrangedSubviews: [headerStack, calendarCollectionView, selectedDayStack])
        calendarContent.axis = .vertical
        calendarContent.spacing = 14

        let calendarCard = cardContainer(for: calendarContent)
        let calendarSection = UIStackView(arrangedSubviews: [sectionLabel("Calendario"), calendarCard])
        calendarSection.axis = .vertical
        calendarSection.spacing = 6

        mainStack.addArrangedSubview(chartSection)
        mainStack.addArrangedSubview(calendarSection)

        view.addSubview(scrollView)
        scrollView.addSubview(mainStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            mainStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            mainStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            mainStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            mainStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])
    }

    // MARK: - Data

    private func refreshData() {
        let descriptor = FetchDescriptor<DiaryEntry>()
        entries = (try? modelContext.fetch(descriptor)) ?? []

        buildChart()
        buildCurrentMonthDates()
        updateMonthLabel()
        calendarCollectionView.reloadData()
        updateSelectedDayList()
    }

    private func buildChart() {
        chartContainerView.subviews.forEach { $0.removeFromSuperview() }

        let barsStack = UIStackView()
        barsStack.axis = .horizontal
        barsStack.alignment = .bottom
        barsStack.distribution = .fillEqually
        barsStack.spacing = 12
        barsStack.translatesAutoresizingMaskIntoConstraints = false

        let maxCount = max(Mood.allCases.map { mood in entries.filter { $0.mood == mood }.count }.max() ?? 1, 1)

        for mood in Mood.allCases {
            let count = entries.filter { $0.mood == mood }.count

            let column = UIStackView()
            column.axis = .vertical
            column.alignment = .center
            column.spacing = 4

            let countLabel = UILabel()
            countLabel.text = "\(count)"
            countLabel.font = .systemFont(ofSize: 12)
            countLabel.textColor = .secondaryLabel

            let barHeight = max(CGFloat(count) / CGFloat(maxCount) * 100, 4)
            let bar = UIView()
            bar.backgroundColor = .systemBlue
            bar.layer.cornerRadius = 5
            bar.translatesAutoresizingMaskIntoConstraints = false
            bar.heightAnchor.constraint(equalToConstant: barHeight).isActive = true
            bar.widthAnchor.constraint(equalToConstant: 28).isActive = true

            let emojiLabel = UILabel()
            emojiLabel.text = moodEmoji(mood)
            emojiLabel.font = .systemFont(ofSize: 18)

            column.addArrangedSubview(countLabel)
            column.addArrangedSubview(bar)
            column.addArrangedSubview(emojiLabel)

            barsStack.addArrangedSubview(column)
        }

        chartContainerView.addSubview(barsStack)
        NSLayoutConstraint.activate([
            barsStack.leadingAnchor.constraint(equalTo: chartContainerView.leadingAnchor),
            barsStack.trailingAnchor.constraint(equalTo: chartContainerView.trailingAnchor),
            barsStack.bottomAnchor.constraint(equalTo: chartContainerView.bottomAnchor)
        ])
    }

    private func buildCurrentMonthDates() {
        let calendar = Calendar.current
        guard let monthInterval = calendar.dateInterval(of: .month, for: displayedMonth) else {
            currentMonthDates = []
            return
        }

        var dates: [Date] = []
        var current = monthInterval.start
        while current < monthInterval.end {
            dates.append(current)
            current = calendar.date(byAdding: .day, value: 1, to: current)!
        }
        currentMonthDates = dates
    }

    private func updateMonthLabel() {
        monthLabel.text = displayedMonth.formatted(.dateTime.month(.wide).year())
    }

    private func entryCount(for date: Date) -> Int {
        let calendar = Calendar.current
        return entries.filter { calendar.isDate($0.date, inSameDayAs: date) }.count
    }

    private func updateSelectedDayList() {
        selectedDayStack.arrangedSubviews.forEach {
            selectedDayStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        guard let selectedDate else { return }

        let divider = UIView()
        divider.backgroundColor = .separator
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true

        let dateLabel = UILabel()
        dateLabel.text = selectedDate.formatted(.dateTime.day().month(.wide))
        dateLabel.font = .systemFont(ofSize: 13, weight: .medium)
        dateLabel.textColor = .secondaryLabel

        selectedDayStack.addArrangedSubview(divider)
        selectedDayStack.addArrangedSubview(dateLabel)

        let calendar = Calendar.current
        let dayEntries = entries.filter { calendar.isDate($0.date, inSameDayAs: selectedDate) }

        if dayEntries.isEmpty {
            let emptyLabel = UILabel()
            emptyLabel.text = "Nessuna voce in questo giorno"
            emptyLabel.font = .systemFont(ofSize: 14)
            emptyLabel.textColor = .tertiaryLabel
            selectedDayStack.addArrangedSubview(emptyLabel)
        } else {
            for entry in dayEntries {
                let button = UIButton(type: .system)
                var config = UIButton.Configuration.plain()
                config.title = entry.title
                config.contentInsets = .zero
                config.image = UIImage(systemName: "chevron.right")
                config.imagePlacement = .trailing
                config.imagePadding = 4
                button.configuration = config
                button.contentHorizontalAlignment = .leading
                button.addAction(UIAction { [weak self] _ in
                    let detailVC = EntryDetailViewController(entry: entry)
                    self?.navigationController?.pushViewController(detailVC, animated: true)
                }, for: .touchUpInside)
                selectedDayStack.addArrangedSubview(button)
            }
        }
    }

    private func moodEmoji(_ mood: Mood) -> String {
        switch mood {
        case .happy: return "😊"
        case .sad: return "😢"
        case .angry: return "😠"
        case .excited: return "🤩"
        case .bored: return "😐"
        }
    }

    // MARK: - Actions

    @objc private func previousMonthTapped() {
        changeMonth(by: -1)
    }

    @objc private func nextMonthTapped() {
        changeMonth(by: 1)
    }

    private func changeMonth(by value: Int) {
        guard let newMonth = Calendar.current.date(byAdding: .month, value: value, to: displayedMonth) else { return }
        displayedMonth = newMonth
        selectedDate = nil
        buildCurrentMonthDates()
        updateMonthLabel()
        calendarCollectionView.reloadData()
        updateSelectedDayList()
    }
}

// MARK: - UICollectionView

extension StatsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        currentMonthDates.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DayCell", for: indexPath) as! DayCell
        let date = currentMonthDates[indexPath.item]
        let day = Calendar.current.component(.day, from: date)
        let count = entryCount(for: date)
        let isSelected = selectedDate.map { Calendar.current.isDate($0, inSameDayAs: date) } ?? false

        cell.configure(day: day, count: count, isSelected: isSelected)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let date = currentMonthDates[indexPath.item]

        if let selectedDate, Calendar.current.isDate(selectedDate, inSameDayAs: date) {
            self.selectedDate = nil
        } else {
            selectedDate = date
        }

        collectionView.reloadData()
        updateSelectedDayList()
    }
}

// MARK: - DayCell

class DayCell: UICollectionViewCell {

    private let dayLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        dayLabel.textAlignment = .center
        dayLabel.font = .systemFont(ofSize: 14)
        dayLabel.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(dayLabel)
        contentView.layer.cornerRadius = 8

        NSLayoutConstraint.activate([
            dayLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }

    func configure(day: Int, count: Int, isSelected: Bool) {
        dayLabel.text = "\(day)"

        if isSelected {
            contentView.backgroundColor = .systemBlue
            dayLabel.textColor = .white
        } else if count > 0 {
            let alpha = min(0.15 * Double(count), 0.6)
            contentView.backgroundColor = UIColor.systemBlue.withAlphaComponent(alpha)
            dayLabel.textColor = .label
        } else {
            contentView.backgroundColor = .clear
            dayLabel.textColor = .label
        }
    }
}
