//
//  DataProviderProtocols.swift
//  Tracker
//
//  Created by Тимур Танеев on 07.09.2023.
//

import Foundation

protocol DataProviderForDataSource {
    associatedtype DataSourceType
    var numberOfSections: Int { get }
    func numberOfRows(in section: Int) -> Int
    func object(at indexPath: IndexPath) -> DataSourceType?
}

protocol DataProviderForCollectionLayoutDelegate: AnyObject {
    func didUpdate(_ updatedIndexes: UpdatedIndexes)
}

protocol DataProviderForTableViewDelegate: AnyObject {
    func didUpdate(_ updatedIndexes: UpdatedIndexes)
}

struct UpdatedIndexes {
    let insertedSections: IndexSet
    let insertedIndexes: [IndexPath]
    let deletedSections: IndexSet
    let deletedIndexes: [IndexPath]
}
