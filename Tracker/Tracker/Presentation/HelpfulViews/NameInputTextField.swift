//
//  NameInputTextField.swift
//  Tracker
//
//  Created by Тимур Танеев on 13.08.2023.
//

import UIKit

final class NameInputTextField: UITextField {

    private let insets = UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 41)

    override public func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: insets)
    }

    override public func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: insets)
    }

    override public func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: insets)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 16
        layer.masksToBounds = true
        backgroundColor = .ypBackgroundDay
        clearButtonMode = .whileEditing
        textColor = .ypBlackDay
        font = UIFont.systemFont(ofSize: 17, weight: .regular)
        translatesAutoresizingMaskIntoConstraints = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
