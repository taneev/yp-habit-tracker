//
//  RoundedButton.swift
//  Tracker
//
//  Created by Тимур Танеев on 12.08.2023.
//

import UIKit

enum RoundedButtonStyle {
    case normal, disabled, cancel
}

class RoundedButton: UIButton {

    var roundedButtonStyle: RoundedButtonStyle = .normal {
        didSet {
            isEnabled = roundedButtonStyle != .disabled
            applyStyle()
        }
    }
    private var titleText: String = ""

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    convenience init(title: String, style: RoundedButtonStyle = .normal) {
        self.init(frame: .zero)
        self.roundedButtonStyle = style
        self.titleText = title
        translatesAutoresizingMaskIntoConstraints = false
        applyStyle()
    }

    private func applyStyle() {
        contentEdgeInsets = UIEdgeInsets(top: 14, left: 20, bottom: 14, right: 20)
        layer.cornerRadius = 16
        layer.masksToBounds = true
        switch roundedButtonStyle {
        case .cancel:
            backgroundColor = .ypWhiteDay
            layer.borderWidth = 1
            layer.borderColor = UIColor.ypRed.cgColor
        case .normal:
            backgroundColor = .ypBlackDay
        case .disabled:
            isEnabled = false
            backgroundColor = .ypGray
        }

        setTitle(titleText, for: .normal)
        if roundedButtonStyle == .cancel {
            setTitleColor(.ypRed, for: .normal)
        } else {
            setTitleColor(.ypWhiteDay, for: .normal)
        }
        titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel?.textAlignment = .center
    }
}
