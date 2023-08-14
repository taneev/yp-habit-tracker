//
//  NewTrackerViewController.swift
//  Tracker
//
//  Created by Тимур Танеев on 12.08.2023.
//

import UIKit

final class NewTrackerViewController: UIViewController {

    var isRegular: Bool!
    var newTracker: Tracker?
    var category: TrackerCategory?

    private var isTrackerNameInputFooterDisplayed: Bool = false

    private lazy var createTrackerTableView = { createTableView() }()
    private let uiSource: [NewTrackerTableUISection] = [
        .trackerName(cellClass: TrackerNameInputViewCell.self, reuseIdentifier: "trackerNameInputCell"),
        .trackerButtons(cellClass: TrackerActionsViewCell.self, reuseIdentifier: "trackerActionsViewCell"),
        .emojiCollection(cellClass: EmojiCollectionViewCell.self, reuseIdentifier: "emojiCollectionViewCell"),
        .colorCollection(cellClass: ColorCollectionViewCell.self, reuseIdentifier: "colorCollectionViewCell"),
        .okCancelButtons(cellClass: OkCancelActionsViewCell.self, reuseIdentifier: "okCancelButtonViewCell")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        registerCellTypes()
    }

    private func registerCellTypes() {
        uiSource.forEach { section in
            section.register(in: createTrackerTableView)
        }
    }
}

// MARK: Layout
private extension NewTrackerViewController {

    func createTitleLabel() -> TitleLabel {
        let titleText = isRegular ? "Новая привычка" : "Новое нерегулярное событие"
        let title = TitleLabel(title: titleText)
        return title
    }

    func createTableView() -> UITableView {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.dataSource = self
        table.delegate = self
        table.backgroundColor = .ypWhiteDay
        table.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }

    func setupSubviews() {
        view.backgroundColor = .ypWhiteDay

        let title = createTitleLabel()
        view.addSubview(title)
        view.addSubview(createTrackerTableView)

        NSLayoutConstraint.activate([
            title.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            title.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),

            createTrackerTableView.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 14),
            createTrackerTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            createTrackerTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            createTrackerTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

// MARK: UITableViewDataSource
extension NewTrackerViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        uiSource.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch uiSource[section] {
        case .trackerButtons:
            // Единственная секция с двумя ячейками - секция кнопок действий trackerButtons:
            // Категория и Расписание (для регулярной привычки)
            return isRegular ? 2 : 1
        default:
            return 1
        }
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        switch uiSource[section] {
        case .trackerName:
            return isTrackerNameInputFooterDisplayed ? TrackerNameInputFooterLabel() : nil
        default:
            return nil
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let sectionType = uiSource[indexPath.section]
        let cell = sectionType.dequeueReusableCell(in: tableView, indexPath: indexPath)
        if let actionButtonCell = cell as? TrackerActionsViewCell,
           let buttonType = ActionButton(rawValue: indexPath.row) {
            newTracker = Tracker(name: "Новый трекер", isRegular: true, emoji: "", color: .ypColorSelection1, schedule: [.fri, .sat, .tue])
            category = TrackerCategory(categoryID: UUID(), name: "Категория новая", activeTrackers: nil)

            var cornerStyle: CellRoundedCorderStyle?
            if isRegular {
                cornerStyle = buttonType == .category ? .topOnly : .bottomOnly
            }
            else {
                cornerStyle = .topAndBottom
            }
            actionButtonCell.configCell(for: buttonType,
                                        cornerStyle: cornerStyle ?? .defaultCorners,
                                        tracker: newTracker,
                                        category: category)
        }
        return cell
    }
}

extension NewTrackerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellType = uiSource[indexPath.section]
        switch cellType {
        case .trackerName, .trackerButtons:
            return CGFloat(75)
        case .okCancelButtons:
            return CGFloat(60)
        default:
            return CGFloat(204)
        }
    }
}