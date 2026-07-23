//
//  MainTabBarController.swift
//  DemoAppUIKit
//
//  Created by Davide Cidu on 22/07/2026.
//

import UIKit

final class MainTabBarController: UITabBarController {

    private let session: SessionManager
    private let viewModel = ContentViewModel()

    /// Chiamata quando la sessione non è più valida (401) o l'utente fa logout dal Profilo.
    var onLogout: (() -> Void)?

    init(session: SessionManager) {
        self.session = session
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) non è supportato")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        showLoadingScreen()
        Task { await loadData() }
    }

    // MARK: - Caricamento dati

    private func loadData() async {
        guard let token = session.token else {
            onLogout?()
            return
        }

        let sessioneValida = await viewModel.loadData(token: token)

        guard sessioneValida else {
            onLogout?()
            return
        }

        guard let costumer = viewModel.costumer else {
            showError(viewModel.errorMessage ?? "Errore nel caricamento dei dati.")
            return
        }

        setupTabs(costumer: costumer, transactions: viewModel.transactions)
    }

    /// Da richiamare quando torniamo alla Home dopo un pagamento, per aggiornare saldo e transazioni.
    private func reloadData() async {
        guard let token = session.token else {
            onLogout?()
            return
        }

        let sessioneValida = await viewModel.loadData(token: token)

        guard sessioneValida else {
            onLogout?()
            return
        }

        guard let costumer = viewModel.costumer,
              let homeViewController = viewControllers?.first as? HomeViewController else {
            return
        }

        homeViewController.update(costumer: costumer, transactions: viewModel.transactions)
        selectedIndex = 0
    }

    // MARK: - Stati intermedi

    private func showLoadingScreen() {
        tabBar.isHidden = true

        let loadingViewController = UIViewController()
        loadingViewController.view.backgroundColor = .systemBackground

        let indicator = UIActivityIndicatorView(style: .large)
        indicator.startAnimating()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        loadingViewController.view.addSubview(indicator)

        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: loadingViewController.view.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: loadingViewController.view.centerYAnchor)
        ])

        viewControllers = [loadingViewController]
    }

    private func showError(_ message: String) {
        tabBar.isHidden = true

        let errorViewController = UIViewController()
        errorViewController.view.backgroundColor = .systemBackground

        let label = UILabel()
        label.text = "Errore: \(message)"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        errorViewController.view.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: errorViewController.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: errorViewController.view.centerYAnchor),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: errorViewController.view.leadingAnchor, constant: 24),
            label.trailingAnchor.constraint(lessThanOrEqualTo: errorViewController.view.trailingAnchor, constant: -24)
        ])

        viewControllers = [errorViewController]
    }

    // MARK: - Tab vere e proprie

    private func setupTabs(costumer: CostumerProfile, transactions: [Transaction]) {
        let home = HomeViewController(costumer: costumer, transactions: transactions)
        home.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house.fill"), tag: 0)

        let payments = PaymentsViewController(session: session)
        payments.onPaymentCompleted = { [weak self] in
            Task { await self?.reloadData() }
        }
        payments.onSessionExpired = { [weak self] in
            self?.onLogout?()
        }
        payments.tabBarItem = UITabBarItem(title: "Pay", image: UIImage(systemName: "dollarsign.circle.fill"), tag: 1)

        let services = ServicesViewController()
        services.tabBarItem = UITabBarItem(title: "Servizi", image: UIImage(systemName: "bag.fill.badge.plus"), tag: 2)

        let profile = ProfileViewController(costumer: costumer, session: session)
        profile.onLogout = { [weak self] in
            self?.onLogout?()
        }
        profile.onShowDocuments = { [weak self] in
            guard let self else { return }
            let documentsViewController = DocumentsViewController(session: self.session)
            let navigationController = UINavigationController(rootViewController: documentsViewController)
            self.present(navigationController, animated: true)
        }
        profile.tabBarItem = UITabBarItem(title: "Profilo", image: UIImage(systemName: "person.circle.fill"), tag: 3)

        viewControllers = [home, payments, services, profile]
        tabBar.isHidden = false
        selectedIndex = 0
    }
}
