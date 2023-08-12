//
//  RoundedButton.swift
//  Tracker
//
//  Created by Тимур Танеев on 12.08.2023.
//

import UIKit

class RoundedButton: UIButton {

//    var title: String? {
//        didSet {
//            setTitleStyle(title: title)
//        }
//    }
//
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    convenience init(title: String) {
        self.init(frame: .zero)
        setTitleStyle(title: title)
        applyStyle()
    }

    private func applyStyle() {
        layer.cornerRadius = 16
        layer.masksToBounds = true
        backgroundColor = .ypBlackDay
        translatesAutoresizingMaskIntoConstraints = false
    }

    private func setTitleStyle(title: String?) {
        setTitle(title, for: .normal)
        titleLabel?.textColor = .ypWhiteDay
        titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel?.textAlignment = .center
    }
}
