//
//  TitleLabel.swift
//  Tracker
//
//  Created by Тимур Танеев on 12.08.2023.
//

import UIKit

class TitleLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    convenience init(title: String) {
        self.init(frame: .zero)
        setupTitle(title: title)
    }

    private func setupTitle(title: String) {
        text = title
        font = UIFont.systemFont(ofSize: 16, weight: .medium)
        textColor = .ypBlackDay
        textAlignment = .center
        translatesAutoresizingMaskIntoConstraints = false
    }
}
