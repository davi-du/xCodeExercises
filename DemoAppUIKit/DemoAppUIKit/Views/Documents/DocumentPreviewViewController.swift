//
//  DocumentPreviewViewController.swift
//  DemoAppUIKit
//
//  Created by Davide Cidu on 22/07/2026.
//

//
//  Equivalente UIKit di DocumentPreviewView.swift. Il PDFKitView (UIViewRepresentable
//  che avvolgeva PDFView per SwiftUI) qui non serve: usa PDFView direttamente.
//

import UIKit
import PDFKit

final class DocumentPreviewViewController: UIViewController {

    private let document: DocumentSummary
    private let session: SessionManager

    init(document: DocumentSummary, session: SessionManager) {
        self.document = document
        self.session = session
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) non è supportato")
    }

    // MARK: - UI

    private let pdfView: PDFView = {
        let view = PDFView()
        view.autoScales = true
        view.isHidden = true
        return view
    }()

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
        title = document.title
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .systemBackground

        buildLayout()
        Task { await loadDocument() }
    }

    // MARK: - Layout

    private func buildLayout() {
        [pdfView, activityIndicator, messageLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        view.addSubview(pdfView)
        view.addSubview(activityIndicator)
        view.addSubview(messageLabel)

        NSLayoutConstraint.activate([
            pdfView.topAnchor.constraint(equalTo: view.topAnchor),
            pdfView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pdfView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pdfView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            messageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            messageLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            messageLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24)
        ])

        activityIndicator.startAnimating()
    }

    // MARK: - Caricamento

    private func loadDocument() async {
        guard let token = session.token else {
            showMessage("Sessione scaduta, accedi di nuovo.")
            activityIndicator.stopAnimating()
            return
        }

        do {
            let pdfData = try await CustomerService.fetchDocumentFile(id: document.id, token: token)
            if let pdfDocument = PDFDocument(data: pdfData) {
                pdfView.document = pdfDocument
                pdfView.isHidden = false
            } else {
                showMessage("Impossibile aprire il documento.")
            }
        } catch APIError.unauthorized {
            showMessage("Sessione scaduta, accedi di nuovo.")
            session.logout()
        } catch {
            showMessage("Impossibile scaricare il documento.")
        }

        activityIndicator.stopAnimating()
    }

    private func showMessage(_ text: String) {
        messageLabel.text = text
        messageLabel.isHidden = false
    }
}
