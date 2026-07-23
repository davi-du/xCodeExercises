//
//  FormDateCell.swift
//  DemoAppUIKit
//
//  Created by Davide Cidu on 22/07/2026.
//

import UIKit

final class FormDateCell: UITableViewCell {

    static let reuseIdentifier = "FormDateCell"

    var onDateChanged: ((Date) -> Void)?

    private let label: UILabel = {
        let label = UILabel()
        label.text = "Data"
        return label
    }()

    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        return picker
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none

        label.translatesAutoresizingMaskIntoConstraints = false
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)
        contentView.addSubview(datePicker)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            datePicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            datePicker.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            datePicker.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            datePicker.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6)
        ])

        datePicker.addTarget(self, action: #selector(dateValueChanged), for: .valueChanged)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) non è supportato")
    }

    func configure(date: Date) {
        datePicker.date = date
    }

    @objc private func dateValueChanged() {
        onDateChanged?(datePicker.date)
    }
}
