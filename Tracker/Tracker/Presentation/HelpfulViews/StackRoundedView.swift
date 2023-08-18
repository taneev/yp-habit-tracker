//
//  StackRoundedView.swift
//  Tracker
//
//  Created by Тимур Танеев on 13.08.2023.
//

import UIKit

enum RoundedCornerStyle {
    case topOnly
    case bottomOnly
    case topAndBottom
    case notRounded
}

class StackRoundedView: UIView {

    var roundedCornerStyle: RoundedCornerStyle? {
        didSet {
            setCornerStyle(roundedCornerStyle)
            // Сепаратор размещается по верхней границе. Поэтому для
            // одиноких и верхних ячеек стека он не отображается по умолчанию
            // В текущей версии не управляется снаружи
            separatorView.isHidden = [.topOnly, .topAndBottom].contains(roundedCornerStyle)
        }
    }

    var text: String = "" {
        didSet {
            buttonNameLabel.text = text
        }
    }

    var detailedText: String? {
        didSet {
            setDetailText(with: detailedText)
        }
    }

    private lazy var buttonNameLabel = { createNameLabel() }()
    private lazy var buttonDetailLabel = { createDetailLabel() }()
    private lazy var actionButton = { createActionButton() }()
    private lazy var separatorView = { createSeparatorView() }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .ypBackgroundDay
        addSubview(separatorView)
        addSubview(actionButton)
        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 75),

            actionButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            actionButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            // trailing = -75: выделено место для размещения '>' или элементов switch в расписании
            actionButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -75),

            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            separatorView.topAnchor.constraint(equalTo: topAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createNameLabel() -> UILabel {
        let buttonNameLabel = UILabel()
        buttonNameLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        buttonNameLabel.textColor = .ypBlackDay
        buttonNameLabel.textAlignment = .left
        buttonNameLabel.translatesAutoresizingMaskIntoConstraints = false
        return buttonNameLabel
    }

    private func createDetailLabel() -> UILabel {
        let detailLabel = UILabel()
        detailLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        detailLabel.textColor = .ypGray
        detailLabel.textAlignment = .left
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        return detailLabel
    }

    private func createActionButton() -> UIStackView {
        let vButtonStackView = UIStackView(arrangedSubviews: [buttonNameLabel, buttonDetailLabel])
        vButtonStackView.spacing = 2
        vButtonStackView.alignment = .leading
        vButtonStackView.axis = .vertical
        vButtonStackView.translatesAutoresizingMaskIntoConstraints = false
        return vButtonStackView
    }

    func createSeparatorView() -> UIView {
        let separatorView = UIView()
        separatorView.layer.borderColor = UIColor.ypGray.cgColor
        separatorView.layer.borderWidth = 0.5
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        return separatorView
    }

    private func setDetailText(with text: String?) {
        guard let text, !text.isEmpty else {
            buttonDetailLabel.isHidden = true
            return
        }
        buttonDetailLabel.isHidden = false
        buttonDetailLabel.text = text
    }

    private func setCornerStyle(_ cornerStyle: RoundedCornerStyle?) {
        layer.cornerRadius = 16
        layer.masksToBounds = true
        switch cornerStyle {
        case .topOnly:
            layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        case .bottomOnly:
            layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        case .topAndBottom:
            layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        default:
            layer.cornerRadius = 0
            layer.masksToBounds = false
        }
    }
}

