

import UIKit

class TestViewController: UIViewController {
    
    private let textView = TextView()
    private let todoItemSettingsView = TodoItemSettingsView()
    private let deleteButton = DeleteButtonView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setDelegates()
        setConstraints()
    }
    

    private func setupLayout() {
        view.backgroundColor = .primaryBack
        
        view.addSubview(textView)
        view.addSubview(todoItemSettingsView)
        view.addSubview(deleteButton)
        
        hideKeyboardWhenTappedAround()
    }
    
    
    //MARK: - Set Delegates
    private func setDelegates() {
        textView.delegate = self
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
extension TestViewController: UITextViewDelegate {
    public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.text == Resources.Text.placeholderTitleForTextView && textView.textColor == .tertiaryLabel {
            textView.text = ""
            textView.textColor = .primaryLabel
        }
        return true
    }
    
    public func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if textView.text == "" {
            textView.text = Resources.Text.placeholderTitleForTextView
            textView.textColor = .tertiaryLabel
        }
        return true
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        if textView.text != "" && textView.textColor != .tertiaryLabel {
            navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
}

// MARK: - Set Constaints
extension TestViewController {
    private func setConstraints() {
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: Resources.Constants.edgeSize
            ),
            textView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: Resources.Constants.edgeSize
            ),
            textView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -Resources.Constants.edgeSize
            ),
            textView.heightAnchor.constraint(
                greaterThanOrEqualToConstant: Resources.Constants.textViewHeight
            ),
            
            todoItemSettingsView.topAnchor.constraint(
                equalTo: textView.bottomAnchor,
                constant: Resources.Constants.edgeSize
            ),
            todoItemSettingsView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: Resources.Constants.edgeSize
            ),
            todoItemSettingsView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -Resources.Constants.edgeSize
            ),
            
            deleteButton.topAnchor.constraint(
                equalTo: todoItemSettingsView.bottomAnchor,
                constant: Resources.Constants.edgeSize
            ),
            deleteButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: Resources.Constants.edgeSize
            ),
            deleteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Resources.Constants.edgeSize),
            deleteButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
}
