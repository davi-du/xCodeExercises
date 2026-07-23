//
//  LoginViewController.swift
//  DemoAppUIKit
//
//  Created by Davide Cidu on 22/07/2026.
//

import UIKit

final class LoginViewController: UIViewController {

    // MARK: - Dipendenze

    private let session: SessionManager
    private let viewModel = LoginViewModel()

    /// Chiamata quando il login ha successo, così il RootViewController può passare all'area autenticata.
    var onLoginSuccess: (() -> Void)?

    init(session: SessionManager) {
        self.session = session
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) non è supportato")
    }

    // MARK: - UI

    private let iconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "building.columns.fill"))
        imageView.tintColor = .systemBlue
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Accedi"
        label.font = .systemFont(ofSize: 34, weight: .bold)
        return label
    }()

    private let usernameField = LoginViewController.makeTextField(placeholder: "Nome utente")
    private let passwordField = LoginViewController.makeTextField(placeholder: "Password", isSecure: true)

    private let errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemRed
        label.font = .preferredFont(forTextStyle: .footnote)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    private let loginButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "Accedi"
        configuration.cornerStyle = .medium
        configuration.buttonSize = .large
        let button = UIButton(configuration: configuration)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        return button
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        return indicator
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        buildLayout()
        wireActions()
        updateLoginButtonState()

        let tapToDismiss = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapToDismiss)
    }

    // MARK: - Layout

    private func buildLayout() {
        let fieldsStack = UIStackView(arrangedSubviews: [usernameField, passwordField])
        fieldsStack.axis = .vertical
        fieldsStack.spacing = 16

        let mainStack = UIStackView(arrangedSubviews: [
            iconImageView,
            titleLabel,
            fieldsStack,
            errorLabel,
            loginButton
        ])
        mainStack.axis = .vertical
        mainStack.alignment = .fill
        mainStack.spacing = 24
        mainStack.setCustomSpacing(8, after: iconImageView)
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(mainStack)

        loginButton.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            mainStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 30),
            mainStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -30),
            mainStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),

            iconImageView.heightAnchor.constraint(equalToConstant: 60),

            usernameField.heightAnchor.constraint(equalToConstant: 50),
            passwordField.heightAnchor.constraint(equalToConstant: 50),
            loginButton.heightAnchor.constraint(equalToConstant: 50),

            activityIndicator.centerXAnchor.constraint(equalTo: loginButton.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: loginButton.centerYAnchor)
        ])
    }

    private static func makeTextField(placeholder: String, isSecure: Bool = false) -> UITextField {
        let field = UITextField()
        field.placeholder = placeholder
        field.isSecureTextEntry = isSecure
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.backgroundColor = UIColor(white: 0.95, alpha: 1)
        field.layer.cornerRadius = 10
        field.setLeftPadding(12)
        return field
    }

    // MARK: - Azioni

    private func wireActions() {
        usernameField.addTarget(self, action: #selector(usernameChanged), for: .editingChanged)
        passwordField.addTarget(self, action: #selector(passwordChanged), for: .editingChanged)
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
    }

    @objc private func usernameChanged() {
        viewModel.username = usernameField.text ?? ""
        updateLoginButtonState()
    }

    @objc private func passwordChanged() {
        viewModel.password = passwordField.text ?? ""
        updateLoginButtonState()
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func loginTapped() {
        Task { await performLogin() }
    }

    private func performLogin() async {
        setLoading(true)

        await viewModel.login(session: session)

        setLoading(false)
        updateLoginButtonState()

        if let errorMessage = viewModel.errorMessage {
            errorLabel.text = errorMessage
            errorLabel.isHidden = false
        } else {
            errorLabel.isHidden = true
            onLoginSuccess?()
        }
    }

    // MARK: - Stato UI

    private func setLoading(_ isLoading: Bool) {
        usernameField.isEnabled = !isLoading
        passwordField.isEnabled = !isLoading
        loginButton.isEnabled = !isLoading

        if isLoading {
            loginButton.configuration?.title = ""
            activityIndicator.startAnimating()
        } else {
            loginButton.configuration?.title = "Accedi"
            activityIndicator.stopAnimating()
        }
    }

    private func updateLoginButtonState() {
        let usernameEmpty = viewModel.username.trimmingCharacters(in: .whitespaces).isEmpty
        let passwordEmpty = viewModel.password.isEmpty
        loginButton.isEnabled = !usernameEmpty && !passwordEmpty
    }
}

// MARK: - Utility layout per i text field

private extension UITextField {
    /// applico un padding sinistro dato che in UIKit un UITextField non ha .padding() come SwiftUI.
    func setLeftPadding(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: frame.height))
        leftView = paddingView
        leftViewMode = .always
    }
}
