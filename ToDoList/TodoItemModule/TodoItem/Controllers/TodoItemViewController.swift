import UIKit
import TodoItem

class TodoItemViewController: UIViewController {

    private let scrollView = UIScrollView()

    private let textView: UITextView = {
        let textView = UITextView()
        textView.text = "Что надо сделать?"
        textView.textColor = Resources.Colors.tertiaryLabel
        textView.textContainerInset = UIEdgeInsets.init(top: 16, left: 11, bottom: 16, right: 16)
        textView.font = UIFont.body
        textView.layer.cornerRadius = 16
        textView.backgroundColor = Resources.Colors.secondaryBack
        textView.isScrollEnabled = false
        textView.autocorrectionType = .no
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()

    private let todoItemSettingsView = TodoItemSettingsView()
    private let deleteButtonView = DeleteButtonView()

    private var currentTodoItem: TodoItem?
    private let coreDataBase = FileCache()
    var dataCompletionHandler: ((TodoItem?) -> Void)?

    // MARK: - Initializators

    init(item: TodoItem?) {
        super.init(nibName: nil, bundle: nil)
        currentTodoItem = item
    }

    convenience init() {
        self.init(item: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setConstraints()
    }

// MARK: - Setup Layout

    private func setupViews() {
        view.backgroundColor = Resources.Colors.primaryBack

        setupNavBar()

        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(textView)
        scrollView.addSubview(todoItemSettingsView)
        scrollView.addSubview(deleteButtonView)

        textView.delegate = self

        todoItemSetup()

        hideKeyboardWhenTappedAround()
    }

    private func todoItemSetup() {
        if let currentTodoItem = currentTodoItem {
            let color: UIColor? = Resources.Colors.primaryLabel

            textView.text = currentTodoItem.text
            textView.textColor = color
            todoItemSettingsView.importanceSegmentControl.selectedSegmentIndex = currentTodoItem.importance.value

            if let dateDeadline = currentTodoItem.dateDeadline {
                todoItemSettingsView.dateDeadlineButton.setAttributedTitle(
                    NSAttributedString(
                        string: dateDeadline.toString(),
                        attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .footnote)]),
                    for: .normal
                )
                todoItemSettingsView.calendarView.date = dateDeadline
                todoItemSettingsView.deadLineSwtich.isOn = true
                todoItemSettingsView.dateDeadlineButton.isHidden = false
            } else {
                todoItemSettingsView.dateDeadlineButton.isHidden = true
            }

        } else {
            textView.text = Resources.Text.placeholderTitleForTextView
            textView.textColor = Resources.Colors.tertiaryLabel

            todoItemSettingsView.importanceSegmentControl.selectedSegmentIndex = 1

            todoItemSettingsView.dateDeadlineButton.isHidden = true
            deleteButtonView.deleteButton.isEnabled = false
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }

    func setupNavBar() {
        title = Resources.Text.todoItemNavBarTitle

        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.headline ?? .systemFont(ofSize: 17),
            NSAttributedString.Key.foregroundColor: Resources.Colors.primaryLabel
        ]

        addNavBarButtons()
    }

    private func addNavBarButtons() {
        let leftButton = UIButton(type: .system)
        leftButton.setTitleColor(Resources.Colors.blueColor, for: .normal)
        leftButton.setTitle(Resources.Text.cancelButtonTitle, for: .normal)
        leftButton.titleLabel?.font = UIFont.body
        leftButton.addTarget(self, action: #selector(dismissTapped(sender:)), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftButton)

        let rightButton = UIButton(type: .system)
        rightButton.setTitle(Resources.Text.saveButtonTitle, for: .normal)
        rightButton.setTitleColor(Resources.Colors.tertiaryLabel, for: .disabled)
        rightButton.titleLabel?.font = UIFont.headline
        rightButton.addTarget(self, action: #selector(saveTodoItem), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightButton)
    }

    func setUserInteractionDisabled() {
        deleteButtonView.deleteButton.isHidden = true
        textView.isUserInteractionEnabled = false
        todoItemSettingsView.importanceSegmentControl.isUserInteractionEnabled = false
        todoItemSettingsView.deadLineSwtich.isUserInteractionEnabled = false
    }

    // MARK: - Helper functions

    // MARK: - objc Methods

    @objc func dismissTapped(sender: UIBarButtonItem) {
        print(1)
        dismiss(animated: true)
    }

    @objc func saveTodoItem(sender: UIBarButtonItem) {
        var dateDeadline: Date?
        let importance = Importance(
            rawValue: todoItemSettingsView.importanceSegmentControl.selectedSegmentIndex
        ) ?? .basic

        let isDeadLineSwtichOn = todoItemSettingsView.deadLineSwtich.isOn
        if isDeadLineSwtichOn {
            dateDeadline = todoItemSettingsView.calendarView.date
        }

        if currentTodoItem != nil {
            currentTodoItem = TodoItem(
                id: currentTodoItem!.id,
                text: textView.text,
                importance: importance,
                dateDeadline: dateDeadline,
                isDone: currentTodoItem!.isDone,
                dateСreation: currentTodoItem!.dateСreation,
                dateChanging: Date()
             )
        } else {
            currentTodoItem = TodoItem(text: textView.text, importance: importance, dateDeadline: dateDeadline)
        }

        if let completion = dataCompletionHandler {
            completion(currentTodoItem!)
        }

        dismiss(animated: true)
        dismissKeyboard()
    }

    @objc func deleteTodoItem(sender: UIButton) {
        if let completion = dataCompletionHandler {
            completion(nil)
        }

        dismiss(animated: true)
    }

    @objc func switchChanged(sender: UISwitch) {
        if sender.isOn {
            let nextDayDate = Date.getNextDayDate()
            todoItemSettingsView.calendarView.date = nextDayDate
            todoItemSettingsView.dateDeadlineButton.setAttributedTitle(
                NSAttributedString(
                    string: nextDayDate.toString(),
                    attributes: [
                        NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .footnote)
                    ]
                ),
                for: .normal
            )
            calendarViewAppereanceAnimation(dateSelected: false)
        } else {
            calendarViewDisappereanceAnimation(dateSelected: false)
        }
    }

    @objc func datePickerSelected(sender: UIDatePicker) {
        todoItemSettingsView.dateDeadlineButton.setAttributedTitle(
            NSAttributedString(
                string: sender.date.toString(),
                attributes: [
                    NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .footnote)
                ]
            ),
            for: .normal
         )
    }

