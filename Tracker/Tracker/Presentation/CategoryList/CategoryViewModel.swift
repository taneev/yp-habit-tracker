//
//  CategoryViewModel.swift
//  Tracker
//
//  Created by Тимур Танеев on 06.09.2023.
//

import Foundation

struct CategoryViewModelBindings {
    let categoryName: (String?) -> Void
}

protocol CategoryViewModelProtocol {
    init(forCellAt indexPath: IndexPath, dataProvider: any CategoryDataProviderProtocol)
    func setBinidings(_ bindings: CategoryViewModelBindings)
    func cellViewDidLoad()
}

final class CategoryViewModel: CategoryViewModelProtocol {

    @Observable
    private var categoryName: String?

    private let indexPath: IndexPath
    private let dataProvider: any CategoryDataProviderProtocol

    init(forCellAt indexPath: IndexPath, dataProvider: any CategoryDataProviderProtocol) {
        self.indexPath = indexPath
        self.dataProvider = dataProvider
    }

    func cellViewDidLoad() {
        guard let category = dataProvider.object(at: indexPath) as? TrackerCategory
        else {return}
        categoryName = category.name
    }

    func setBinidings(_ bindings: CategoryViewModelBindings) {
        self.$categoryName.bind(action: bindings.categoryName)
    }
}
