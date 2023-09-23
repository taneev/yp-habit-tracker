//
//  DataStoreFetchedControllerProtocol.swift
//  Tracker
//
//  Created by Тимур Танеев on 07.09.2023.
//

import Foundation

protocol DataStoreFetchedControllerProtocol {
    associatedtype DataStoreType
    var numberOfObjects: Int? { get }
    var numberOfSections: Int? { get }
    func numberOfRows(in section: Int) -> Int?
    func object(at indexPath: IndexPath) -> DataStoreType?
    func fetchData()
}
