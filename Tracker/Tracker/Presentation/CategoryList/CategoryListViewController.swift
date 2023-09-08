//
//  CategoryListViewController.swift
//  Tracker
//
//  Created by Тимур Танеев on 06.09.2023.
//

import UIKit

final class CategoryListViewController: UIViewController {

    var viewModel: CategoryListViewModelProtocol? {
        didSet {
            let bindings = CategoryListViewModelBindings(
                numberOfCategories: { [weak self] in
                    self?.categoriesCount = $0
                    self?.tableView.reloadData()
                },
                isPlaceHolderHidden: { [weak self] in
                    self?.placeholderView.isHidden = ($0 == true)
                }
            )
            viewModel?.setBindings(bindings)
        }
    }
    private var categoriesCount: Int?

    private lazy var placeholderView = { createPlaceholderView() }()
    private lazy var tableView = { createTableView() }()
    private lazy var addCategoryButton = RoundedButton(title: "Добавить категорию")

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        viewModel?.viewDidLoad()
    }
}

extension CategoryListViewController: DataProviderDelegate {
    func didUpdateIndexPath(_ updatedIndexes: UpdatedIndexes) {
        
    }
}

// MARK: UITableViewDataSource

extension CategoryListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categoriesCount ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let dataProvider = viewModel?.dataProvider,
              let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.reuseIdentifier,for: indexPath) as? CategoryCell
        else {return UITableViewCell(style: .default, reuseIdentifier: CategoryCell.reuseIdentifier)}

        cell.viewModel = CategoryViewModel(forCellAt: indexPath, dataProvider: dataProvider)
        return cell
    }
}

// MARK: UITableViewDelegate

extension CategoryListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        CGFloat(75)
    }
}

// MARK: Setup & Layout UI

private extension CategoryListViewController {
    func setupUI() {

        view.backgroundColor = .ypWhiteDay

        let title = TitleLabel(title: "Категория")
        view.addSubview(title)
        view.addSubview(tableView)
        view.addSubview(placeholderView)
        view.addSubview(addCategoryButton)

        NSLayoutConstraint.activate([
            title.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            title.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),
        ])

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 38),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -20)
        ])

        NSLayoutConstraint.activate([
            placeholderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
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
        let view = UITableView(frame: .zero, style: .insetGrouped)
        view.backgroundColor = .ypWhiteDay
        view.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        view.dataSource = self
        view.delegate = self
        view.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.reuseIdentifier)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
}
