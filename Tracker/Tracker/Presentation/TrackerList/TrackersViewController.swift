//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Тимур Танеев on 01.08.2023.
//

import UIKit

protocol TrackersViewControllerProtocol: AnyObject, UISearchControllerDelegate {
    func addTrackerButtonDidTapped()
}

final class TrackersViewController: UIViewController {

    private lazy var navigationBar = { createNavigationBar() }()
    private lazy var collectionView = { createCollectionView() }()
    private lazy var emptyCollectionPlaceholder = { EmptyCollectionPlaceholderView() }()

    override func viewDidLoad() {
        super.viewDidLoad()

        addSubviews()
        addConstraints()
    }
}

// MARK: Layout
private extension TrackersViewController {

    func createNavigationBar() -> UINavigationBar {
        let bar = TrackerNavigationBar(frame: .zero,
                                       trackerBarDelegate: self)
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

            emptyCollectionPlaceholder.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            emptyCollectionPlaceholder.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor)
        ])
    }
}

extension TrackersViewController: TrackersViewControllerProtocol {
    func addTrackerButtonDidTapped() {
        print("add Tracker tapped")
    }
}


