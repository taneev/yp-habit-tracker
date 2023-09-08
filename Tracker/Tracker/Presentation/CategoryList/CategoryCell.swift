//
//  CategoryCell.swift
//  Tracker
//
//  Created by Тимур Танеев on 06.09.2023.
//

import UIKit

class CategoryCell: UITableViewCell {

    static let reuseIdentifier = "CategoryCell"

    var viewModel: CategoryViewModelProtocol? {
        didSet {
            guard let viewModel else {return}

            let bindings = CategoryViewModelBindings(
                categoryName: {[weak self] in
                    self?.setText(with: $0)
                })
            viewModel.setBinidings(bindings)
            viewModel.cellViewDidLoad()
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .ypBackgroundDay
        textLabel?.textColor = .ypBlackDay
        textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setText(with categoryName: String?) {
        textLabel?.text = categoryName
    }

    override func prepareForReuse() {
        viewModel = nil
    }
}
