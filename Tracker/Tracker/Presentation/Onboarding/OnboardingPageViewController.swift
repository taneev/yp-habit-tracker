//
//  OnboardingPageViewController.swift
//  Tracker
//
//  Created by Тимур Танеев on 05.09.2023.
//

import UIKit

final class OnboardingPageViewController: UIViewController {

    var backgroundImageName: String? {
        didSet {
            guard let backgroundImageName else {return}
            pageBackgroundImageView.image = UIImage(named: backgroundImageName)
        }
    }
    var pageMainMessage: String? {
        didSet {
            pageMessageLabel.text = pageMainMessage
        }
    }

    private lazy var pageMessageLabel = { createPageMessageLabel() }()
    private lazy var pageBackgroundImageView = { createBackgroundImage() }()

    override func viewDidLoad() {
        super.viewDidLoad()

        addSubviews()
    }
}

// MARK: Setup & Layout UI

private extension OnboardingPageViewController {

    func createPageMessageLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textColor = UIColor.ypBlackDay
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = pageMainMessage
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    func createBackgroundImage() -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        if let backgroundImageName {
            imageView.image = UIImage(named: backgroundImageName)
        }
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }

    func addSubviews() {

        view.addSubview(pageBackgroundImageView)
        view.addSubview(pageMessageLabel)

        NSLayoutConstraint.activate([
            pageMessageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageMessageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            pageMessageLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -250),

            pageBackgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageBackgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            pageBackgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageBackgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)

        ])
    }
}
