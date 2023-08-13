//
//  TrackerActionsViewCell.swift
//  Tracker
//
//  Created by Тимур Танеев on 13.08.2023.
//

import UIKit

enum ActionButton: Int {
    case category = 0
    case schedule
}

final class TrackerActionsViewCell: UITableViewCell {

    private var buttonType: ActionButton?

    private lazy var buttonNameLabel = { createNameLabel() }()
    private lazy var buttonDetailLabel = { createDetailLabel() }()
    private lazy var actionButton = { createActionButton() }()

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        accessoryType = .disclosureIndicator
        accessoryView?.backgroundColor = .ypBackgroundDay
        backgroundColor = .ypBackgroundDay
        selectionStyle = .none

        contentView.addSubview(actionButton)

        NSLayoutConstraint.activate([
            actionButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            actionButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            actionButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -14)
        ])
        if let accessoryView {
            let trailingConstraint = NSLayoutConstraint(item: actionButton, attribute: .leading, relatedBy: .equal, toItem: accessoryView, attribute: .trailing, multiplier: 1, constant: 0)
            trailingConstraint.isActive = true
        }
        else {
            let trailingConstraint = NSLayoutConstraint(item: actionButton, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: 0)
            trailingConstraint.isActive = true
        }

        if !buttonDetailLabel.isHidden {
            let equalLabelHeights = NSLayoutConstraint(item: buttonNameLabel, attribute: .height, relatedBy: .equal, toItem: buttonDetailLabel, attribute: .height, multiplier: 1, constant: 0)
            equalLabelHeights.isActive = true
        }
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

    private func setDetailText(with text: String?) {
        guard let text else {
            buttonDetailLabel.isHidden = true
            return
        }
        buttonDetailLabel.isHidden = false
        buttonDetailLabel.text = text
    }


    func configCell(for buttonType: ActionButton, tracker: Tracker?, category: TrackerCategory?) {

        self.buttonType = buttonType


        switch buttonType {
        case .category:
            buttonNameLabel.text = "Категория"
            setDetailText(with: category?.name)
        case .schedule:
            buttonNameLabel.text = "Расписание"
            let detailedText = tracker?.schedule?
                                    .compactMap{ WeekDay.shortWeekdayText[$0] }
                                    .joined(separator: ", ")
            setDetailText(with: detailedText)
        }
    }

}
