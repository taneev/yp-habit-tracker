//
//  TrackerNameInputFooterView.swift
//  Tracker
//
//  Created by Тимур Танеев on 14.08.2023.
//

import UIKit

class TrackerNameInputFooterView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)

        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = .ypRed
        label.textAlignment = .center
        label.text = "Ограничение 38 символов"
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
