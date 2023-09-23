//
//  TrackersFilterViewController.swift
//  Tracker
//
//  Created by Тимур Танеев on 18.09.2023.
//

import UIKit

class TrackersFilterViewController: UIViewController {

    var selectedItem: FilterItemKind?
    weak var filterSelectionDelegate: FilterSelectionDelegate?
    private lazy var filterStack = { createFilterStack() }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
}

// MARK: Setup & layout UI

private extension TrackersFilterViewController {

    func createFilterStack() -> FilterItemStackSelector? {
        let stack = FilterItemStackSelector(selectedItem: selectedItem)
        stack?.filterDidSelectDelegate = self
        stack?.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }

    func setupUI() {

        view.backgroundColor = .ypWhiteDay

        let title = TitleLabel(title: "filters.title".localized())
        view.addSubview(title)
        NSLayoutConstraint.activate([
            title.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            title.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),
        ])

        guard let filterStack = filterStack else { return }

        view.addSubview(filterStack)
        NSLayoutConstraint.activate([
            filterStack.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 38),
            filterStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            filterStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])

    }
}

// MARK: FilterItemTapDelegate

extension TrackersFilterViewController: FilterItemTapDelegate {
    func filterItemDidTap(_ itemKind: FilterItemKind) {
        filterSelectionDelegate?.filterDidSelect(itemKind)
        dismiss(animated: true)
    }
}
