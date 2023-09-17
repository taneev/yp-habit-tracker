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
        assertSnapshots(of: startVC, as: [.image(on: .iPhone13ProMax)])
        assertSnapshots(of: startVC, as: [.recursiveDescription(on: .iPhone13ProMax)])

        assertSnapshots(of: startVC, as: [.image(on: .iPhoneSe)])
        assertSnapshots(of: startVC, as: [.recursiveDescription(on: .iPhoneSe)])
    }
}
