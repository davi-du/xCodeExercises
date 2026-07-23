//
//  ServiceCardCell.swift
//  DemoAppUIKit
//
//  Created by Davide Cidu on 22/07/2026.
//


//
//  ServiceCardCell.swift
//  DemoApp
//
//  Equivalente UIKit di ServiceCardView.swift: card blu 140x140 con icona,
//  titolo e descrizione, usata dentro la UICollectionView di ServicesViewController.
//

import UIKit

final class ServiceCardCell: UICollectionViewCell {

    static let reuseIdentifier = "ServiceCardCell"

    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.black.cgColor
        return view
    }()

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        buildLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) non è supportato")
    }

    private func buildLayout() {
        let textStack = UIStackView(arrangedSubviews: [iconImageView, titleLabel, descriptionLabel])
        textStack.axis = .vertical
        textStack.alignment = .center
        textStack.spacing = 6
        textStack.translatesAutoresizingMaskIntoConstraints = false

        cardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cardView)
        cardView.addSubview(textStack)

        NSLayoutConstraint.activate([
            cardView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            cardView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            cardView.widthAnchor.constraint(equalToConstant: 140),
            cardView.heightAnchor.constraint(equalToConstant: 140),

            textStack.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            textStack.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            textStack.leadingAnchor.constraint(greaterThanOrEqualTo: cardView.leadingAnchor, constant: 8),
            textStack.trailingAnchor.constraint(lessThanOrEqualTo: cardView.trailingAnchor, constant: -8),

            iconImageView.heightAnchor.constraint(equalToConstant: 36)
        ])
    }

    func configure(with offer: BankOffer) {
        iconImageView.image = UIImage(systemName: offer.iconName)
        titleLabel.text = offer.title
        descriptionLabel.text = offer.description
    }
}