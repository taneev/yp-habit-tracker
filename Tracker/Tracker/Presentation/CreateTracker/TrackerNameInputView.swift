//
//  TrackerNameInputViewCell.swift
//  Tracker
//
//  Created by Тимур Танеев on 13.08.2023.
//

import UIKit

final class TrackerNameInputView: UIStackView {

    var isMaxLengthHintHidden = true {
        didSet {
            maxLengthHintView.isHidden = isMaxLengthHintHidden
        }
    }
    weak var delegate: UITextFieldDelegate? {
        didSet {
            inputTextField.delegate = delegate
        }
    }
    private lazy var inputTextField = { createInputTextField() }()
    private lazy var maxLengthHintView = { createHintView() }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .ypWhiteDay
        axis = .vertical
        spacing = 0
        addArrangedSubview(inputTextField)
        addArrangedSubview(maxLengthHintView)
        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            inputTextField.leadingAnchor.constraint(equalTo: leadingAnchor),
            inputTextField.topAnchor.constraint(equalTo: topAnchor),
            inputTextField.trailingAnchor.constraint(equalTo: trailingAnchor),
            inputTextField.heightAnchor.constraint(equalToConstant: 75),

            maxLengthHintView.leadingAnchor.constraint(equalTo: leadingAnchor),
            maxLengthHintView.topAnchor.constraint(equalTo: inputTextField.bottomAnchor),
            maxLengthHintView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        maxLengthHintView.isHidden = isMaxLengthHintHidden
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    convenience init(delegate: UITextFieldDelegate, placeholder: String) {
        self.init(frame: .zero)
        inputTextField.delegate = delegate
        inputTextField.placeholder = placeholder
    }

}

// MARK: Layout
private extension TrackerNameInputView {
    func createInputTextField() -> NameInputTextField {
        let textField = NameInputTextField()
        textField.placeholder = "Введите название трекера"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }

    func createHintView() -> TrackerNameInputFooterView {
        let hintView = TrackerNameInputFooterView()
        return hintView
    }
}

// MARK: NameInputTextField
class NameInputTextField: UITextField {

    private let insets = UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 41)

    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: insets)
    }

    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: insets)
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: insets)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 16
        layer.masksToBounds = true
        backgroundColor = .ypBackgroundDay
        clearButtonMode = .whileEditing
        textColor = .ypBlackDay
        font = UIFont.systemFont(ofSize: 17, weight: .regular)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
