//
//  EntryDetailViewController.swift
//  MyDiaryUIKit
//
//  Created by Davide Cidu on 21/07/2026.
//

import UIKit
import SwiftData

class EntryDetailViewController: UIViewController {

    private let entry: DiaryEntry

    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    private let moodBadge = UILabel()
    private let tagsStackView = UIStackView()
    private let photosStackView = UIStackView()
    private let contentLabel = UILabel()

    init(entry: DiaryEntry) {
        self.entry = entry
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Dettaglio"
        view.backgroundColor = .systemGroupedBackground

        setupLayout()
        populateContent()
    }

    // MARK: - Layout helpers

    private func cardContainer(for content: UIView, insets: NSDirectionalEdgeInsets = .init(top: 14, leading: 14, bottom: 14, trailing: 14)) -> UIView {
        let card = UIView()
        card.backgroundColor = .secondarySystemGroupedBackground
        card.layer.cornerRadius = 14
        card.translatesAutoresizingMaskIntoConstraints = false

        content.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(content)

        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: card.topAnchor, constant: insets.top),
            content.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -insets.bottom),
            content.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: insets.leading),
            content.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -insets.trailing)
        ])

        return card
    }

    private func setupLayout() {
        titleLabel.font = .systemFont(ofSize: 26, weight: .bold)
        titleLabel.numberOfLines = 0

        dateLabel.font = .systemFont(ofSize: 13)
        dateLabel.textColor = .secondaryLabel

        moodBadge.font = .systemFont(ofSize: 14, weight: .medium)
        moodBadge.backgroundColor = .tertiarySystemGroupedBackground
        moodBadge.layer.cornerRadius = 12
        moodBadge.layer.masksToBounds = true
        moodBadge.textAlignment = .center
        moodBadge.setContentHuggingPriority(.required, for: .horizontal)

        let headerStack = UIStackView(arrangedSubviews: [titleLabel, dateLabel, moodBadgeWrapper()])
        headerStack.axis = .vertical
        headerStack.spacing = 8
        headerStack.alignment = .leading

        tagsStackView.axis = .horizontal
        tagsStackView.spacing = 6

        let tagsScroll = UIScrollView()
        tagsScroll.showsHorizontalScrollIndicator = false
        tagsScroll.translatesAutoresizingMaskIntoConstraints = false
        tagsScroll.addSubview(tagsStackView)
        tagsStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tagsStackView.topAnchor.constraint(equalTo: tagsScroll.topAnchor),
            tagsStackView.leadingAnchor.constraint(equalTo: tagsScroll.leadingAnchor),
            tagsStackView.trailingAnchor.constraint(equalTo: tagsScroll.trailingAnchor),
            tagsStackView.bottomAnchor.constraint(equalTo: tagsScroll.bottomAnchor),
            tagsStackView.heightAnchor.constraint(equalTo: tagsScroll.heightAnchor)
        ])
        tagsScroll.heightAnchor.constraint(equalToConstant: 30).isActive = true

        photosStackView.axis = .horizontal
        photosStackView.spacing = 8

        let photosScroll = UIScrollView()
        photosScroll.showsHorizontalScrollIndicator = false
        photosScroll.translatesAutoresizingMaskIntoConstraints = false
        photosScroll.addSubview(photosStackView)
        photosStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            photosStackView.topAnchor.constraint(equalTo: photosScroll.topAnchor),
            photosStackView.leadingAnchor.constraint(equalTo: photosScroll.leadingAnchor),
            photosStackView.trailingAnchor.constraint(equalTo: photosScroll.trailingAnchor),
            photosStackView.bottomAnchor.constraint(equalTo: photosScroll.bottomAnchor),
            photosStackView.heightAnchor.constraint(equalTo: photosScroll.heightAnchor)
        ])
        photosScroll.heightAnchor.constraint(equalToConstant: 130).isActive = true

        contentLabel.font = .systemFont(ofSize: 16)
        contentLabel.numberOfLines = 0

        let mainStack = UIStackView(arrangedSubviews: [
            cardContainer(for: headerStack),
            tagsScroll,
            photosScroll,
            cardContainer(for: contentLabel)
        ])
        mainStack.axis = .vertical
        mainStack.spacing = 16
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false

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

    private func moodBadgeWrapper() -> UIView {
        let wrapper = UIView()
        wrapper.addSubview(moodBadge)
        moodBadge.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            moodBadge.topAnchor.constraint(equalTo: wrapper.topAnchor),
            moodBadge.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor),
            moodBadge.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor),
            moodBadge.heightAnchor.constraint(equalToConstant: 26)
        ])
        moodBadge.textAlignment = .center
        return wrapper
    }

    private func populateContent() {
        titleLabel.text = entry.title
        dateLabel.text = entry.date.formatted(date: .complete, time: .shortened)
        moodBadge.text = "  \(moodText(for: entry.mood))  "
        contentLabel.text = entry.content.isEmpty ? "Nessun testo" : entry.content
        contentLabel.textColor = entry.content.isEmpty ? .tertiaryLabel : .label

        for tag in entry.tags {
            let pill = UILabel()
            pill.text = "  \(tag.name)  "
            pill.font = .systemFont(ofSize: 13)
            pill.textColor = .white
            pill.backgroundColor = .systemBlue
            pill.layer.cornerRadius = 12
            pill.layer.masksToBounds = true
            pill.heightAnchor.constraint(equalToConstant: 24).isActive = true
            tagsStackView.addArrangedSubview(pill)
        }

        for attachment in entry.attachments {
            if let uiImage = UIImage(data: attachment.imageData) {
                let imageView = UIImageView(image: uiImage)
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
                imageView.layer.cornerRadius = 12
                imageView.translatesAutoresizingMaskIntoConstraints = false
                imageView.widthAnchor.constraint(equalToConstant: 130).isActive = true
                imageView.heightAnchor.constraint(equalToConstant: 130).isActive = true

                photosStackView.addArrangedSubview(imageView)
            }
        }
    }

    private func moodText(for mood: Mood) -> String {
        switch mood {
        case .happy: return "😊 Felice"
        case .sad: return "😢 Triste"
        case .angry: return "😠 Arrabbiato"
        case .excited: return "🤩 Emozionato"
        case .bored: return "😐 Annoiato"
        }
    }
}
