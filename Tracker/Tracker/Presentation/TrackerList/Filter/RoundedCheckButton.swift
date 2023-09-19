//
//  StackRoundedButton.swift
//  Tracker
//
//  Created by Тимур Танеев on 18.09.2023.
//
import UIKit

class RoundedCheckButton: StackRoundedView {

    var isChecked: Bool = false {
        didSet {
            accessoryView.isHidden = !isChecked
        }
    }

    private lazy var accessoryView = { createAccessoryView() }()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(accessoryView)

        NSLayoutConstraint.activate([
            accessoryView.centerYAnchor.constraint(equalTo: centerYAnchor),
            accessoryView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }

    private func createAccessoryView() -> UIView {
        let accessoryImage = UIImage(systemName: "checkmark") ?? UIImage()
        let accessoryView = UIImageView(image: accessoryImage)
        accessoryView.contentMode = .center
        accessoryView.translatesAutoresizingMaskIntoConstraints = false
        accessoryView.tintColor = .ypBlue
        return accessoryView
    }
}
