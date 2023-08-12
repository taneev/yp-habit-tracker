//
//  NewTrackerViewController.swift
//  Tracker
//
//  Created by Тимур Танеев on 12.08.2023.
//

import UIKit

class NewTrackerViewController: UIViewController {

    var isRegular: Bool!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
    }
}

// MARK: Layout
private extension NewTrackerViewController {
    func setupSubviews() {
        view.backgroundColor = .ypWhiteDay

        let titleText = isRegular ? "Новая привычка" : "Новое нерегулярное событие"
        let title = TitleLabel(title: titleText)
        view.addSubview(title)

        NSLayoutConstraint.activate([
            title.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            title.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),
        ])
    }
}
