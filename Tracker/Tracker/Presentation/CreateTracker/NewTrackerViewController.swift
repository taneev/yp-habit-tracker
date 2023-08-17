//
//  NewTrackerViewController.swift
//  Tracker
//
//  Created by Тимур Танеев on 12.08.2023.
//

import UIKit

protocol ScheduleSaverDelegate: AnyObject {
    func scheduleDidSetup(with newSchedule: [WeekDay])
}

final class NewTrackerViewController: UIViewController {

    var isRegular: Bool!
    var newTracker: Tracker?
    var trackerName: String?
    // временная категория для тестирования
    var category: TrackerCategory? = TrackerCategory(categoryID: UUID(uuidString: "8BFB9644-098E-46CF-9C47-BF3740038E1C")!,
                                                     name: "Занятия спортом",
                                                     activeTrackers: nil)
    var schedule: [WeekDay]?

    private lazy var inputTrackerNameTxtField = { createInputTextField() }()
    private lazy var categorySetupButton = { createCategorySetupButton() }()
    private lazy var scheduleSetupButton = { createScheduleSetupButton() }()
    private lazy var emojiCollectionView = { createCollectionView() }()
    private lazy var colorCollectionView = { createCollectionView() }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        displayData()
    }

    @objc private func categoryButtonDidTap() {
        // TODO: next sprint
        print("Category did tap")
    }

    @objc private func scheduleButtonDidTap() {
        let scheduleViewController = ScheduleViewController()
        scheduleViewController.schedule = schedule
        scheduleViewController.saveScheduleDelegate = self
        present(scheduleViewController, animated: true)
    }

    private func displaySchedule() {
        scheduleSetupButton.detailedText = schedule == nil ? "" : WeekDay.getDescription(for: schedule!)
    }

    private func displayCategory() {
        categorySetupButton.detailedText = category?.name ?? ""
    }

    private func displayData() {
        displaySchedule()
        displayCategory()
    }
}

// MARK: Layout
private extension NewTrackerViewController {

    func createTitleLabel() -> TitleLabel {
        let titleText = isRegular ? "Новая привычка" : "Новое нерегулярное событие"
        let title = TitleLabel(title: titleText)
        return title
    }

    func createInputTextField() -> TrackerNameInputView {
        let textField = TrackerNameInputView(delegate: self, placeholder: "Введите название трекера")
        return textField
    }

    func createCategorySetupButton() -> StackRoundedView {
        let categoryButton = StackRoundedButton(target: self, action: #selector(categoryButtonDidTap))
        categoryButton.roundedCornerStyle = isRegular ? .topOnly : .topAndBottom
        categoryButton.text = "Категория"
        return categoryButton
    }

    func createScheduleSetupButton() -> StackRoundedView {
        let scheduleButton = StackRoundedButton(target: self, action: #selector(scheduleButtonDidTap))
        scheduleButton.roundedCornerStyle = .bottomOnly
        scheduleButton.text = "Расписание"
        return scheduleButton
    }

    func createActionButtonsView() -> UIView {

        let stack = UIStackView()
        stack.addArrangedSubview(categorySetupButton)
        if isRegular {
            stack.addArrangedSubview(scheduleSetupButton)
        }
        stack.axis = .vertical
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false

        return stack
    }

    func createScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.contentInset = UIEdgeInsets(top: 24, left: 0, bottom: 16, right: 0)
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        scrollView.addSubview(inputTrackerNameTxtField)

        let actionButtonsView = createActionButtonsView()
        scrollView.addSubview(actionButtonsView)

        scrollView.addSubview(emojiCollectionView)
        scrollView.addSubview(colorCollectionView)

        NSLayoutConstraint.activate([

            inputTrackerNameTxtField.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
            inputTrackerNameTxtField.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            inputTrackerNameTxtField.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32),

            actionButtonsView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            actionButtonsView.topAnchor.constraint(equalTo: inputTrackerNameTxtField.bottomAnchor, constant: 24),
            actionButtonsView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32),
        ])

        return scrollView
    }

    func createCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.translatesAutoresizingMaskIntoConstraints = true
        return collection
    }

    func setupSubviews() {
        view.backgroundColor = .ypWhiteDay

        let title = createTitleLabel()
        view.addSubview(title)

        let scrollView = createScrollView()
        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            title.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            title.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),

            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.topAnchor.constraint(equalTo: title.bottomAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

extension NewTrackerViewController: ScheduleSaverDelegate {
    func scheduleDidSetup(with newSchedule: [WeekDay]) {
        self.schedule = newSchedule
        displaySchedule()
    }
}

extension NewTrackerViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 5
        let currentString = textField.text as? NSString
        let newString = currentString?.replacingCharacters(in: range, with: string) ?? ""
        if newString.count > maxLength {
            inputTrackerNameTxtField.isMaxLengthHintHidden = false
        }
        else if !inputTrackerNameTxtField.isMaxLengthHintHidden {
            inputTrackerNameTxtField.isMaxLengthHintHidden = true
        }
        return newString.count <= maxLength
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
        trackerName = textField.text
    }
}
