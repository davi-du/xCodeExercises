//
//  HomeViewController.swift
//  DemoAppUIKit
//
//  Created by Davide Cidu on 22/07/2026.
//

import UIKit

final class HomeViewController: UIViewController {

    private var costumer: CostumerProfile
    private var transactions: [Transaction]
    private var isBalanceVisible = true

    init(costumer: CostumerProfile, transactions: [Transaction]) {
        self.costumer = costumer
        self.transactions = transactions
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) non è supportato")
    }

    // MARK: - Header

    private let headerContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        return view
    }()

    private let welcomeLabel: UILabel = {
        let label = UILabel()
        label.text = "Benvenuto"
        label.font = .systemFont(ofSize: 20)
        label.textColor = .white
        return label
    }()

    private let fullNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .white
        return label
    }()

    private let bankIconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "dollarsign.bank.building"))
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let balanceCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        return view
    }()

    private let balanceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 28, weight: .bold)
        return label
    }()

    private let balanceToggleButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .label
        return button
    }()

    private let balanceCaptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Saldo al:"
        label.font = .systemFont(ofSize: 11)
        label.textColor = .secondaryLabel
        return label
    }()

    private let balanceDateLabel: UILabel = {
        let label = UILabel()
        label.text = Date().formatted(date: .numeric, time: .omitted)
        label.font = .systemFont(ofSize: 15)
        return label
    }()

    // MARK: - Lista

    private let tableView = UITableView(frame: .zero, style: .plain)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        fullNameLabel.text = costumer.fullName

        buildLayout()
        configureTableView()
        updateBalanceDisplay()

        balanceToggleButton.addTarget(self, action: #selector(toggleBalanceVisibility), for: .touchUpInside)
    }

    /// Chiamata da MainTabBarController dopo un pagamento, per rinfrescare saldo e lista.
    func update(costumer: CostumerProfile, transactions: [Transaction]) {
        self.costumer = costumer
        self.transactions = transactions
        fullNameLabel.text = costumer.fullName
        updateBalanceDisplay()
        tableView.reloadData()
    }

    // MARK: - Layout

    private func buildLayout() {
        let welcomeTextStack = UIStackView(arrangedSubviews: [welcomeLabel, fullNameLabel])
        welcomeTextStack.axis = .vertical
        welcomeTextStack.spacing = 2

        let welcomeRow = UIStackView(arrangedSubviews: [welcomeTextStack, bankIconImageView])
        welcomeRow.axis = .horizontal
        welcomeRow.alignment = .center
        bankIconImageView.setContentHuggingPriority(.required, for: .horizontal)

        let balanceTopRow = UIStackView(arrangedSubviews: [balanceLabel, balanceToggleButton])
        balanceTopRow.axis = .horizontal
        balanceTopRow.alignment = .center
        balanceTopRow.spacing = 8

        let balanceTextStack = UIStackView(arrangedSubviews: [balanceTopRow, balanceCaptionLabel, balanceDateLabel])
        balanceTextStack.axis = .vertical
        balanceTextStack.spacing = 4
        balanceTextStack.setCustomSpacing(10, after: balanceTopRow)

        [welcomeRow, balanceTextStack, headerContainerView, balanceCardView, tableView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        view.addSubview(headerContainerView)
        headerContainerView.addSubview(welcomeRow)
        headerContainerView.addSubview(balanceCardView)
        balanceCardView.addSubview(balanceTextStack)
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            headerContainerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            welcomeRow.topAnchor.constraint(equalTo: headerContainerView.safeAreaLayoutGuide.topAnchor, constant: 8),
            welcomeRow.leadingAnchor.constraint(equalTo: headerContainerView.leadingAnchor, constant: 16),
            welcomeRow.trailingAnchor.constraint(equalTo: headerContainerView.trailingAnchor, constant: -8),

            balanceCardView.topAnchor.constraint(equalTo: welcomeRow.bottomAnchor, constant: 16),
            balanceCardView.leadingAnchor.constraint(equalTo: headerContainerView.leadingAnchor, constant: 35),
            balanceCardView.trailingAnchor.constraint(equalTo: headerContainerView.trailingAnchor, constant: -35),
            balanceCardView.bottomAnchor.constraint(equalTo: headerContainerView.bottomAnchor, constant: -20),

            balanceTextStack.topAnchor.constraint(equalTo: balanceCardView.topAnchor, constant: 16),
            balanceTextStack.bottomAnchor.constraint(equalTo: balanceCardView.bottomAnchor, constant: -16),
            balanceTextStack.leadingAnchor.constraint(equalTo: balanceCardView.leadingAnchor, constant: 16),
            balanceTextStack.trailingAnchor.constraint(equalTo: balanceCardView.trailingAnchor, constant: -16),

            bankIconImageView.widthAnchor.constraint(equalToConstant: 50),
            bankIconImageView.heightAnchor.constraint(equalToConstant: 50),

            tableView.topAnchor.constraint(equalTo: headerContainerView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TransactionCell.self, forCellReuseIdentifier: TransactionCell.reuseIdentifier)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemBackground
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
    }

    // MARK: - Azioni

    @objc private func toggleBalanceVisibility() {
        isBalanceVisible.toggle()
        updateBalanceDisplay()
    }

    private func updateBalanceDisplay() {
        balanceLabel.text = isBalanceVisible
            ? costumer.accountBalance.formatted(.currency(code: "EUR"))
            : "••••••"
        balanceToggleButton.setImage(UIImage(systemName: isBalanceVisible ? "eye" : "eye.slash"), for: .normal)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        transactions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TransactionCell.reuseIdentifier, for: indexPath) as! TransactionCell
        cell.configure(with: transactions[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presentDetails(for: transactions[indexPath.row])
    }

    private func presentDetails(for transaction: Transaction) {
        let detailsViewController = TransactionDetailsViewController(transaction: transaction)

        if let sheet = detailsViewController.sheetPresentationController {
            sheet.detents = [.custom { _ in 200 }]
            sheet.preferredCornerRadius = 24
            sheet.prefersGrabberVisible = false
        }

        present(detailsViewController, animated: true)
    }
}
