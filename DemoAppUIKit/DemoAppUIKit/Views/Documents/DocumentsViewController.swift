//
//  DocumentsViewController.swift
//  DemoAppUIKit
//
//  Created by Davide Cidu on 22/07/2026.
//

//
//  Equivalente UIKit di DocumentsView.swift. Presentata modalmente (dentro
//  una UINavigationController) dal tap su Documenti in ProfileViewController.
//

import UIKit

final class DocumentsViewController: UIViewController {

    private let session: SessionManager
    private let viewModel = DocumentsViewModel()

    init(session: SessionManager) {
        self.session = session
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) non è supportato")
    }

    // MARK: - UI

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Documenti"
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Chiudi", style: .done, target: self, action: #selector(closeTapped)
        )

        buildLayout()
        configureTableView()

        Task { await loadDocuments() }
    }

    // MARK: - Layout

    private func buildLayout() {
        [tableView, activityIndicator, messageLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        view.addSubview(messageLabel)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            messageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            messageLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            messageLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24)
        ])
    }

    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isHidden = true
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    // MARK: - Caricamento

    private func loadDocuments() async {
        activityIndicator.startAnimating()
        messageLabel.isHidden = true
        tableView.isHidden = true

        guard let token = session.token else {
            activityIndicator.stopAnimating()
            showMessage("Sessione scaduta, accedi di nuovo.")
            return
        }

        let sessioneValida = await viewModel.loadDocuments(token: token)
        activityIndicator.stopAnimating()

        guard sessioneValida else {
            session.logout()
            dismiss(animated: true)
            return
        }

        if let errorMessage = viewModel.errorMessage {
            showMessage(errorMessage)
        } else if viewModel.documents.isEmpty {
            showMessage("Nessun documento disponibile.")
        } else {
            tableView.isHidden = false
            tableView.reloadData()
        }
    }

    private func showMessage(_ text: String) {
        messageLabel.text = text
        messageLabel.isHidden = false
        tableView.isHidden = true
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension DocumentsViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.documents.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "DocumentCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier) ?? UITableViewCell(style: .subtitle, reuseIdentifier: identifier)

        let document = viewModel.documents[indexPath.row]
        cell.textLabel?.text = document.title
        cell.textLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        cell.detailTextLabel?.text = document.date.formatted(date: .abbreviated, time: .omitted)
        cell.detailTextLabel?.textColor = .secondaryLabel
        cell.accessoryType = .disclosureIndicator

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let document = viewModel.documents[indexPath.row]
        let previewViewController = DocumentPreviewViewController(document: document, session: session)
        navigationController?.pushViewController(previewViewController, animated: true)
    }
}
