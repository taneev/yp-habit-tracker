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
                isPlaceHolderHidden: { [weak self] in
                    self?.placeholderView.isHidden = ($0 == true)
                },
                selectedRow: { [weak self] indexPath in
                    guard let self,
                          let indexPath,
                          indexPath != self.tableView.indexPathForSelectedRow
                    else {return}

                    self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                },
                selectedCategory: { [weak self] category in
                    self?.categorySelectionDelegate?.didSelect(category)
                    // Минимальная задержка для того, чтобы пользователь успел увидеть
                    // выбор другой категории
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                        self?.dismiss(animated: true)
                    }
                }
            )
            viewModel?.setBindings(bindings)
        }
    }
    var categorySelectionDelegate: CategorySelectionDelegate?

    private lazy var placeholderView = { createPlaceholderView() }()
    private lazy var tableView = { createTableView() }()
    private lazy var addCategoryButton = RoundedButton(title: "Добавить категорию")

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        viewModel?.viewDidLoad()
        tableView.reloadData()
    }

    @objc func addCategoryButtonDidTap() {
        guard let saveDelegate = viewModel as? SaveCategoryDelegate else {return}
        let controller = CreateCategoryViewController()
        let createCategoryViewModel = CreateCategoryViewModel(saveCategoryDelegate: saveDelegate)
        controller.viewModel = createCategoryViewModel
        controller.modalPresentationStyle = .automatic
        present(controller, animated: true)
    }
}

// MARK: DataProviderDelegate

extension CategoryListViewController: DataProviderDelegate {
    func didUpdateIndexPath(_ updatedIndexes: UpdatedIndexes) {
        tableView.performBatchUpdates{
            tableView.insertRows(at: updatedIndexes.insertedIndexes, with: .automatic)
            tableView.deleteRows(at: updatedIndexes.deletedIndexes, with: .automatic)
        }
    }
}

// MARK: UITableViewDataSource

extension CategoryListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel?.categoriesCount ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.reuseIdentifier,for: indexPath) as? CategoryCell
        else {return UITableViewCell(style: .default, reuseIdentifier: CategoryCell.reuseIdentifier)}

        cell.viewModel = viewModel?.cellViewModel(forCellAt: indexPath)
        return cell
    }
}

// MARK: UITableViewDelegate

extension CategoryListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        CGFloat(75)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? CategoryCell else {return}
        cell.viewModel?.didSelectRow(isInitialSelection: false)
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? CategoryCell else {return}
        cell.viewModel?.didDeselectRow()
    }

    func tableView(
        _ tableView: UITableView,
        contextMenuConfigurationForRowAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil,
                                          previewProvider: nil) {[weak self] _ in
            let editAction =
            UIAction(title: "Редактировать") { [weak self] _ in
                self?.viewModel?.editCategory(at: indexPath)
            }
            let deleteAction =
            UIAction(title: "Удалить",
                     attributes: .destructive) { [weak self] _ in
                self?.viewModel?.deleteCategory(at: indexPath)
            }
            return UIMenu(title: "", children: [editAction, deleteAction])
        }
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

        addCategoryButton.addTarget(
            self,
            action: #selector(addCategoryButtonDidTap),
            for: .touchUpInside
        )
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
        let zeroHeader = UIView(frame: .zero)
        // Простой .zero не убирает хедер таблицы, нужна минимальная высота
        zeroHeader.frame.size.height = .leastNormalMagnitude
        view.tableHeaderView = zeroHeader
        view.backgroundColor = .ypWhiteDay
        view.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        view.dataSource = self
        view.delegate = self
        view.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.reuseIdentifier)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
}
