//
//  StatisticView.swift
//  Tracker
//
//  Created by Тимур Танеев on 21.09.2023.
//

import UIKit

class StatisticView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    private lazy var statisticValueLabel = { createStatisticValueLabel() }()
    var statisticValue: Int? {
        didSet {
            statisticValueLabel.text = String(format: "%d", statisticValue ?? 0)
        }
    }

    private lazy var statisticNameLabel = { createStatisticNameLabel() }()
    var statisticName: String? {
        didSet {
            statisticNameLabel.text = statisticName
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .ypWhiteDay
        layer.cornerRadius = 16
        layer.masksToBounds = true
        layer.borderColor = UIColor.red.cgColor
        layer.borderWidth = 1
        translatesAutoresizingMaskIntoConstraints = false
        setupSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    convenience init(value: Int, name: String) {
        self.init(frame: .zero)
        self.statisticValue = value
        self.statisticName = name
    }

    private func setupSubviews() {
        addSubview(statisticValueLabel)
        addSubview(statisticNameLabel)
        NSLayoutConstraint.activate([
            statisticValueLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            statisticValueLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            statisticValueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),

            statisticNameLabel.topAnchor.constraint(equalTo: statisticValueLabel.bottomAnchor, constant: 7),
            statisticNameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            statisticNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            statisticNameLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }
}

private extension StatisticView {
    func createStatisticValueLabel() -> UILabel {
        let label = UILabel()
        label.text = String(format: "%d", self.statisticValue ?? 0)
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textColor = .ypBlackDay
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    func createStatisticNameLabel() -> UILabel {
        let label = UILabel()
        label.text = self.statisticName
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlackDay
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
}
