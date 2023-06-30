

import UIKit

class TodoItemViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let textView = TextView()
    private let todoItemSettingsView = TodoItemSettingsView()
    private let deleteButtonView = DeleteButtonView()
    
    private var currentTodoItem: TodoItem? = nil
    private let fileCache = FileCache()
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setConstraints()
        setDelegates()
    }
    
// MARK: - Setup Layout
    
    private func setupLayout() {
        view.backgroundColor = Resources.Colors.primaryBack
        
        setupNavBar()
        
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(textView)
        scrollView.addSubview(todoItemSettingsView)
        scrollView.addSubview(deleteButtonView)
        
        makeLoad()
        setValues()
        
        hideKeyboardWhenTappedAround()
    }
    
    private func setupNavBar() {
        title = Resources.Text.todoItemNavBarTitle
        
        addNavBarButton(location: .leftElement)
        addNavBarButton(location: .rightElement)
        navigationItem.rightBarButtonItem?.setTitleTextAttributes(
            [NSAttributedString.Key.foregroundColor: Resources.Colors.tertiaryLabel!],
            for: .disabled
        )
        
        navigationController!.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.headline ?? .systemFont(ofSize: 17),
            NSAttributedString.Key.foregroundColor: Resources.Colors.primaryLabel ?? .black
        ]
    }
        
        private func addNavBarButton(location: NavBarElements) {
            let button = UIButton(type: .system)
            button.setTitleColor(Resources.Colors.blueColor, for: .normal)
            
            switch location {
            case .leftElement:
                button.setTitle(Resources.Text.cancelButtonTitle, for: .normal)
                button.titleLabel?.font = UIFont.body
                navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
            case .rightElement:
                button.setTitle(Resources.Text.saveButtonTitle, for: .normal)
                button.setTitleColor(Resources.Colors.tertiaryLabel, for: .disabled)
                button.titleLabel?.font = UIFont.headline
                button.addTarget(self, action: #selector(saveTodoItem), for: .touchUpInside)
                navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
            }
        }
    
    //MARK: - Set Delegates
    
    private func setDelegates() {
        textView.delegate = self
    }
    
    // MARK: - Load saved items

    private func makeLoad() {
        do {
            try fileCache.loadFromJSON(file: Resources.Text.mainDataBaseFileName)
        } catch {
            print("Данных не обнаружено")
        }
        
        if !fileCache.todoItems.isEmpty {
            currentTodoItem = fileCache.todoItems.first!.value
        }
    }
    
    private func setValues() {
        if let currentTodoItem = currentTodoItem {
           
            textView.text = currentTodoItem.text
            textView.textColor = Resources.Colors.primaryLabel
            todoItemSettingsView.importanceSegmentControl.selectedSegmentIndex = indexByImportance(currentTodoItem.importance)
            
            if let dateDeadline = currentTodoItem.dateDeadline {
                todoItemSettingsView.dateDeadlineButton.setAttributedTitle(NSAttributedString(string: dateDeadline.toString(), attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .footnote)]), for: .normal)
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
    
    
   //MARK: - objc Methods
    
    @objc func saveTodoItem(sender: UIBarButtonItem) {
        var dateDeadline: Date?
        let importance = importanceByIndex(todoItemSettingsView.importanceSegmentControl.selectedSegmentIndex)
        let deadLineSwtichIsOn = todoItemSettingsView.deadLineSwtich.isOn
        if deadLineSwtichIsOn {
            dateDeadline = todoItemSettingsView.calendarView.date
        }
        
        if currentTodoItem != nil {
            currentTodoItem = TodoItem(id: currentTodoItem!.id, text: textView.text, importance: importance, dateDeadline: dateDeadline, isDone: currentTodoItem!.isDone, dateСreation: currentTodoItem!.dateСreation, dateChanging: Date())
        } else {
            currentTodoItem = TodoItem(text: textView.text, importance: importance, dateDeadline: dateDeadline)
        }
        
        fileCache.add(currentTodoItem!)
        do {
            try fileCache.saveToJSON(file: Resources.Text.mainDataBaseFileName)
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
        
        deleteButtonView.deleteButton.isEnabled = true
    
        dismissKeyboard()
    }
    
    @objc func switchChanged(sender: UISwitch) {
       
        if sender.isOn {
            let nextDayDate = Date.getNextDayDate()
            todoItemSettingsView.calendarView.date = nextDayDate
            todoItemSettingsView.dateDeadlineButton.setAttributedTitle(NSAttributedString(string: nextDayDate.toString(), attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .footnote)]), for: .normal)

            calendarViewAppereanceAnimation(dateSelected: false)
        } else {
            calendarViewDisappereanceAnimation(dateSelected: false)
        }
    }
    
    @objc func datePickerSelected(sender: UIDatePicker) {
        todoItemSettingsView.dateDeadlineButton.setAttributedTitle(NSAttributedString(string: sender.date.toString(), attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .footnote)]), for: .normal)
    }
    
    @objc func dateDeadlineButtonTapped(sender: UIButton) {
        if !todoItemSettingsView.calendarView.isHidden {
            calendarViewDisappereanceAnimation(dateSelected: true)
        } else {
            calendarViewAppereanceAnimation(dateSelected: false)
        }
    }
    
    @objc func deleteTodoItem(sender: UIButton) {

        fileCache.remove(with: currentTodoItem!.id)
        do {
            try fileCache.saveToJSON(file: Resources.Text.mainDataBaseFileName)
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

        textView.text = Resources.Text.placeholderTitleForTextView
        textView.textColor = Resources.Colors.tertiaryLabel
        todoItemSettingsView.importanceSegmentControl.selectedSegmentIndex = 1

        todoItemSettingsView.dateDeadlineButton.isHidden = true
        todoItemSettingsView.calendarView.isHidden = true
        todoItemSettingsView.secondSeparator.isHidden = true
        todoItemSettingsView.deadLineSwtich.isOn = false
        deleteButtonView.deleteButton.isEnabled = false
        navigationItem.rightBarButtonItem?.isEnabled = false

    }
    
    //MARK: - Animations
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
            
            self.todoItemSettingsView.dateDeadlineButton.transform = dateSelected ? .identity : self.todoItemSettingsView.dateDeadlineButton.transform.translatedBy(x: 0, y: -10)
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
        if textView.text == Resources.Text.placeholderTitleForTextView && textView.textColor == Resources.Colors.tertiaryLabel {
            textView.text = ""
            textView.textColor = Resources.Colors.primaryLabel
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
            textView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: Resources.Constants.edgeSize),
            textView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -Resources.Constants.edgeSize),
            textView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -2 * Resources.Constants.edgeSize),
            textView.heightAnchor.constraint(greaterThanOrEqualToConstant: Resources.Constants.textViewHeight),
            
            todoItemSettingsView.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: Resources.Constants.edgeSize),
            todoItemSettingsView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: Resources.Constants.edgeSize),
            todoItemSettingsView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -Resources.Constants.edgeSize),
            
            deleteButtonView.topAnchor.constraint(equalTo: todoItemSettingsView.bottomAnchor, constant: Resources.Constants.edgeSize),
            deleteButtonView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: Resources.Constants.edgeSize),
            deleteButtonView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -Resources.Constants.edgeSize),
            deleteButtonView.heightAnchor.constraint(equalToConstant: 56),
            deleteButtonView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16)
        ])
    }
}
