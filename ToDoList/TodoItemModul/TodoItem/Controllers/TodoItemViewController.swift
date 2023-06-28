import UIKit

final class TodoItemViewController: UIViewController {
    // MARK: - Properties

    private lazy var textView = TextView()
    private lazy var scrollView = UIScrollView()

    // StackView properties
    private lazy var settingsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = .secondaryBack
        stackView.layer.cornerRadius = cornerRadius
        stackView.axis = .vertical
        stackView.spacing = settingsStackViewSpacing
        stackView.distribution = .fillProportionally
        stackView.layoutMargins = UIEdgeInsets(top: verticalStackEdgeSize, left: edgeSize, bottom: verticalStackEdgeSize, right: edgeSize)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()
    
    private lazy var deadlineVerticalSubStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.alignment = .leading
        return stackView
    }()
    
    private lazy var importanceStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = edgeSize
        stackView.alignment = .center
        return stackView
    }()
    
    private lazy var deadlineStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = edgeSize
        stackView.alignment = .center
        return stackView
    }()
    
    // Label properties
    private lazy var importanceLabel: BodyLabelView = {
        let label = BodyLabelView()
        label.text = importanceTitle
        return label
    }()
    
    private lazy var deadlineLabel: BodyLabelView = {
        let label = BodyLabelView()
        label.text = doBeforeTitle
        return label
    }()
    
    // SegmentControl properties
    private lazy var importanceSegmentControl: UISegmentedControl = {
        let segmentControl = UISegmentedControl(items: items)
        segmentControl.selectedSegmentTintColor = .elevatedBack
        segmentControl.backgroundColor = .overlaySupport
        return segmentControl
    }()

    // Switch properties
    private lazy var dateDeadLineSwtich: UISwitch = {
        let switcher = UISwitch()
        switcher.onTintColor = .greenColor
        switcher.layer.cornerRadius = cornerRadius
        switcher.layer.masksToBounds = true
        switcher.backgroundColor = .overlaySupport
        switcher.addTarget(nil, action: #selector(switchChanged), for: .valueChanged)
        return switcher
    }()
    
    // Button properties
    private lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.setTitle(deleteTitle, for: .normal)
        button.setTitleColor(.redColor, for: .normal)
        button.setTitleColor(.tertiaryLabel, for: .disabled)
        button.layer.cornerRadius = cornerRadius
        button.backgroundColor = .secondaryBack
        button.addTarget(nil, action: #selector(deleteTodoItem), for: .touchUpInside)
        return button
    }()
    
    private lazy var dateDeadlineButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.blueColor, for: .normal)
        button.contentHorizontalAlignment = .left
        button.addTarget(nil, action: #selector(dateDeadlineButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // Calendar properties
    private lazy var calendarView: UIDatePicker = {
        let datePicker = UIDatePicker()

        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.calendar.firstWeekday = 2
        datePicker.minimumDate = Date()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline

        datePicker.addTarget(nil, action: #selector(datePickerSelected), for: .valueChanged)
        datePicker.isHidden = true
        return datePicker
    }()
    
    // SeparatorViews properties
    private lazy var separator = SeparatorLineView()
    private lazy var secondSeparator = SeparatorLineView()

    private let fileCache = FileCache()
    private var currentTodoItem: TodoItem? = nil
    
    // MARK: - Initializators

    init(item: TodoItem?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    convenience init() {
        self.init(item: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Override methods

    override func viewDidLoad() {
        super.viewDidLoad()
        makeLoad()
        setUpView()
    }
}

// MARK: - Extensions

extension TodoItemViewController {
    // MARK: - Load saved items

    // Delete when we will make rootViewController
    private func makeLoad() {
        do {
            try fileCache.loadFromJSON(file: mainDataBaseFileName)
        } catch {
            print("Ошибочка при загрузке данных")
        }
        
        if !fileCache.todoItems.isEmpty {
            currentTodoItem = fileCache.todoItems.first!.value
        }
    }
    
    // MARK: - Settings views

    private func setUpView() {
        // Root view setup
        view.backgroundColor = .primaryBack
        
        // Navigation setup
        title = todoItemTitle
        navigationItem.leftBarButtonItem = .init(title: cancelTitle, style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItem = .init(title: saveTitle, style: .plain, target: self, action: #selector(saveTodoItem))
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.tertiaryLabel!], for: .disabled)
        
        // TextView setup
        textView.delegate = self
        
        // Separator setup
        secondSeparator.isHidden = true
        secondSeparator.isHidden = true
        
        // ColorPickerView setup
        
        
    
        calendarView.isHidden = true
        
        // TodoItem setup
        if let currentTodoItem = currentTodoItem {
           
            textView.text = currentTodoItem.text
            textView.textColor = .primaryLabel
            importanceSegmentControl.selectedSegmentIndex = indexByImportance(currentTodoItem.importance)
            
            if let dateDeadline = currentTodoItem.dateDeadline {
                dateDeadlineButton.setAttributedTitle(NSAttributedString(string: dateDeadline.toString(), attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .footnote)]), for: .normal)
                calendarView.date = dateDeadline
                dateDeadLineSwtich.isOn = true
                dateDeadlineButton.isHidden = false
            } else {
                dateDeadlineButton.isHidden = true
            }
    
        } else {
            textView.text = placeholderTitleForTextView
            textView.textColor = .secondaryLabel
            
            importanceSegmentControl.selectedSegmentIndex = 1
        
            dateDeadlineButton.isHidden = true
            deleteButton.isEnabled = false
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
                
        addSubViews()
        setupLayout()
    }
    
    // MARK: - Obj-c methods
    
    @objc func saveTodoItem(sender: UIBarButtonItem) {
        var dateDeadline: Date?
        let importance = importanceByIndex(importanceSegmentControl.selectedSegmentIndex)
        if dateDeadLineSwtich.isOn == true {
            dateDeadline = calendarView.date
        }
        
        if currentTodoItem != nil {
            currentTodoItem = TodoItem(id: currentTodoItem!.id, text: textView.text, importance: importance, dateDeadline: dateDeadline, isDone: currentTodoItem!.isDone, dateСreation: currentTodoItem!.dateСreation, dateChanging: Date())
        } else {
            currentTodoItem = TodoItem(text: textView.text, importance: importance, dateDeadline: dateDeadline)
        }
        
        fileCache.add(currentTodoItem!)
        do {
            try fileCache.saveToJSON(file: mainDataBaseFileName)
        } catch FileCacheErrors.DirectoryNotFound {
            print(FileCacheErrors.DirectoryNotFound.rawValue)
        } catch FileCacheErrors.JSONConvertationError {
            print(FileCacheErrors.JSONConvertationError.rawValue)
        } catch FileCacheErrors.PathToFileNotFound {
            print(FileCacheErrors.PathToFileNotFound.rawValue)
        } catch FileCacheErrors.WriteFileError {
            print(FileCacheErrors.WriteFileError.rawValue)
        } catch {
            print("Другая ошибка при сохранении файла")
        }
        
        deleteButton.isEnabled = true
        dismissKeyboard()
    }
    
    @objc func deleteTodoItem(sender: UIButton) {
        
        
        fileCache.remove(with: currentTodoItem!.id)
        do {
            try fileCache.saveToJSON(file: mainDataBaseFileName)
        } catch FileCacheErrors.DirectoryNotFound {
            print(FileCacheErrors.DirectoryNotFound.rawValue)
        } catch FileCacheErrors.JSONConvertationError {
            print(FileCacheErrors.JSONConvertationError.rawValue)
        } catch FileCacheErrors.PathToFileNotFound {
            print(FileCacheErrors.PathToFileNotFound.rawValue)
        } catch FileCacheErrors.WriteFileError {
            print(FileCacheErrors.WriteFileError.rawValue)
        } catch {
            print("Другая ошибка при сохранении файла, когда элемент удален")
        }
    
        currentTodoItem = nil
        
        textView.text = placeholderTitleForTextView
        textView.textColor = .secondaryLabel
        importanceSegmentControl.selectedSegmentIndex = 1
        
        dateDeadlineButton.isHidden = true
        calendarView.isHidden = true
        secondSeparator.isHidden = true
        secondSeparator.isHidden = true
        dateDeadLineSwtich.isOn = false
        deleteButton.isEnabled = false
        navigationItem.rightBarButtonItem?.isEnabled = false
        
    }
        
    @objc func switchChanged(sender: UISwitch) {
        if sender.isOn {
            let nextDayDate = Date.getNextDayDate()
            calendarView.date = nextDayDate
            dateDeadlineButton.setAttributedTitle(NSAttributedString(string: nextDayDate.toString(), attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .footnote)]), for: .normal)

            calendarViewAppereanceAnimation(dateSelected: false)
        } else {
            calendarViewDisappereanceAnimation(dateSelected: false)
        }
    }
    
    @objc func datePickerSelected(sender: UIDatePicker) {
        dateDeadlineButton.setAttributedTitle(NSAttributedString(string: sender.date.toString(), attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .footnote)]), for: .normal)
    }
    
    @objc func dateDeadlineButtonTapped(sender: UIButton) {
        if !calendarView.isHidden {
            calendarViewDisappereanceAnimation(dateSelected: true)
        } else {
            calendarViewAppereanceAnimation(dateSelected: false)
        }
    }

    // MARK: - Add subviews

    private func addSubViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(textView)
        scrollView.addSubview(settingsStackView)
        scrollView.addSubview(deleteButton)
        
        settingsStackView.addArrangedSubview(importanceStackView)
        settingsStackView.addArrangedSubview(separator)
        settingsStackView.addArrangedSubview(secondSeparator)
        settingsStackView.addArrangedSubview(deadlineStackView)
        settingsStackView.addArrangedSubview(secondSeparator)
        settingsStackView.addArrangedSubview(calendarView)
        
        importanceStackView.addArrangedSubview(importanceLabel)
        importanceStackView.addArrangedSubview(importanceSegmentControl)
        
        deadlineStackView.addArrangedSubview(deadlineVerticalSubStack)
        deadlineStackView.addArrangedSubview(dateDeadLineSwtich)
        
        deadlineVerticalSubStack.addArrangedSubview(deadlineLabel)
        deadlineVerticalSubStack.addArrangedSubview(dateDeadlineButton)


        hideKeyboardWhenTappedAround()
    }
    
    // MARK: - Setup layout

    private func setupLayout() {
        // ScrollView anchors
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor).isActive = true
        scrollView.contentSize = view.bounds.size
        
        // TextViewAnchors
        textView.translatesAutoresizingMaskIntoConstraints = false

        textView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: edgeSize).isActive = true
        textView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -edgeSize).isActive = true
        textView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: edgeSize).isActive = true
        textView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -2 * edgeSize).isActive = true
        textView.heightAnchor.constraint(greaterThanOrEqualToConstant: textViewHeight).isActive = true
        
        // SettingsStack anchors
        settingsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        settingsStackView.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: edgeSize).isActive = true
        settingsStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: edgeSize).isActive = true
        settingsStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -edgeSize).isActive = true
        
        // Separators anchors
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.heightAnchor.constraint(equalToConstant: separatorHeight).isActive = true
        
        secondSeparator.translatesAutoresizingMaskIntoConstraints = false
        secondSeparator.heightAnchor.constraint(equalToConstant: separatorHeight).isActive = true
        
        secondSeparator.translatesAutoresizingMaskIntoConstraints = false
        secondSeparator.heightAnchor.constraint(equalToConstant: separatorHeight).isActive = true
                
        // SegmentControl anchors
        importanceSegmentControl.translatesAutoresizingMaskIntoConstraints = false
        
        importanceSegmentControl.widthAnchor.constraint(equalToConstant: importanceSegmentControlWidth).isActive = true
        importanceSegmentControl.heightAnchor.constraint(equalToConstant: importanceSegmentControlHeight).isActive = true
        
        // Deletebutton anchors
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        
        deleteButton.heightAnchor.constraint(equalToConstant: deleteButtonHeight).isActive = true
        deleteButton.topAnchor.constraint(equalTo: settingsStackView.bottomAnchor, constant: edgeSize).isActive = true
        deleteButton.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: edgeSize).isActive = true
        deleteButton.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -edgeSize).isActive = true
        deleteButton.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        
        // DateDeadlineButton anchors
        dateDeadlineButton.translatesAutoresizingMaskIntoConstraints = false
        dateDeadlineButton.heightAnchor.constraint(equalToConstant: dateDeadlineButtonHeight).isActive = true
    
    }
    
    // MARK: - Helper functions

    private func indexByImportance(_ importance: Importance) -> Int {
        switch importance {
            case .unimportant:
                return 0
            case .normal:
                return 1
            case .important:
                return 2
        }
    }
    
    private func importanceByIndex(_ index: Int) -> Importance {
        switch index {
            case 0:
                return .unimportant
            case 1:
                return .normal
            case 2:
                return .important
            default:
                return .normal
        }
    }
    
    // MARK: - Animations

    private func calendarViewAppereanceAnimation(dateSelected: Bool) {
        dateDeadlineButton.transform = .identity
        
        UIView.animate(withDuration: 0.3) {
            self.calendarView.isHidden = false
            self.secondSeparator.isHidden = false
            self.dateDeadlineButton.isHidden = dateSelected ? true : false
                    
            self.calendarView.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
            self.calendarView.alpha = 0.0
            self.dateDeadlineButton.alpha = dateSelected ? 0 : 1.0
            
            self.calendarView.transform = .identity
            self.calendarView.alpha = 1.0
            self.dateDeadlineButton.alpha = 1.0
        }
    }
        
    private func calendarViewDisappereanceAnimation(dateSelected: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.calendarView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            self.calendarView.alpha = 1.0
            
            self.dateDeadlineButton.alpha = 1.0
            self.dateDeadlineButton.transform = .identity
                
            self.calendarView.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
            self.calendarView.alpha = 0.0
            
            self.dateDeadlineButton.transform = dateSelected ? .identity : self.dateDeadlineButton.transform.translatedBy(x: 0, y: -10)
            self.dateDeadlineButton.alpha = dateSelected ? 1.0 : 0.0
            
            self.calendarView.isHidden = true
            self.secondSeparator.isHidden = true
            self.dateDeadlineButton.isHidden = dateSelected ? false : true
        }
    }
}

