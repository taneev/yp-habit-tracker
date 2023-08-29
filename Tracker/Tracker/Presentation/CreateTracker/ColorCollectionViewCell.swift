//
//  ColorCollectionViewCell.swift
//  Tracker
//
//  Created by Тимур Танеев on 23.08.2023.
//

import UIKit

final class ColorCollectionViewCell: UICollectionViewCell {

    static let reuseIdentifier = "color"

    var color: UIColor? {
        didSet {
            applyStyle(for: (color == nil ? false : isSelected))
        }
    }

    override var isSelected: Bool {
        didSet {
            applyStyle(for: (color == nil ? false : isSelected))
        }
    }

    private lazy var colorView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.layer.cornerRadius = 9.5
        contentView.layer.masksToBounds = true
        contentView.layer.borderWidth = 3
        contentView.layer.borderColor = color == nil ? UIColor.clear.cgColor : color!.cgColor
        contentView.addSubview(colorView)

        NSLayoutConstraint.activate([
            colorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 6),
            colorView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            colorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -6),
            colorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func applyStyle(for isSelectedState: Bool) {
        guard let color else {return}

        colorView.backgroundColor = color

        contentView.layer.borderColor = isSelectedState
                ? color.withAlphaComponent(0.3).cgColor
                : UIColor.clear.cgColor
    }
}

extension ColorCollectionViewCell: PropertyCellProtocol {
    func setCellSelected(_ isSelected: Bool) {
        self.isSelected = isSelected
    }

    func config(with colorName: String) {
        guard let ypColor = UIColor.YpColors(rawValue: colorName) else {return}
        self.color = ypColor.color()
    }
}
