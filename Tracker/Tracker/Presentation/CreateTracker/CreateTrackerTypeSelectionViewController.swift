//
//  CreateTrackerTypeSelectionViewController.swift
//  Tracker
//
//  Created by Тимур Танеев on 12.08.2023.
//

import UIKit

final class CreateTrackerTypeSelectionViewController: UIViewController {

    weak var saverDelegate: NewTrackerSaverDelegate?
    private lazy var habitButton = { RoundedButton(title: "Привычка") }()
    private lazy var irregularEventButton = { RoundedButton(title: "Нерегулярное событие") }()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupSubviews()
        addButtonTargets()
    }

    @objc private func habitButtonDidTap() {
        createTracker(isRegular: true)
    }

    @objc private func irregularEventButtonDidTap() {
        createTracker(isRegular: false)
    }

    private func createTracker(isRegular: Bool) {
        let viewController = NewTrackerViewController()
        viewController.isRegular = isRegular
        viewController.saverDelegate = saverDelegate
        present(viewController, animated: true)
    }

    private func addButtonTargets(){
        habitButton.addTarget(
                self,
                action: #selector(habitButtonDidTap),
                for: .touchUpInside
        )
        irregularEventButton.addTarget(
                self,
                action: #selector(irregularEventButtonDidTap),
                for: .touchUpInside
        )
    }
}

// MARK: Layout
private extension CreateTrackerTypeSelectionViewController {

    func setupSubviews() {
        view.backgroundColor = .ypWhiteDay

        let titleLabel = TitleLabel(title: "Создание трекера")
        view.addSubview(titleLabel)

        let vButtonStackView = UIStackView(arrangedSubviews: [habitButton, irregularEventButton])
        vButtonStackView.axis = .vertical
        vButtonStackView.spacing = 16

        vButtonStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(vButtonStackView)

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),

            vButtonStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            vButtonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            vButtonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            vButtonStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 43),

            habitButton.heightAnchor.constraint(equalToConstant: 60),
            irregularEventButton.heightAnchor.constraint(equalTo: habitButton.heightAnchor),
        ])
    }
}