extension TodoItemViewController: UITextViewDelegate {
    public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.text == placeholderTitleForTextView {
            textView.text = ""
            textView.textColor = .primaryLabel
        }
        return true
    }
    
    public func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if textView.text == "" {
            textView.text = placeholderTitleForTextView
            textView.textColor = .tertiaryLabel
        }
        return true
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        if textView.text != "" && textView.text != placeholderTitleForTextView {
            navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
}



private let selectedColorButtonSizes: CGFloat = 36
private let importanceSegmentControlHeight: CGFloat = 36
private let separatorHeight: CGFloat = 1
private let textViewHeight: CGFloat = 120
private let dateDeadlineButtonHeight: CGFloat = 18
private let deleteButtonHeight: CGFloat = 56

private let importanceSegmentControlWidth: CGFloat = 156

private let cornerRadius: CGFloat = 16
private let edgeSize: CGFloat = 16
private let verticalStackEdgeSize: CGFloat = 12.5
private let settingsStackViewSpacing: CGFloat = 11

private var placeholderTitleForTextView = "Что надо сделать?"

private let todoItemTitle = "Дело"

private let deleteTitle = "Удалить"
private let cancelTitle = "Отменить"
private let saveTitle = "Сохранить"

private let doBeforeTitle = "Cделать до"
private let importanceTitle = "Важность"
private let colorTextTitle = "Цвет текста"

private let mainDataBaseFileName = "2"

private var items: [Any] = [UIImage.lowImportanceIcon, NSAttributedString(string: "нет", attributes: [NSAttributedString.Key.font: UIFont.subhead!]), UIImage.highImportanceIcon]
