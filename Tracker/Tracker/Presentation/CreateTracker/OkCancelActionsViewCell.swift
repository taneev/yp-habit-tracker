//
//  OkCancelActionsViewCell.swift
//  Tracker
//
//  Created by Тимур Танеев on 13.08.2023.
//

import UIKit

final class OkCancelActionsViewCell: UITableViewCell {

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .ypBackgroundDay
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
