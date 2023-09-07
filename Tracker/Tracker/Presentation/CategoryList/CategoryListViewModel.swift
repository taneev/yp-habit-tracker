//
//  CategoryListViewModel.swift
//  Tracker
//
//  Created by Тимур Танеев on 06.09.2023.
//

import Foundation

final class CategoryListViewModel {

    @Observable
    private var numberOfCategories: Int?
    var dataProvider: any CategoryDataProviderProtocol

    init(dataProvider: any CategoryDataProviderProtocol) {
        self.dataProvider = dataProvider
    }
}
