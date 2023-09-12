//
//  CategoryCell.swift
//  Tracker
//
//  Created by Тимур Танеев on 06.09.2023.
//

import UIKit

class CategoryCell: UITableViewCell {

    static let reuseIdentifier = "CategoryCell"

    var viewModel: CategoryCellViewModelProtocol? {
        didSet {
            guard let viewModel else { return }
            bind(viewModel: viewModel)
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .ypBackgroundDay
        selectionStyle = .none
        textLabel?.textColor = .ypBlackDay
        textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
    }

    override func prepareForReuse() {
        viewModel = nil
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setText(with categoryName: String?) {
        textLabel?.text = categoryName
    }

    private func bind(viewModel: CategoryCellViewModelProtocol) {
        let bindings = CategoryCellViewModelBindings(
            categoryName: { [weak self] in
                self?.setText(with: $0)
            },
            isSelected: { [weak self] in
                self?.accessoryType = ($0 == true) ? .checkmark : .none
            })
        viewModel.setBinidings(bindings)
    }
}