    @objc func dateDeadlineButtonTapped(sender: UIButton) {
        if !todoItemSettingsView.calendarView.isHidden {
            calendarViewDisappereanceAnimation(dateSelected: true)
        } else {
            calendarViewAppereanceAnimation(dateSelected: false)
        }
    }

    // MARK: - Animations
    private func calendarViewAppereanceAnimation(dateSelected: Bool) {
        self.todoItemSettingsView.dateDeadlineButton.transform = .identity

        UIView.animate(withDuration: 0.3) {
            self.todoItemSettingsView.calendarView.isHidden = false
            self.todoItemSettingsView.secondSeparator.isHidden = false
            self.todoItemSettingsView.dateDeadlineButton.isHidden = dateSelected ? true : false

            self.todoItemSettingsView.calendarView.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
            self.todoItemSettingsView.calendarView.alpha = 0.0
            self.todoItemSettingsView.dateDeadlineButton.alpha = dateSelected ? 0 : 1.0

            self.todoItemSettingsView.calendarView.transform = .identity
            self.todoItemSettingsView.calendarView.alpha = 1.0
            self.todoItemSettingsView.dateDeadlineButton.alpha = 1.0
        }
    }

    private func calendarViewDisappereanceAnimation(dateSelected: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.todoItemSettingsView.calendarView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            self.todoItemSettingsView.calendarView.alpha = 1.0

            self.todoItemSettingsView.dateDeadlineButton.alpha = 1.0
            self.todoItemSettingsView.dateDeadlineButton.transform = .identity

            self.todoItemSettingsView.calendarView.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
            self.todoItemSettingsView.calendarView.alpha = 0.0

            self.todoItemSettingsView.dateDeadlineButton.transform = dateSelected ?
                .identity : self.todoItemSettingsView.dateDeadlineButton.transform.translatedBy(x: 0, y: -10)
            self.todoItemSettingsView.dateDeadlineButton.alpha = dateSelected ? 1.0 : 0.0

            self.todoItemSettingsView.calendarView.isHidden = true
            self.todoItemSettingsView.secondSeparator.isHidden = true
            self.todoItemSettingsView.dateDeadlineButton.isHidden = dateSelected ? false : true
        }
    }
}

// MARK: - TextViewDelegate
extension TodoItemViewController: UITextViewDelegate {
    public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.text == Resources.Text.placeholderTitleForTextView {
            if textView.textColor == Resources.Colors.tertiaryLabel {
                textView.text = ""
                textView.textColor = Resources.Colors.primaryLabel
            }
        }
        return true
    }

    public func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if textView.text == "" {
            textView.text = Resources.Text.placeholderTitleForTextView
            textView.textColor = Resources.Colors.tertiaryLabel
        }
        return true
    }

    public func textViewDidChange(_ textView: UITextView) {
        if textView.text != "" && textView.textColor != Resources.Colors.tertiaryLabel {
            navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
}

// MARK: - Set Constaints

extension TodoItemViewController {
    private func setConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),

            textView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: Resources.Constants.edgeSize),
            textView.leadingAnchor.constraint(
                equalTo: scrollView.leadingAnchor,
                constant: Resources.Constants.edgeSize
            ),
            textView.trailingAnchor.constraint(
                equalTo: scrollView.trailingAnchor,
                constant: -Resources.Constants.edgeSize
            ),
            textView.widthAnchor.constraint(
                equalTo: scrollView.widthAnchor,
                constant: -2 * Resources.Constants.edgeSize
            ),
            textView.heightAnchor.constraint(greaterThanOrEqualToConstant: Resources.Constants.textViewHeight),

            todoItemSettingsView.topAnchor.constraint(
                equalTo: textView.bottomAnchor,
                constant: Resources.Constants.edgeSize
            ),
            todoItemSettingsView.leadingAnchor.constraint(
                equalTo: scrollView.leadingAnchor,
                constant: Resources.Constants.edgeSize
            ),
            todoItemSettingsView.trailingAnchor.constraint(
                equalTo: scrollView.trailingAnchor,
                constant: -Resources.Constants.edgeSize
            ),

            deleteButtonView.topAnchor.constraint(
                equalTo: todoItemSettingsView.bottomAnchor,
                constant: Resources.Constants.edgeSize
            ),
            deleteButtonView.leadingAnchor.constraint(
                equalTo: scrollView.leadingAnchor,
                constant: Resources.Constants.edgeSize
            ),
            deleteButtonView.trailingAnchor.constraint(
                equalTo: scrollView.trailingAnchor,
                constant: -Resources.Constants.edgeSize
            ),
            deleteButtonView.heightAnchor.constraint(equalToConstant: 56),
            deleteButtonView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16)
        ])
    }
}
