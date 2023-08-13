//
//  TrackerActionsViewCell.swift
//  Tracker
//
//  Created by Тимур Танеев on 13.08.2023.
//

import UIKit

enum ActionButton: Int {
    case category = 0
    case schedule
}

final class TrackerActionsViewCell: UITableViewCell {

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configCell(for buttonType: ActionButton) {

    }

}
