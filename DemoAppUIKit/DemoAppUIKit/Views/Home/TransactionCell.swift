//
//  TransactionCell.swift
//  DemoAppUIKit
//
//  Created by Davide Cidu on 22/07/2026.
//

import UIKit

final class TransactionCell: UITableViewCell {

    static let reuseIdentifier = "TransactionCell"

    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowRadius = 8
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = .black
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .black
        return label
    }()

    private let amountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = .black
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        buildLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) non è supportato")
    }

    private func buildLayout() {
        backgroundColor = .clear
        selectionStyle = .none

        let textStack = UIStackView(arrangedSubviews: [titleLabel, dateLabel])
        textStack.axis = .vertical
        textStack.spacing = 2

        [cardView, textStack, amountLabel].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        contentView.addSubview(cardView)
        cardView.addSubview(textStack)
        cardView.addSubview(amountLabel)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            textStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            textStack.topAnchor.constraint(greaterThanOrEqualTo: cardView.topAnchor, constant: 12),
            textStack.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor, constant: -12),
            textStack.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),

            amountLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            amountLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            amountLabel.leadingAnchor.constraint(greaterThanOrEqualTo: textStack.trailingAnchor, constant: 8)
        ])
    }

    func configure(with transaction: Transaction) {
        titleLabel.text = transaction.title
        dateLabel.text = transaction.date.formatted(date: .numeric, time: .omitted)
        amountLabel.text = transaction.amount.formatted(.currency(code: "EUR"))
    }
}
