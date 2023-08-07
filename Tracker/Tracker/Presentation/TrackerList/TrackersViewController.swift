//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Тимур Танеев on 01.08.2023.
//

import UIKit

final class TrackersViewController: UIViewController {

    private lazy var navigationBar = { createNavigationBar() }()
    private lazy var collectionView = { createCollectionView() }()
    private lazy var emptyCollectionPlaceholder = { EmptyCollectionPlaceholderView() }()

    override func viewDidLoad() {
        super.viewDidLoad()

        addSubviews()
        addConstraints()
    }

    @objc private func createTrackerTapped() {

        print("Create Tracker")
    }
}

// MARK: Layout
private extension TrackersViewController {

    func createNavigationBar() -> UINavigationBar {
        let bar = UINavigationBar(frame: .zero)
        bar.prefersLargeTitles = true

        let navigationItem = UINavigationItem()
        let leftBarItem = UIBarButtonItem(image: UIImage(systemName: "plus"),
                                          style: .plain,
                                          target: self,
                                          action: #selector(createTrackerTapped))
        navigationItem.leftBarButtonItem = leftBarItem
        navigationItem.title = "Трекеры"

        let rightBarItem = UIDatePicker()
        rightBarItem.datePickerMode = .date
        rightBarItem.preferredDatePickerStyle = .compact
        rightBarItem.locale = Locale(identifier: "ru_RU")
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBarItem)

        let searchController = UISearchController()
        searchController.delegate = self
        searchController.automaticallyShowsCancelButton = true
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск"
        navigationItem.searchController = searchController

        bar.isTranslucent = false
        bar.tintColor = .ypBlackDay
        bar.setItems([navigationItem], animated: true)
        bar.translatesAutoresizingMaskIntoConstraints = false

        return bar
    }

    func createCollectionView() -> UICollectionView {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }

    func addSubviews() {
        view.addSubview(navigationBar)
        view.addSubview(collectionView)
        view.addSubview(emptyCollectionPlaceholder)
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),

            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
 //       view.layoutIfNeeded()

        NSLayoutConstraint.activate([
            emptyCollectionPlaceholder.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            emptyCollectionPlaceholder.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor)
        ])
    }
}

extension TrackersViewController: UISearchControllerDelegate {

}


