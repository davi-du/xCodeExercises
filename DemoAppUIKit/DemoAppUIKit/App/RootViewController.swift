//
//  RootViewController.swift
//  DemoApp
//

import UIKit

final class RootViewController: UIViewController {

    private let session = SessionManager()
    private var currentChild: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        showInitialScreen()
    }

    private func showInitialScreen() {
        if session.isAuthenticated {
            showMainArea()
        } else {
            showLogin()
        }
    }

    private func showLogin() {
        let loginViewController = LoginViewController(session: session)
        loginViewController.onLoginSuccess = { [weak self] in
            self?.showMainArea()
        }
        display(loginViewController)
    }

    private func showMainArea() {
        let tabBarController = MainTabBarController(session: session)
        tabBarController.onLogout = { [weak self] in
            self?.showLogin()
        }
        display(tabBarController)
    }

    private func makePlaceholder(text: String) -> UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .systemBackground

        let label = UILabel()
        label.text = text
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: vc.view.leadingAnchor, constant: 24),
            label.trailingAnchor.constraint(lessThanOrEqualTo: vc.view.trailingAnchor, constant: -24)
        ])

        return vc
    }

    /// epr rimuovere il child corrente (se c'è) e installare quello nuovo come contenuto a fullscreen
    private func display(_ viewController: UIViewController) {
        if let currentChild {
            currentChild.willMove(toParent: nil)
            currentChild.view.removeFromSuperview()
            currentChild.removeFromParent()
        }

        addChild(viewController)
        viewController.view.frame = view.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(viewController.view)
        viewController.didMove(toParent: self)

        currentChild = viewController
    }
}
