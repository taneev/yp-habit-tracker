//
//  RoundedStackButtonSelector.swift
//  Tracker
//
//  Created by Тимур Танеев on 18.09.2023.
//

import Foundation

class RoundedStackButtonSelector<CheckableButton: RoundedCheckButton>: RoundedViewsStackView<CheckableButton> {

    private var selectedIndex: Int? {
        didSet {
            if oldValue != nil {
                (arrangedSubviews[oldValue!] as? CheckableButton)?.isChecked = false
            }
            if selectedIndex != nil {
                (arrangedSubviews[selectedIndex!] as? CheckableButton)?.isChecked = true
            }
        }
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(selectedIndex: Int?, views: [CheckableButton]) {
        self.selectedIndex = selectedIndex
        super.init(arrangedSubviews: views)
    }

    func selectItem(at index: Int?) {
        guard let index,
              index >= 0
        else {
            selectedIndex = nil
            return
        }
        selectedIndex = index < arrangedSubviews.count ? index : nil
    }
}
