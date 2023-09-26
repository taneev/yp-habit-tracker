//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Тимур Танеев on 17.09.2023.
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {

    func testStartViewController() throws {
        let startVC = StartViewController()
        // .light mode
        assertSnapshots(of: startVC, as: [.image(on: .iPhone13ProMax, traits: UITraitCollection(userInterfaceStyle: .light))])
        assertSnapshots(of: startVC, as: [.image(on: .iPhone13, traits: UITraitCollection(userInterfaceStyle: .light))])

        // .dark mode
        assertSnapshots(of: startVC, as: [.image(on: .iPhone13ProMax, traits: UITraitCollection(userInterfaceStyle: .dark))])
        assertSnapshots(of: startVC, as: [.image(on: .iPhone13, traits: UITraitCollection(userInterfaceStyle: .dark))])
    }
}
