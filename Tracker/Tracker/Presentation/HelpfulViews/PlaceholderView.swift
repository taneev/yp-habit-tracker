//
//  PlaceholderView.swift
//  Tracker
//
//  Created by Тимур Танеев on 06.09.2023.
//

import UIKit

class PlaceholderView: UIView {

    var placeholderImage: UIImage? {
        didSet {
            placeholderImageView.image = placeholderImage
        }
    }
    var placeholderText: String? {
        didSet {
            placeholderLabel.text = placeholderText
        }
    }

    private lazy var placeholderImageView = {
        let imageView = UIImageView(image: placeholderImage)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var placeholderLabel = {
        let label = UILabel()
        label.text = placeholderText
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .ypBlackDay
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        translatesAutoresizingMaskIntoConstraints = false
        addSubview(placeholderImageView)
        addSubview(placeholderLabel)
        NSLayoutConstraint.activate([
            placeholderImageView.topAnchor.constraint(equalTo: topAnchor),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80),
            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
            placeholderImageView.bottomAnchor.constraint(equalTo: placeholderLabel.topAnchor),
            placeholderImageView.centerXAnchor.constraint(equalTo: placeholderLabel.centerXAnchor),
            placeholderLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            placeholderLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            placeholderLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
