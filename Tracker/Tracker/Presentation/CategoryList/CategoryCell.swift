//
//  CategoryCell.swift
//  Tracker
//
//  Created by Тимур Танеев on 06.09.2023.
//

import UIKit

class CategoryCell: UITableViewCell {

    static let reuseIdentifier = "CategoryCell"
    var viewModel: CategoryViewModel?

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
