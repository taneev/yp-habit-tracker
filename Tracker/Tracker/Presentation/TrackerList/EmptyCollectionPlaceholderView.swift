//
//  EmptyCollectionPlaceholderView.swift
//  Tracker
//
//  Created by Тимур Танеев on 07.08.2023.
//

import UIKit

class EmptyCollectionPlaceholderView: UIView {

    private lazy var placeholderImage = {
        let image = UIImage(named: "circleStar") ?? UIImage()
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var placeholderLabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlackDay
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        translatesAutoresizingMaskIntoConstraints = false
        addSubview(placeholderImage)
        addSubview(placeholderLabel)
        NSLayoutConstraint.activate([
            placeholderImage.topAnchor.constraint(equalTo: topAnchor),
            placeholderImage.heightAnchor.constraint(equalToConstant: 80),
            placeholderImage.widthAnchor.constraint(equalToConstant: 80),
            placeholderImage.bottomAnchor.constraint(equalTo: placeholderLabel.topAnchor),
            placeholderImage.centerXAnchor.constraint(equalTo: placeholderLabel.centerXAnchor),
            placeholderLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            placeholderLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            placeholderLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
