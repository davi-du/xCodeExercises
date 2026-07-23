//
//  TransactionDetailsViewController.swift
//  DemoAppUIKit
//
//  Created by Davide Cidu on 22/07/2026.
//

import UIKit

final class TransactionDetailsViewController: UIViewController {

    private let transaction: Transaction

    init(transaction: Transaction) {
        self.transaction = transaction
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) non è supportato")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        buildLayout()
    }

    private func buildLayout() {
        let iconImageView = UIImageView(image: UIImage(systemName: "dollarsign.circle.fill"))
        iconImageView.tintColor = .systemBlue
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = makeLabel(transaction.title)
        titleLabel.font = .systemFont(ofSize: 17, weight: .bold)

        let dateAmountRow = UIStackView(arrangedSubviews: [
            makeLabel("Data \(transaction.date.formatted(date: .numeric, time: .omitted))"),
            makeSpacer(),
            makeLabel("Importo \(transaction.amount.formatted(.currency(code: "EUR")))")
        ])
        dateAmountRow.axis = .horizontal

        var rows: [UIView] = [titleLabel, dateAmountRow]

        if let beneficiary = transaction.beneficiary, !beneficiary.isEmpty {
            let row = UIStackView(arrangedSubviews: [makeLabel("Beneficiario \(beneficiary)"), makeSpacer()])
            row.axis = .horizontal
            rows.append(row)
        }

        if let iban = transaction.beneficiaryIban, !iban.isEmpty {
            let ibanLabel = makeLabel("IBAN \(iban)")
            ibanLabel.font = .systemFont(ofSize: 12)
            let row = UIStackView(arrangedSubviews: [ibanLabel, makeSpacer()])
            row.axis = .horizontal
            rows.append(row)
        }

        let textStack = UIStackView(arrangedSubviews: rows)
        textStack.axis = .vertical
        textStack.spacing = 6
        textStack.setCustomSpacing(12, after: titleLabel)

        let mainStack = UIStackView(arrangedSubviews: [iconImageView, textStack])
        mainStack.axis = .vertical
        mainStack.alignment = .leading
        mainStack.spacing = 16
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 24),
            mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            iconImageView.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    private func makeLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 15)
        return label
    }

    private func makeSpacer() -> UIView {
        let view = UIView()
        view.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return view
    }
}
