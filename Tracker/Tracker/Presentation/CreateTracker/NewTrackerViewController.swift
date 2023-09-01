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

    weak var saverDelegate: NewTrackerSaverDelegate?
    var dataProvider: DataProviderProtocol?
    var isRegular: Bool!

    private var trackerName: String? {
        didSet {
            checkIsAllParametersDidSetup()
        }
    }

    // временная категория для тестирования
    private lazy var category: TrackerCategory? = { initDefaultCategory() }() {
        didSet {
            checkIsAllParametersDidSetup()
        }
    }

    private var selectedEmoji: String? {
        didSet {
            checkIsAllParametersDidSetup()
        }
    }
    private var selectedColor: String? {
        didSet {
            checkIsAllParametersDidSetup()
        }
    }

    private var emojies = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡","🥶",
        "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"
    ]

    private var colors: [String] = UIColor.YpColors.allColorNames()

    private var schedule: [WeekDay]? {
        didSet {
            checkIsAllParametersDidSetup()
        }
    }

    private var isAllParametersDidSetup = false {
        didSet {
            doneButton.roundedButtonStyle = isAllParametersDidSetup ? .normal : .disabled
        }
    }

    private lazy var inputTrackerNameTxtField = { createInputTextField() }()
    private lazy var categorySetupButton = { createCategorySetupButton() }()
    private lazy var scheduleSetupButton = { createScheduleSetupButton() }()
    private lazy var emojiCollectionView = { createEmojiCollectionView() }()
    private lazy var colorCollectionView = { createColorCollectionView() }()
    private lazy var cancelButton = { createCancelButton() }()
    private lazy var doneButton = { createDoneButton() }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        displayData()
        // Для скрытия курсора с поля ввода при тапе вне поля ввода и вне клавиатуры
        let anyTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleAnyTap))
        anyTapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(anyTapGesture)
    }

    @objc private func handleAnyTap() {
        trackerName = inputTrackerNameTxtField.text
        _ = inputTrackerNameTxtField.resignFirstResponder()
    }

    @objc private func categoryButtonDidTap() {
        // TODO: next sprint
        print("Category did tap")
    }

    @objc private func scheduleButtonDidTap() {
        _ = inputTrackerNameTxtField.resignFirstResponder()
        trackerName = inputTrackerNameTxtField.text

        let scheduleViewController = ScheduleViewController()
        scheduleViewController.schedule = schedule
        scheduleViewController.saveScheduleDelegate = self
        present(scheduleViewController, animated: true)
    }

    @objc private func doneButtonDidTap() {
        guard let selectedEmoji else {
            assertionFailure("Не удалось определить emoji карточки трекера при сохранении")
            return
        }
        guard let selectedColor,
              let color = UIColor.YpColors(rawValue: selectedColor) else {
            assertionFailure("Не удалось определить цвет карточки трекера при сохранении")
            return
        }
        guard let category else {
            assertionFailure("Не удалось определить категорию для сохранения трекера")
            return
        }

        if inputTrackerNameTxtField.isFirstResponder {
            if inputTrackerNameTxtField.resignFirstResponder() {
                trackerName = inputTrackerNameTxtField.text
            }
            else {
                assertionFailure("Не удалось завершить ввода названия трекера при сохранении")
                return
            }
        }

        guard let trackerName else {
            assertionFailure("Не удалось определить название трекера при сохранении")
            return
        }

        if trackerName.isEmpty {
            isAllParametersDidSetup = false
            return
        }

        let newTracker = Tracker(
                name: trackerName,
                isRegular: isRegular,
                emoji: selectedEmoji,
                color: color,
                schedule: schedule,
                isCompleted: false,
                completedCounter: 0
        )
        saverDelegate?.save(tracker: newTracker, in: category)
    }

    @objc private func cancelButtonDidTap() {
        dismiss(animated: true)
    }

    private func initDefaultCategory() -> TrackerCategory? {
        // NOTE: временный вариант инициализации категории первой попавшейся, пока нет
        // функциональности создания категорий
        return dataProvider?.getDefaultCategory()
    }

    private func checkIsAllParametersDidSetup() {
        isAllParametersDidSetup = trackerName?.isEmpty == false
            && (!isRegular || schedule?.isEmpty == false)
            && (category?.name.isEmpty == false)
            && (selectedEmoji?.isEmpty == false)
            && (UIColor.YpColors(rawValue: selectedColor ?? "") != nil)
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

extension NewTrackerViewController: ScheduleSaverDelegate {
    func scheduleDidSetup(with newSchedule: [WeekDay]) {
        self.schedule = newSchedule
        displaySchedule()
        dismiss(animated: true)
    }
}

extension NewTrackerViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 38
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

extension NewTrackerViewController: PropertyCollectionViewDelegate {
    func didSelectItem(at indexPath: IndexPath, for propertyType: TrackerProperty) {
        switch propertyType {
        case .emoji:
            selectedEmoji = emojies[indexPath.row]
        case .color:
            selectedColor = colors[indexPath.row]
        }
    }
}

extension NewTrackerViewController: PropertyCollectionDataSource {
    func getItem(at indexPath: IndexPath, for propertyType: TrackerProperty) -> String {
        switch propertyType {
        case .emoji:
            return emojies[indexPath.row]
        case .color:
            return colors[indexPath.row]
        }
    }

    func numberOfItems(in section: Int, for propertyType: TrackerProperty) -> Int {
        switch propertyType {
        case .emoji:
            return emojies.count
        case .color:
            return colors.count
        }
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

    func createEmojiCollectionView() -> UIView {

        let view = TrackerPropertyCollectionView(
                        title: "Emoji",
                        propertyType: .emoji,
                        delegate: self,
                        dataSource: self
        )

        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    func createColorCollectionView() -> UIView {

        let view = TrackerPropertyCollectionView(
                        title: "Цвет",
                        propertyType: .color,
                        delegate: self,
                        dataSource: self
        )

        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    func createDoneButton() -> RoundedButton {
        let button = RoundedButton(title: "Создать")
        button.roundedButtonStyle = isAllParametersDidSetup ? .normal : .disabled
        button.addTarget(self, action: #selector(doneButtonDidTap), for: .touchUpInside)
        return button
    }

    func createCancelButton() -> RoundedButton {
        let button = RoundedButton(title: "Отменить", style: .cancel)
        button.addTarget(self, action: #selector(cancelButtonDidTap), for: .touchUpInside)
        return button
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

        let buttons = UIStackView(arrangedSubviews: [cancelButton, doneButton])
        buttons.axis = .horizontal
        buttons.spacing = 8
        buttons.distribution = .fillEqually
        buttons.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(buttons)

        NSLayoutConstraint.activate([

            inputTrackerNameTxtField.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
            inputTrackerNameTxtField.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            inputTrackerNameTxtField.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32),

            actionButtonsView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            actionButtonsView.topAnchor.constraint(equalTo: inputTrackerNameTxtField.bottomAnchor, constant: 24),
            actionButtonsView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32),

            emojiCollectionView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            emojiCollectionView.topAnchor.constraint(equalTo: actionButtonsView.bottomAnchor, constant: 32),
            emojiCollectionView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),

            colorCollectionView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            colorCollectionView.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 16),
            colorCollectionView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),

            buttons.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 20),
            buttons.topAnchor.constraint(equalTo: colorCollectionView.bottomAnchor, constant: 16),
            buttons.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -20),
            buttons.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40),
            buttons.heightAnchor.constraint(equalToConstant: 60),
            buttons.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
        ])

        return scrollView
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

