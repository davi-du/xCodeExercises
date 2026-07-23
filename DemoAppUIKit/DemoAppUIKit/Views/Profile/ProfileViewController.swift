//
//  ProfileViewController.swift
//  DemoAppUIKit
//
//  Created by Davide Cidu on 22/07/2026.
//

import UIKit

final class ProfileViewController: UIViewController {

    private let costumer: CostumerProfile
    private let session: SessionManager

    var onLogout: (() -> Void)?
    var onShowDocuments: (() -> Void)?

    private var hideCopiedFeedbackTask: Task<Void, Never>?

    init(costumer: CostumerProfile, session: SessionManager) {
        self.costumer = costumer
        self.session = session
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) non è supportato")
    }

    deinit {
        hideCopiedFeedbackTask?.cancel()
    }

    // MARK: - UI

    private let scrollView = UIScrollView()

    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 24, right: 16)
        return stack
    }()

    private let avatarImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "person.circle.fill"))
        imageView.tintColor = .systemBlue
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textAlignment = .center
        return label
    }()

    private let ibanValueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.numberOfLines = 0
        return label
    }()

    private let ibanCopyButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .systemBlue
        button.accessibilityLabel = "Copia IBAN"
        return button
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        buildLayout()
    }

    // MARK: - Layout

    private func buildLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            avatarImageView.widthAnchor.constraint(equalToConstant: 100),
            avatarImageView.heightAnchor.constraint(equalToConstant: 100)
        ])

        nameLabel.text = costumer.fullName
        ibanValueLabel.text = costumer.iban
        setIbanCopied(false)
        ibanCopyButton.addTarget(self, action: #selector(copyIban), for: .touchUpInside)

        let headerStack = UIStackView(arrangedSubviews: [avatarImageView, nameLabel])
        headerStack.axis = .vertical
        headerStack.alignment = .center
        headerStack.spacing = 8

        contentStack.addArrangedSubview(headerStack)
        contentStack.addArrangedSubview(makePersonalInfoCard())
        contentStack.addArrangedSubview(makeAccountInfoCard())
        contentStack.addArrangedSubview(makeDocumentsButton())
        contentStack.addArrangedSubview(makeLogoutButton())
    }

    // MARK: - Card dati personali

    private func makePersonalInfoCard() -> UIView {
        let container = makeCardContainer()

        let stack = UIStackView(arrangedSubviews: [
            makeInfoRow(label: "Data di nascita", value: costumer.birthdate.formatted(date: .numeric, time: .omitted)),
            makeDivider(),
            makeInfoRow(label: "Email", value: costumer.email),
            makeDivider(),
            makeInfoRow(label: "Telefono", value: costumer.phone),
            makeDivider(),
            makeInfoRow(label: "Codice cliente", value: costumer.costumerCode),
            makeDivider(),
            makeInfoRow(label: "Indirizzo", value: costumer.address)
        ])
        stack.axis = .vertical
        pin(stack, inside: container)

        return container
    }

    // MARK: - Card saldo e IBAN

    private func makeAccountInfoCard() -> UIView {
        let container = makeCardContainer()

        let ibanLabel = UILabel()
        ibanLabel.text = "IBAN"
        ibanLabel.font = .systemFont(ofSize: 12)
        ibanLabel.textColor = .secondaryLabel

        let ibanTextStack = UIStackView(arrangedSubviews: [ibanLabel, ibanValueLabel])
        ibanTextStack.axis = .vertical
        ibanTextStack.spacing = 4

        let ibanRow = UIStackView(arrangedSubviews: [ibanTextStack, ibanCopyButton])
        ibanRow.axis = .horizontal
        ibanRow.alignment = .center
        ibanRow.isLayoutMarginsRelativeArrangement = true
        ibanRow.layoutMargins = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)

        let stack = UIStackView(arrangedSubviews: [
            makeInfoRow(label: "Saldo disponibile", value: costumer.accountBalance.formatted(.currency(code: "EUR"))),
            makeDivider(),
            ibanRow
        ])
        stack.axis = .vertical
        pin(stack, inside: container)

        return container
    }

    // MARK: - Pulsante Documenti

    private func makeDocumentsButton() -> UIView {
        let container = makeCardContainer()

        let icon = UIImageView(image: UIImage(systemName: "doc.text.fill"))
        icon.tintColor = .label
        icon.setContentHuggingPriority(.required, for: .horizontal)

        let label = UILabel()
        label.text = "Documenti"
        label.textColor = .label

        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = .secondaryLabel
        chevron.setContentHuggingPriority(.required, for: .horizontal)

        let row = UIStackView(arrangedSubviews: [icon, label, spacer, chevron])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 8
        row.isLayoutMarginsRelativeArrangement = true
        row.layoutMargins = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)
        row.isUserInteractionEnabled = false
        pin(row, inside: container)

        container.isUserInteractionEnabled = true
        container.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(documentsTapped)))

        return container
    }

    // MARK: - Pulsante Esci

    private func makeLogoutButton() -> UIView {
        var configuration = UIButton.Configuration.bordered()
        configuration.title = "Esci"
        configuration.baseForegroundColor = .systemRed
        configuration.cornerStyle = .medium
        configuration.buttonSize = .large

        let button = UIButton(configuration: configuration)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true

        return button
    }

    // MARK: - Helper di layout

    private func makeCardContainer() -> UIView {
        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = 12
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.1
        container.layer.shadowRadius = 6
        container.layer.shadowOffset = CGSize(width: 0, height: 3)
        return container
    }

    private func makeInfoRow(label: String, value: String) -> UIView {
        let labelView = UILabel()
        labelView.text = label
        labelView.textColor = .secondaryLabel
        labelView.setContentHuggingPriority(.required, for: .horizontal)

        let valueView = UILabel()
        valueView.text = value
        valueView.textAlignment = .right
        valueView.numberOfLines = 0

        let row = UIStackView(arrangedSubviews: [labelView, valueView])
        row.axis = .horizontal
        row.alignment = .top
        row.spacing = 12
        row.isLayoutMarginsRelativeArrangement = true
        row.layoutMargins = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        return row
    }

    private func makeDivider() -> UIView {
        let wrapper = UIView()
        let line = UIView()
        line.backgroundColor = .separator
        line.translatesAutoresizingMaskIntoConstraints = false

        wrapper.addSubview(line)
        wrapper.heightAnchor.constraint(equalToConstant: 1).isActive = true

        NSLayoutConstraint.activate([
            line.heightAnchor.constraint(equalToConstant: 1),
            line.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: 16),
            line.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor),
            line.centerYAnchor.constraint(equalTo: wrapper.centerYAnchor)
        ])

        return wrapper
    }

    private func pin(_ subview: UIView, inside container: UIView) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(subview)
        NSLayoutConstraint.activate([
            subview.topAnchor.constraint(equalTo: container.topAnchor),
            subview.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            subview.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            subview.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])
    }

    // MARK: - Azioni

    @objc private func copyIban() {
        UIPasteboard.general.string = costumer.iban
        setIbanCopied(true)

        hideCopiedFeedbackTask?.cancel()
        hideCopiedFeedbackTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            guard !Task.isCancelled else { return }
            self?.setIbanCopied(false)
        }
    }

    private func setIbanCopied(_ isCopied: Bool) {
        let imageName = isCopied ? "checkmark" : "document.on.document.fill"
        ibanCopyButton.setImage(UIImage(systemName: imageName), for: .normal)
        ibanCopyButton.tintColor = isCopied ? .systemGreen : .systemBlue
    }

    @objc private func documentsTapped() {
        onShowDocuments?()
    }

    @objc private func logoutTapped() {
        session.logout()
        onLogout?()
    }
}
