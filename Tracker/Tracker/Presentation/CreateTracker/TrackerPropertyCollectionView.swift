//
//  TrackerPropertyCollectionView.swift
//  Tracker
//
//  Created by Тимур Танеев on 23.08.2023.
//

import UIKit

protocol PropertyCollectionViewDelegate: AnyObject {
    func didSelectItem(at indexPath: IndexPath, for propertyType: TrackerProperty)
}

protocol PropertyCollectionDataSource: AnyObject {
    func numberOfItems(in section: Int, for propertyType: TrackerProperty) -> Int
    func getItem(at indexPath: IndexPath, for propertyType: TrackerProperty) -> String
}

enum TrackerProperty: String {
    case emoji
    case color

    func reuseIdentifier() -> String {
        switch self {
        case .emoji:
            return EmojiCollectionViewCell.reuseIdentifier
        case .color:
            return ColorCollectionViewCell.reuseIdentifier
        }
    }
}

final class TrackerPropertyCollectionView: UIView {

    private var propertyType: TrackerProperty?
    private weak var delegate: PropertyCollectionViewDelegate?
    private weak var dataSource: PropertyCollectionDataSource?
    private var title: String?
    private lazy var titleView = { createTitleView() }()
    private lazy var collectionView = { createCollectionView() }()

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    convenience init(
            title: String,
            propertyType: TrackerProperty,
            delegate: PropertyCollectionViewDelegate,
            dataSource: PropertyCollectionDataSource
    ) {
        self.init(frame: .zero)
        
        self.title = title
        self.propertyType = propertyType
        self.delegate = delegate
        self.dataSource = dataSource

        setupSubviews()
    }
}

extension TrackerPropertyCollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let propertyType else { return }
        collectionView.cellForItem(at: indexPath)?.isSelected = true
        delegate?.didSelectItem(at: indexPath,  for: propertyType)
    }
}

extension TrackerPropertyCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: 52, height: 52)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 5.0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 0.0
    }
}

// MARK: DataSource
extension TrackerPropertyCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let propertyType,
              let dataSource else {return 0}

        return dataSource.numberOfItems(in: section, for: propertyType)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let propertyType,
              let property = dataSource?.getItem(at: indexPath, for: propertyType)
        else {return UICollectionViewCell() }

        let cell = collectionView.dequeueReusableCell(
                      withReuseIdentifier: propertyType.reuseIdentifier(),
                      for: indexPath
        )
        (cell as? PropertyCellProtocol)?.config(with: property)
        return cell
    }
}

// MARK: Layout
private extension TrackerPropertyCollectionView {

    func setupSubviews() {
        addSubview(titleView)
        addSubview(collectionView)

        NSLayoutConstraint.activate([
            titleView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
            titleView.topAnchor.constraint(equalTo: topAnchor),

            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: titleView.bottomAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 204),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    func createTitleView() -> UILabel {

        let title = UILabel()
        title.text = self.title
        title.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        title.textColor = .ypBlackDay
        title.textAlignment = .left
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }

    func createCollectionView() -> UIView {

        let layout = UICollectionViewFlowLayout()
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.contentInset = UIEdgeInsets(top: 24, left: 18, bottom: 24, right: 18)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.delegate = self
        collection.dataSource = self
        collection.register(
                EmojiCollectionViewCell.self,
                forCellWithReuseIdentifier: EmojiCollectionViewCell.reuseIdentifier
        )
        collection.register(
                ColorCollectionViewCell.self,
                forCellWithReuseIdentifier: ColorCollectionViewCell.reuseIdentifier
        )

        return collection
    }
}
