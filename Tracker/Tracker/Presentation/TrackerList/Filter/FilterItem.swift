//
//  FilterItem.swift
//  Tracker
//
//  Created by Тимур Танеев on 19.09.2023.
//

import UIKit

enum FilterItemKind: String, CaseIterable {
    case all = "filters.allTrackers"
    case today = "filters.currentDate"
    case completed = "filters.completed"
    case todo = "filters.uncompleted"

    var localizedRawValue: String {
        return self.rawValue.localized()
    }
}

protocol SelectItemDelegate: AnyObject {
    func itemDidTap(_ itemKind: FilterItemKind)
}

final class FilterItem: RoundedCheckButton {
    var filterKind: FilterItemKind {
        didSet {
            text = filterKind.localizedRawValue
        }
    }
    weak var delegate: SelectItemDelegate?

    init(filterKind: FilterItemKind) {
        self.filterKind = filterKind
        super.init(frame: .zero)
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(buttonDidTap))
        addGestureRecognizer(tapRecognizer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func buttonDidTap(_ sender: Any) {
        delegate?.itemDidTap(filterKind)
    }
}
