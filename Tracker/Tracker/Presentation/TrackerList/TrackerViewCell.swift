//
//  TrackerViewCell.swift
//  Tracker
//
//  Created by Тимур Танеев on 08.08.2023.
//

import UIKit

final class TrackerViewCell: UICollectionViewCell {
    static var cellIdentifier = "trackerCell"

    var cellColor: UIColor! {
        didSet {
            contentView.backgroundColor = cellColor
        }
    }
    var cellName: String! {
        didSet {
            cellNameLabel.text = cellName
        }
    }
    var emoji: String! {
        didSet {
            emojiLabel.text = emoji
        }
    }
    var pinned: Bool = false {
        didSet {
            pinnedImageView.image = pinned ? pinImage : UIImage()
        }
    }

    private let pinImage = UIImage(systemName: "pin.fill") ?? UIImage()
    private let fontSize = CGFloat(12)

    private lazy var cellNameLabel = { createNameLabel() }()
    private lazy var emojiLabel = { createEmojiLabel() }()
    private lazy var pinnedImageView = { createPinnedImagedView() }()


    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        addSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension TrackerViewCell {
    func createNameLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: fontSize, weight: .medium)
        label.textColor = .white
        label.textAlignment = .left
        label.numberOfLines = 2
        label.contentMode = .bottomLeft
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    func createEmojiLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: fontSize, weight: .medium)
        label.textAlignment = .center
        label.contentMode = .center
        label.backgroundColor = .white.withAlphaComponent(0.3)
        label.numberOfLines = 1
        label.layer.cornerRadius = 12
        label.layer.masksToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    func createPinnedImagedView() -> UIImageView {
        let pinImage = UIImage()
        let imageView = UIImageView(image: pinImage)
        imageView.tintColor = .white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }

    func addSubviews() {
        contentView.addSubview(cellNameLabel)
        contentView.addSubview(emojiLabel)
        contentView.addSubview(pinnedImageView)

        NSLayoutConstraint.activate([
            emojiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            emojiLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),

            pinnedImageView.heightAnchor.constraint(equalToConstant: 24),
            pinnedImageView.widthAnchor.constraint(equalTo: pinnedImageView.heightAnchor),
            emojiLabel.heightAnchor.constraint(equalTo: pinnedImageView.heightAnchor),

            pinnedImageView.centerYAnchor.constraint(equalTo: emojiLabel.centerYAnchor),
            pinnedImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),

            cellNameLabel.topAnchor.constraint(greaterThanOrEqualTo: emojiLabel.bottomAnchor, constant: 8),
            cellNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            cellNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            cellNameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
}
