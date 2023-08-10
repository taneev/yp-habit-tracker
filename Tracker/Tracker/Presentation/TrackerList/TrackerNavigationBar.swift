//
//  TrackerNavigationBar.swift
//  Tracker
//
//  Created by Тимур Танеев on 08.08.2023.
//

import UIKit

class TrackerNavigationBar: UINavigationBar {

    private weak var trackerBarDelegate: TrackersBarControllerProtocol?
    private lazy var datePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.addTarget(self, action: #selector(currentDateDidChange), for: .valueChanged)
        return datePicker
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    convenience init(frame: CGRect,
                     trackerBarDelegate: TrackersBarControllerProtocol) {
        self.init(frame: frame)

        self.trackerBarDelegate = trackerBarDelegate

        prefersLargeTitles = true

        let navigationItem = UINavigationItem()
        let leftBarItem = UIBarButtonItem(image: UIImage(systemName: "plus"),
                                          style: .plain,
                                          target: self,
                                          action: #selector(createTrackerTapped))
        navigationItem.leftBarButtonItem = leftBarItem
        navigationItem.title = "Трекеры"

        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)

        let searchController = UISearchController()
        searchController.searchBar.delegate = self.trackerBarDelegate
        searchController.automaticallyShowsCancelButton = true
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск"
        navigationItem.searchController = searchController

        isTranslucent = false
        tintColor = .ypBlackDay
        setItems([navigationItem], animated: true)
        translatesAutoresizingMaskIntoConstraints = false
    }

    @objc private func createTrackerTapped() {
        trackerBarDelegate?.addTrackerButtonDidTapped()
    }

    @objc private func currentDateDidChange() {
        trackerBarDelegate?.currentDateDidChange(for: datePicker.date)
    }
}
