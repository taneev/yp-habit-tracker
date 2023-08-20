//
//  StackRoundedSwitch.swift
//  Tracker
//
//  Created by Тимур Танеев on 17.08.2023.
//

import UIKit

class StackRoundedSwitch: StackRoundedView {

    var isOn: Bool {
        get {
            return switchView.isOn
        }
        set {
            switchView.isOn = newValue
        }
    }
    private lazy var switchView = { createSwitchView() }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(switchView)

        NSLayoutConstraint.activate([
            switchView.centerYAnchor.constraint(equalTo: centerYAnchor),
            switchView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createSwitchView() -> UISwitch {
        let switchView = UISwitch()
        switchView.setOn(false, animated: true)
        switchView.onTintColor = .ypBlue
        switchView.translatesAutoresizingMaskIntoConstraints = false
        return switchView
    }
}
