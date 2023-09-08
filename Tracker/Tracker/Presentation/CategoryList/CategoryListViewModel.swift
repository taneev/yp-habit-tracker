//
//  CategoryListViewModel.swift
//  Tracker
//
//  Created by Тимур Танеев on 06.09.2023.
//

import Foundation

struct CategoryListViewModelBindings {
    let numberOfCategories: (Int?) -> Void
    let isPlaceHolderHidden: (Bool?) -> Void
}

protocol CategoryListViewModelProtocol {
    var dataProvider: any CategoryDataProviderProtocol {get}
    func viewDidLoad()
    func setBindings(_ bindings: CategoryListViewModelBindings)
}

// MARK: CategoryListViewModel

final class CategoryListViewModel: CategoryListViewModelProtocol {

    @Observable
    private var numberOfCategories: Int?

    @Observable
    private var isPlaceHolderHidden: Bool?

    var dataProvider: any CategoryDataProviderProtocol

    init(dataProvider: any CategoryDataProviderProtocol) {
        self.dataProvider = dataProvider
    }

    func viewDidLoad() {
        dataProvider.loadData()
        numberOfCategories = dataProvider.numberOfObjects
        isPlaceHolderHidden = (numberOfCategories ?? 0) > 0
    }

    func setBindings(_ bindings: CategoryListViewModelBindings) {
        self.$numberOfCategories.bind(action: bindings.numberOfCategories)
        self.$isPlaceHolderHidden.bind(action: bindings.isPlaceHolderHidden)
    }
}
