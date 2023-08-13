//
//  NewTrackerTableUISection.swift
//  Tracker
//
//  Created by Тимур Танеев on 13.08.2023.
//

import UIKit


enum NewTrackerTableUISection {
    case trackerName(cellClass: UITableViewCell.Type, reuseIdentifier: String)
    case trackerButtons(cellClass: UITableViewCell.Type, reuseIdentifier: String)
    case emojiCollection(cellClass: UITableViewCell.Type, reuseIdentifier: String)
    case colorCollection(cellClass: UITableViewCell.Type, reuseIdentifier: String)
    case okCancelButtons(cellClass: UITableViewCell.Type, reuseIdentifier: String)
}

extension NewTrackerTableUISection {
    func dequeueReusableCell(in tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        switch self {
        case .trackerName(_, let reuseIdentifier),
                .trackerButtons(_, let reuseIdentifier),
                .emojiCollection(_, let reuseIdentifier),
                .colorCollection(_, let reuseIdentifier),
                .okCancelButtons(_, let reuseIdentifier):
            return tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        }
    }

    func register(in tableView: UITableView) {
        switch self {
        case .trackerName(let cellClass, let reuseIdentifier),
                .trackerButtons(let cellClass, let reuseIdentifier),
                .emojiCollection(let cellClass, let reuseIdentifier),
                .colorCollection(let cellClass, let reuseIdentifier),
                .okCancelButtons(let cellClass, let reuseIdentifier):
            tableView.register(cellClass, forCellReuseIdentifier: reuseIdentifier)
        }
    }
}
