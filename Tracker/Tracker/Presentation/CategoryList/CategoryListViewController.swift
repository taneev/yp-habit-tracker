//
//  CategoryListViewController.swift
//  Tracker
//
//  Created by Тимур Танеев on 06.09.2023.
//

import UIKit

class CategoryListViewController: UIViewController {

    private lazy var placholderView = { createPlaceholderView() }()
    private lazy var tableView = { createTableView() }()
    private lazy var addCategoryButton = RoundedButton(title: "Добавить категорию")

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
}

// MARK: UITableViewDataSource

extension CategoryListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        UITableViewCell()
    }
}

// MARK: UITableViewDelegate

extension CategoryListViewController: UITableViewDelegate {

}

// MARK: Setup & Layout UI

private extension CategoryListViewController {
    func setupUI() {

        view.backgroundColor = .ypWhiteDay

        let title = TitleLabel(title: "Категория")
        view.addSubview(title)
        view.addSubview(tableView)
        view.addSubview(placholderView)
        view.addSubview(addCategoryButton)

        NSLayoutConstraint.activate([
            title.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            title.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),
        ])

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 38),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -20)
        ])

        NSLayoutConstraint.activate([
            placholderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placholderView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        NSLayoutConstraint.activate([
            addCategoryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }

    func createPlaceholderView() -> PlaceholderView {
        let view = PlaceholderView()
        view.placeholderText = "Привычки и события можно\n объединить по смыслу"
        view.placeholderImage = UIImage(named: "circleStar") ?? UIImage()
        return view
    }

    func createTableView() -> UITableView {
        let view = UITableView()
        view.dataSource = self
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
}
