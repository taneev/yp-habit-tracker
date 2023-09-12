//
//  EmojiCollectionViewCell.swift
//  Tracker
//
//  Created by Тимур Танеев on 23.08.2023.
//

import UIKit

final class EmojiCollectionViewCell: UICollectionViewCell {

    static let reuseIdentifier = "emoji"

    var emoji: String? {
        didSet {
            guard let emoji else { return }
            emojiLabel.text = emoji
        }
    }

    override var isSelected: Bool {
        didSet {
            applyStyle(for: isSelected)
        }
    }

    private lazy var emojiLabel = { createEmojiLabel() }()
    

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true

        contentView.addSubview(emojiLabel)
        NSLayoutConstraint.activate([
            emojiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            emojiLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createEmojiLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    private func applyStyle(for isSelectedState: Bool) {
        contentView.backgroundColor = isSelectedState ? .ypBackgroundDay.withAlphaComponent(1) : .ypWhiteDay
    }
}

extension EmojiCollectionViewCell: PropertyCellProtocol {
    func config(with emoji: String) {
        self.emoji = emoji
    }
}
