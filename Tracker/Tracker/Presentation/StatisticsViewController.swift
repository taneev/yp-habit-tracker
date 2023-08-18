//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Тимур Танеев on 12.08.2023.
//

import UIKit

final class StatisticsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .ypWhiteDay
        
        let label = UILabel()
        label.text = "Продолжение следует..."
        label.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
