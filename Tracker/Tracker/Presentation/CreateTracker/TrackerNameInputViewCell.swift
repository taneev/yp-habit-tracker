//
//  TrackerNameInputViewCell.swift
//  Tracker
//
//  Created by Тимур Танеев on 13.08.2023.
//

import UIKit

final class TrackerNameInputViewCell: UITableViewCell {

    private lazy var inputTextField = { createInputTextField() }()

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .ypWhiteDay
        contentView.addSubview(inputTextField)

        NSLayoutConstraint.activate([
            inputTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            inputTextField.topAnchor.constraint(equalTo: contentView.topAnchor),
            inputTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            inputTextField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Layout
private extension TrackerNameInputViewCell {
    func createInputTextField() -> NameInputTextField {
        let textField = NameInputTextField()
        textField.placeholder = "Введите название трекера"
        textField.layer.cornerRadius = 16
        textField.layer.masksToBounds = true
        textField.backgroundColor = .green
        textField.clearButtonMode = .whileEditing
        textField.textColor = .ypBlackDay
        textField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        textField.translatesAutoresizingMaskIntoConstraints = false

        return textField
    }
}

private class NameInputTextField: UITextField {

    private let insets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 41)

    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: insets)
    }

    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: insets)
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: insets)
    }
}
