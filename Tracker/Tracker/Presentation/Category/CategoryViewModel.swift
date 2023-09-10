//
//  CategoryViewModel.swift
//  Tracker
//
//  Created by Тимур Танеев on 09.09.2023.
//

import Foundation

struct CategoryViewModelBindings {
    let isOkButtonEnabled: (Bool?) -> Void
    let isCategoryDidCreated: (Bool?) -> Void
}

protocol CategoryViewModelProtocol {
    func setBindings(_ bindings: CategoryViewModelBindings)
    func viewDidLoad()
    func textFieldDidChange(to text: String?)
    func okButtonDidTap()
}

final class CategoryViewModel: CategoryViewModelProtocol {

    var saveCategoryDelegate: SaveCategoryDelegate

    @Observable
    private var isOkButtonEnabled: Bool?

    @Observable
    private var isCategoryDidCreated: Bool?
    private var categoryName: String?

    init(saveCategoryDelegate: SaveCategoryDelegate) {
        self.saveCategoryDelegate = saveCategoryDelegate
    }

    func setBindings(_ bindings: CategoryViewModelBindings) {
        self.$isOkButtonEnabled.bind(action: bindings.isOkButtonEnabled)
        self.$isCategoryDidCreated.bind(action: bindings.isCategoryDidCreated)
    }

    func viewDidLoad() {
        isOkButtonEnabled = false
    }

    func textFieldDidChange(to text: String?) {
        let normalizedName = normalized(categoryName: text)
        isOkButtonEnabled = !normalizedName.isEmpty
        categoryName = normalizedName
    }

    func okButtonDidTap() {
        if let categoryName {
            saveCategoryDelegate.saveNewCategory(with: categoryName)
            isCategoryDidCreated = true
        }
    }

    private func normalized(categoryName text: String?) -> String {
        return text?.trimmingCharacters(in: .whitespaces) ?? ""
    }
}
