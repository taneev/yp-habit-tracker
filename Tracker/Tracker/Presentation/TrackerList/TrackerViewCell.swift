//
//  TrackerViewCell.swift
//  Tracker
//
//  Created by Тимур Танеев on 08.08.2023.
//

import UIKit

protocol TrackerViewCellProtocol: AnyObject {
    func trackerDoneButtonDidTapped(for tracker: TrackerCoreData)
    func trackerCounterValue(for tracker: TrackerCoreData) -> Int
}

final class TrackerViewCell: UICollectionViewCell {
    static let cellIdentifier = "trackerCell"
    static let quantityCardHeight = CGFloat(58)

    weak var delegate: TrackerViewCellProtocol?
    var tracker: TrackerCoreData? {
        didSet {
            guard let tracker else {return}
            cellName = tracker.name
            cellColor = UIColor.ypColors(rawValue: tracker.color ?? "")?.color() ?? .clear
            emoji = tracker.emoji
        }
    }

    var quantity: Int? {
        didSet {
            guard let quantity
            else {
                quantityLabel.text = ""
                return
            }
            let daysText = TextHelper.getDaysText(for: quantity)
            quantityLabel.text = "\(quantity) \(daysText)"
        }
    }

    var isCompleted: Bool? {
        didSet {
            doneButton.setTitle((isCompleted == true) ? "✓" : "＋", for: .normal)
        }
    }

    var isDoneButtonEnabled: Bool? {
        didSet {
            // осознанно реализовал более привычную версию UI:
            // - недоступные кнопки (и только они) приглушаются цветом
            // - для выполненных/невыполненных меняется только title
            doneButton.alpha = (isDoneButtonEnabled == true) ? 1 : 0.3
        }
    }

    private var cellColor: UIColor? {
        didSet {
            trackerView.backgroundColor = cellColor
            doneButton.backgroundColor = cellColor
        }
    }
    private var cellName: String? {
        didSet {
            cellNameLabel.text = cellName
        }
    }
    private var emoji: String? {
        didSet {
            emojiLabel.text = emoji
        }
    }
    private var pinned: Bool = false {
        didSet {
            pinnedImageView.image = pinned ? pinImage : UIImage()
        }
    }

    private let pinImage = UIImage(systemName: "pin.fill") ?? UIImage()
    private let fontSize = CGFloat(12)
    private let buttonRadius = CGFloat(17)
    private var buttonLabelText: String { (isCompleted == true) ? "✓" : "＋" }

    private lazy var trackerView = { createTrackerView() }()
    private lazy var cellNameLabel = { createNameLabel() }()
    private lazy var emojiLabel = { createEmojiLabel() }()
    private lazy var pinnedImageView = { createPinnedImagedView() }()
    private lazy var quantityLabel = { createCounterLabel() }()
    private lazy var doneButton = { createDoneButton() }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func doneButtonDidTap() {
        guard let tracker else {
            assertionFailure("Не удалось определить ID трекера")
            return
        }

        if !(isDoneButtonEnabled == true) {return}

        isCompleted = !(isCompleted ?? false)
        delegate?.trackerDoneButtonDidTapped(for: tracker)
        quantity = delegate?.trackerCounterValue(for: tracker)
    }
}

private extension TrackerViewCell {
    func createTrackerView() -> UIView {
        let trackerView = UIView()
        trackerView.layer.cornerRadius = 16
        trackerView.layer.masksToBounds = true
        trackerView.translatesAutoresizingMaskIntoConstraints = false

        trackerView.addSubview(cellNameLabel)
        trackerView.addSubview(emojiLabel)
        trackerView.addSubview(pinnedImageView)
        return trackerView
    }

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

    func createCounterLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: fontSize, weight: .medium)
        label.tintColor = .ypBlackDay
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    func createDoneButton() -> UIButton {
        let button = UIButton()

        button.layer.cornerRadius = buttonRadius
        button.layer.masksToBounds = true

        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.contentMode = .center
        button.tintColor = .white

        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(doneButtonDidTap), for: .touchUpInside)
        return button
    }

    func addSubviews() {
        let quantityView = UIView()
        quantityView.translatesAutoresizingMaskIntoConstraints = false
        quantityView.addSubview(quantityLabel)
        quantityView.addSubview(doneButton)

        let vStackView = UIStackView()
        vStackView.axis = .vertical
        vStackView.translatesAutoresizingMaskIntoConstraints = false
        vStackView.addArrangedSubview(trackerView)
        vStackView.addArrangedSubview(quantityView)
        contentView.addSubview(vStackView)

        NSLayoutConstraint.activate([
            vStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            vStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            vStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            vStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            quantityView.heightAnchor.constraint(equalToConstant: Self.quantityCardHeight),
            quantityLabel.leadingAnchor.constraint(equalTo: quantityView.leadingAnchor, constant: 12),
            quantityLabel.topAnchor.constraint(equalTo: quantityView.topAnchor, constant: 16),
            quantityLabel.heightAnchor.constraint(equalToConstant: fontSize),
            quantityLabel.trailingAnchor.constraint(lessThanOrEqualTo: doneButton.leadingAnchor, constant: -8),

            doneButton.centerYAnchor.constraint(equalTo: quantityLabel.centerYAnchor),
            doneButton.widthAnchor.constraint(equalToConstant: buttonRadius*2),
            doneButton.heightAnchor.constraint(equalTo: doneButton.widthAnchor),
            doneButton.trailingAnchor.constraint(equalTo: quantityView.trailingAnchor, constant: -12),

            emojiLabel.leadingAnchor.constraint(equalTo: trackerView.leadingAnchor, constant: 12),
            emojiLabel.topAnchor.constraint(equalTo: trackerView.topAnchor, constant: 12),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),

            pinnedImageView.heightAnchor.constraint(equalToConstant: 24),
            pinnedImageView.widthAnchor.constraint(equalTo: pinnedImageView.heightAnchor),
            emojiLabel.heightAnchor.constraint(equalTo: pinnedImageView.heightAnchor),

            pinnedImageView.centerYAnchor.constraint(equalTo: emojiLabel.centerYAnchor),
            pinnedImageView.trailingAnchor.constraint(equalTo: trackerView.trailingAnchor, constant: -12),

            cellNameLabel.topAnchor.constraint(greaterThanOrEqualTo: emojiLabel.bottomAnchor, constant: 8),
            cellNameLabel.leadingAnchor.constraint(equalTo: trackerView.leadingAnchor, constant: 12),
            cellNameLabel.trailingAnchor.constraint(equalTo: trackerView.trailingAnchor, constant: -12),
            cellNameLabel.bottomAnchor.constraint(equalTo: trackerView.bottomAnchor, constant: -12)
        ])
    }
}
