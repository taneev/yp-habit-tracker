//
//  FilterItemStackSelector.swift
//  Tracker
//
//  Created by Тимур Танеев on 19.09.2023.
//

import Foundation

protocol FilterItemTapDelegate: AnyObject {
    func filterItemDidTap(_ itemKind: FilterItemKind)
}

final class FilterItemStackSelector: RoundedStackButtonSelector<FilterItem> {

    var selectedItem: FilterItemKind? {
        didSet {
            guard let selectedItem else {
                selectItem(at: nil)
                return
            }
            selectItem(at: filterItems?.firstIndex(of: selectedItem))
        }
    }

    weak var filterDidSelectDelegate: FilterItemTapDelegate?

    private var filterItems: [FilterItemKind]?

    init?(
        filterItems: [FilterItemKind] = FilterItemKind.allCases,
        selectedItem: FilterItemKind? = .all
    ) {
        let selectedItemIndex = selectedItem == nil ? nil : filterItems.firstIndex(of: selectedItem!)
        let views = filterItems.enumerated().map { index, kind in
            let view = FilterItem(filterKind: kind)
            view.text = kind.localizedRawValue
            view.isChecked = index == selectedItemIndex
            return view
        }
        super.init(selectedIndex: selectedItemIndex, views: views)
        self.selectedItem = selectedItem
        self.filterItems = filterItems
        arrangedSubviews.forEach { view in
            guard let itemView = view as? FilterItem else { return }
            itemView.delegate = self
        }
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension FilterItemStackSelector: SelectItemDelegate {
    func itemDidTap(_ itemKind: FilterItemKind) {
        selectItem(at: filterItems?.firstIndex(of: itemKind))
        filterDidSelectDelegate?.filterItemDidTap(itemKind)
    }
}
