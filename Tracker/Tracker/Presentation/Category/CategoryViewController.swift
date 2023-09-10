//
//  CategoryViewController.swift
//  Tracker
//
//  Created by Тимур Танеев on 09.09.2023.
//

import UIKit

class CategoryViewController: UIViewController {

    var viewModel: CategoryViewModelProtocol? {
        didSet {
            let bindings = CategoryViewModelBindings(
                isOkButtonEnabled: {[weak self] isEnabled in
                    self?.okButton.roundedButtonStyle = isEnabled == true ? .normal : .disabled
                },
                isCategoryDidCreated: {[weak self] isDone in
                    guard let isDone, let self else {return}
                    if isDone {
                        self.dismiss(animated: true)
                    }
                }
            )
            viewModel?.setBindings(bindings)
        }
    }

    var completion: (() -> Void)?

    private lazy var inputNameField = NameInputTextField()
    private lazy var okButton = RoundedButton(title: "Готово")

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        viewModel?.viewDidLoad()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        completion?()
    }

    @objc private func okButtonDidTap() {
        viewModel?.okButtonDidTap()
    }

    @objc private func anyTap() {
        view.endEditing(true)
    }
}

extension CategoryViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        viewModel?.textFieldDidChange(to: textField.text)
    }
}

// MARK: Setup and layout UI

private extension CategoryViewController {
    func setupUI() {
        view.backgroundColor = .ypWhiteDay
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(anyTap))
        view.addGestureRecognizer(tapRecognizer)

        let title = TitleLabel(title: "Новая категория")
        view.addSubview(title)

        inputNameField.placeholder = "Введите название категории"
        inputNameField.delegate = self
        inputNameField.text = viewModel?.getInitialCategoryName()
        view.addSubview(inputNameField)

        okButton.addTarget(
                self,
                action: #selector(okButtonDidTap),
                for: .touchUpInside
        )
        view.addSubview(okButton)

        NSLayoutConstraint.activate([
            title.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            title.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),
        ])

        NSLayoutConstraint.activate([
            inputNameField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            inputNameField.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 38),
            inputNameField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            inputNameField.heightAnchor.constraint(equalToConstant: 75)
        ])

        NSLayoutConstraint.activate([
            okButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            okButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            okButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            okButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}
