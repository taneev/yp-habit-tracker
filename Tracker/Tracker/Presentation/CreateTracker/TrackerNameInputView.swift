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

    var text: String {
        get {
            inputTextField.text ?? ""
        }
        set {
            inputTextField.text = newValue
        }
    }

    weak var delegate: UITextFieldDelegate? {
        didSet {
            inputTextField.delegate = delegate
        }
    }

    override var isFirstResponder: Bool {
        get {
            return inputTextField.isFirstResponder
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

    override func resignFirstResponder() -> Bool {
        return inputTextField.resignFirstResponder()
    }

}

// MARK: Layout
private extension TrackerNameInputView {
    func createInputTextField() -> NameInputTextField {
        let textField = NameInputTextField()
        textField.placeholder = "Введите название трекера"
        return textField
    }

    func createHintView() -> TrackerNameInputFooterView {
        let hintView = TrackerNameInputFooterView()
        return hintView
    }
}
