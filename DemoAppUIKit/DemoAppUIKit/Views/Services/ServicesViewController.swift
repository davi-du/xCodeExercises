//
//  ServicesViewController.swift
//  DemoAppUIKit
//
//  Created by Davide Cidu on 22/07/2026.
//


//
//  ServicesViewController.swift
//  DemoApp
//
//  Equivalente UIKit di ServicesView.swift: la LazyVGrid a 2 colonne diventa
//  una UICollectionView con UICollectionViewCompositionalLayout.
//

import UIKit

final class ServicesViewController: UIViewController {

    private let offers: [BankOffer] = [
        BankOffer(title: "Bonifici", description: "Invia denaro ovunque, in tempo reale.", iconName: "arrow.left.arrow.right"),
        BankOffer(title: "Prestiti", description: "Liquidità su misura per i tuoi progetti.", iconName: "banknote.fill"),
        BankOffer(title: "Mutui", description: "Realizza la casa dei tuoi sogni.", iconName: "house.fill"),
        BankOffer(title: "Assicurazioni", description: "Proteggi te, la famiglia e i tuoi beni.", iconName: "shield.fill"),
        BankOffer(title: "Investimenti", description: "Fai crescere i tuoi risparmi nel tempo.", iconName: "chart.line.uptrend.xyaxis"),
        BankOffer(title: "Carte", description: "Carte di debito e credito su misura.", iconName: "creditcard.fill")
    ]

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Scopri i nostri servizi"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        return label
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        collectionView.backgroundColor = .systemBackground
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        buildLayout()
        configureCollectionView()
    }

    // MARK: - Layout

    private func buildLayout() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(titleLabel)
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func configureCollectionView() {
        collectionView.dataSource = self
        collectionView.register(ServiceCardCell.self, forCellWithReuseIdentifier: ServiceCardCell.reuseIdentifier)
    }

    /// Grid a 2 colonne, ogni riga alta 172pt (card 140x140 + un po' di margine), equivalente
    /// del LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) di SwiftUI.
    private func makeLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(172))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 16, trailing: 16)

        return UICollectionViewCompositionalLayout(section: section)
    }
}

// MARK: - UICollectionViewDataSource

extension ServicesViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        offers.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ServiceCardCell.reuseIdentifier, for: indexPath) as! ServiceCardCell
        cell.configure(with: offers[indexPath.item])
        return cell
    }
}