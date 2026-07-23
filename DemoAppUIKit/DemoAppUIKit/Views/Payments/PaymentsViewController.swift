//
//  PaymentsViewController.swift
//  DemoAppUIKit
//
//  Created by Davide Cidu on 22/07/2026.
//


//
//  PaymentsViewController.swift
//  DemoApp
//
//  Equivalente UIKit di PaymentsView.swift. Il Form di SwiftUI diventa una
//  UITableView in stile .insetGrouped, con celle custom per i vari campi.
//

import UIKit

final class PaymentsViewController: UIViewController {

    // MARK: - Dipendenze

    private let session: SessionManager
    private let viewModel = PaymentsViewModel()

    /// Chiamata dopo un pagamento riuscito (equivalente di onPaymentCompleted in SwiftUI).
    var onPaymentCompleted: (() -> Void)?
    /// Chiamata se il token non è più valido durante l'invio.
    var onSessionExpired: (() -> Void)?

    init(session: SessionManager) {
        self.session = session
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) non è supportato")
    }

    // MARK: - Sezioni del form

    private enum Section: Int, CaseIterable {
        case beneficiary, iban, amount, causale, date

        var title: String {
            switch self {
            case .beneficiary: return "Beneficiario"
            case .iban: return "IBAN"
            case .amount: return "Importo"
            case .causale: return "Causale"
            case .date: return "Emissione"
            }
        }
    }

    // MARK: - UI

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Nuovo bonifico"
        label.font = .systemFont(ofSize: 34, weight: .bold)
        return label
    }()

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    private let payButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "Paga"
        configuration.cornerStyle = .medium
        configuration.buttonSize = .large
        let button = UIButton(configuration: configuration)
        button.titleLabel?.font = .systemFont(ofSize: 19, weight: .bold)
        return button
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private let errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemRed
        label.font = .preferredFont(forTextStyle: .footnote)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        buildLayout()
        configureTableView()
        updatePayButtonState()

        payButton.addTarget(self, action: #selector(payTapped), for: .touchUpInside)
    }

    // MARK: - Layout

    private func buildLayout() {
        [titleLabel, tableView, payButton, errorLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        view.addSubview(titleLabel)
        view.addSubview(tableView)
        view.addSubview(payButton)
        view.addSubview(errorLabel)

        payButton.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),

            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: payButton.topAnchor, constant: -8),

            payButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            payButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            payButton.heightAnchor.constraint(equalToConstant: 50),
            payButton.bottomAnchor.constraint(equalTo: errorLabel.topAnchor, constant: -8),

            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            errorLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),

            activityIndicator.centerXAnchor.constraint(equalTo: payButton.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: payButton.centerYAnchor)
        ])
    }

    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(FormFieldCell.self, forCellReuseIdentifier: FormFieldCell.reuseIdentifier)
        tableView.register(FormDateCell.self, forCellReuseIdentifier: FormDateCell.reuseIdentifier)
        tableView.keyboardDismissMode = .interactive
    }

    // MARK: - Invio pagamento

    @objc private func payTapped() {
        Task { await submitPayment() }
    }

    private func submitPayment() async {
        setSubmitting(true)
        let esito = await viewModel.invia(token: session.token)
        setSubmitting(false)

        switch esito {
        case .successo:
            errorLabel.isHidden = true
            tableView.reloadData() // il ViewModel ha già svuotato i campi (resetForm)
            onPaymentCompleted?()

        case .sessioneScaduta:
            session.logout()
            onSessionExpired?()

        case .fallito:
            errorLabel.text = viewModel.errorMessage
            errorLabel.isHidden = false
        }
    }

    private func setSubmitting(_ isSubmitting: Bool) {
        payButton.isEnabled = !isSubmitting

        if isSubmitting {
            payButton.configuration?.title = ""
            activityIndicator.startAnimating()
        } else {
            payButton.configuration?.title = "Paga"
            activityIndicator.stopAnimating()
        }
    }

    private func updatePayButtonState() {
        payButton.isEnabled = !viewModel.isSubmitting
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension PaymentsViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        Section(rawValue: section)?.title
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: indexPath.section) else {
            return UITableViewCell()
        }

        switch section {
        case .beneficiary:
            let cell = tableView.dequeueReusableCell(withIdentifier: FormFieldCell.reuseIdentifier, for: indexPath) as! FormFieldCell
            cell.configure(placeholder: "Nome e cognome", text: viewModel.fullName, keyboardType: .default)
            cell.onTextChanged = { [weak self] text in self?.viewModel.fullName = text }
            return cell

        case .iban:
            let cell = tableView.dequeueReusableCell(withIdentifier: FormFieldCell.reuseIdentifier, for: indexPath) as! FormFieldCell
            cell.configure(placeholder: "IBAN", text: viewModel.iban, keyboardType: .default, autocapitalization: .allCharacters)
            cell.onTextChanged = { [weak self] text in self?.viewModel.iban = text }
            return cell

        case .amount:
            let cell = tableView.dequeueReusableCell(withIdentifier: FormFieldCell.reuseIdentifier, for: indexPath) as! FormFieldCell
            let amountText = viewModel.amount == 0 ? "" : "\(viewModel.amount)"
            cell.configure(placeholder: "Importo (EUR)", text: amountText, keyboardType: .decimalPad)
            cell.onTextChanged = { [weak self] text in
                let normalized = text.replacingOccurrences(of: ",", with: ".")
                self?.viewModel.amount = Decimal(string: normalized) ?? 0
            }
            return cell

        case .causale:
            let cell = tableView.dequeueReusableCell(withIdentifier: FormFieldCell.reuseIdentifier, for: indexPath) as! FormFieldCell
            cell.configure(placeholder: "Causale", text: viewModel.causale, keyboardType: .default)
            cell.onTextChanged = { [weak self] text in self?.viewModel.causale = text }
            return cell

        case .date:
            let cell = tableView.dequeueReusableCell(withIdentifier: FormDateCell.reuseIdentifier, for: indexPath) as! FormDateCell
            cell.configure(date: viewModel.date)
            cell.onDateChanged = { [weak self] date in self?.viewModel.date = date }
            return cell
        }
    }
}