//
//  RoundedViewsStackView.swift
//  Tracker
//
//  Created by Тимур Танеев on 17.08.2023.
//

import UIKit

class RoundedViewsStackView: UIStackView {

    override init(frame: CGRect) {
        super.init(frame: .zero)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    convenience init(arrangedSubviews: [StackRoundedView]) {
        self.init(frame: .zero)
        axis = .vertical
        alignment = .fill
        distribution = .equalSpacing

        if arrangedSubviews.isEmpty {
            return
        }

        if arrangedSubviews.count == 1 {
            arrangedSubviews[0].roundedCornerStyle = .topAndBottom
            addArrangedSubview(arrangedSubviews[0])
        }
        else if arrangedSubviews.count > 1 {
            for (i, subview) in arrangedSubviews.enumerated() {
                switch i {
                case 0:
                    subview.roundedCornerStyle = .topOnly
                case arrangedSubviews.count-1:
                    subview.roundedCornerStyle = .bottomOnly
                default:
                    subview.roundedCornerStyle = .notRounded
                }
                addArrangedSubview(subview)
            }
        }
    }

}
