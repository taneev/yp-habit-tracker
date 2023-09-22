//
//  StatisticView.swift
//  Tracker
//
//  Created by Тимур Танеев on 21.09.2023.
//

import UIKit

final class StatisticView: UIView {
    private let gradientLayerName = "statisticViewGradientBorder"
    private let cornerRadius = CGFloat(16)
    private let borderWith = CGFloat(1)

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

    override func layoutSubviews() {
        super.layoutSubviews()
        // Добавляем градиентный слой тут, т.к. градиенту нужно, чтобы frame вьюшки
        // уже был рассчитан автолейаутом
        addGradientSublayer()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .ypWhiteDay
        layer.cornerRadius = 16
        layer.masksToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
        setupSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func removeGradientLayer() {
        layer.sublayers?.forEach{
            if $0.name == gradientLayerName {
                $0.removeFromSuperlayer()
            }
        }
    }

    private func addGradientSublayer() {
        removeGradientLayer()
        let gradientLayer = createGradientSublayer()
        layer.addSublayer(gradientLayer)
        gradientLayer.zPosition = 0
    }

    private func createGradientSublayer() -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.name = gradientLayerName
        gradient.frame = bounds
        gradient.colors = [
            UIColor.ypGradientColor3.cgColor,
            UIColor.ypGradientColor2.cgColor,
            UIColor.ypGradientColor1.cgColor
        ]
        gradient.cornerRadius = cornerRadius
        gradient.masksToBounds = true
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)

        let mask = CAShapeLayer()
        mask.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        mask.fillColor = UIColor.clear.cgColor
        mask.strokeColor = UIColor.white.cgColor
        mask.lineWidth = borderWith
        gradient.mask = mask

        return gradient
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
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textColor = .ypBlackDay
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    func createStatisticNameLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlackDay
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
}
