//
//  EmptyCollectionPlaceholderView.swift
//  Tracker
//
//  Created by Тимур Танеев on 07.08.2023.
//

import UIKit

enum PlaceholderType {
    case noData, emptyList
}

final class EmptyCollectionPlaceholderView: UIView {

    var placeholderType: PlaceholderType = .noData {
        didSet {
            switch placeholderType {
            case .noData:
                placeholderImage.image = circleStarImage
                placeholderLabel.text = noDataText
            case .emptyList:
                placeholderImage.image = monocleFaceImage
                placeholderLabel.text = emptyListText
            }
        }
    }

    private let circleStarImage = UIImage(named: "circleStar") ?? UIImage()
    private let monocleFaceImage = UIImage(named: "monocleFace") ?? UIImage()
    private let noDataText = "Что будем отслеживать?"
    private let emptyListText = "Ничего не найдено"

    private lazy var placeholderImage = {
        let image = circleStarImage
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var placeholderLabel = {
        let label = UILabel()
        label.text = noDataText
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
