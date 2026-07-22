//
//  EntryCell.swift
//  MyDiaryUIKit
//
//  Created by Davide Cidu on 22/07/2026.
//

import UIKit

class EntryCell: UITableViewCell {

    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    private let tagsLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }

    private func setupLayout() {
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)

        dateLabel.font = .systemFont(ofSize: 12)
        dateLabel.textColor = .secondaryLabel

        tagsLabel.font = .systemFont(ofSize: 12)
        tagsLabel.textColor = .systemBlue

        let stack = UIStackView(arrangedSubviews: [titleLabel, dateLabel, tagsLabel])
        stack.axis = .vertical
        stack.spacing = 3
        stack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }

    func configure(with entry: DiaryEntry) {
        titleLabel.text = entry.title
        dateLabel.text = entry.date.formatted(date: .abbreviated, time: .shortened)

        if entry.tags.isEmpty {
            tagsLabel.text = nil
            tagsLabel.isHidden = true
        } else {
            tagsLabel.text = entry.tags.map { $0.name }.joined(separator: "  •  ")
            tagsLabel.isHidden = false
        }
    }
}
