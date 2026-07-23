//
//  FormFieldCell.swift
//  DemoAppUIKit
//
//  Created by Davide Cidu on 22/07/2026.
//

import UIKit

final class FormFieldCell: UITableViewCell {

    static let reuseIdentifier = "FormFieldCell"

    var onTextChanged: ((String) -> Void)?

    private let textField = UITextField()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none

        textField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(textField)

        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            textField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])

        textField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) non è supportato")
    }

    func configure(
        placeholder: String,
        text: String,
        keyboardType: UIKeyboardType,
        autocapitalization: UITextAutocapitalizationType = .sentences
    ) {
        textField.placeholder = placeholder
        textField.text = text
        textField.keyboardType = keyboardType
        textField.autocapitalizationType = autocapitalization
    }

    @objc private func textFieldChanged() {
        onTextChanged?(textField.text ?? "")
    }
}
