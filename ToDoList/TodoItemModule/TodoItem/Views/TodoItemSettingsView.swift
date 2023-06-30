import UIKit

class TodoItemSettingsView: UIView {
    
    private let importanceLabel = UILabel(
        text: Resources.Text.importanceLabelTitle,
        textColor: Resources.Colors.primaryLabel,
        font: .body
    )
       
    let importanceSegmentControl: UISegmentedControl = {
        let items: [Any] = [
            Resources.Images.lowImportanceIcon,
            NSAttributedString(
                string: Resources.Text.importanceSegmentedControlText,
                attributes: [
                    NSAttributedString.Key.font: UIFont.subhead ?? UIFont.systemFont(ofSize: 15)
                ]
            ),
            Resources.Images.highImportanceIcon
        ]
        
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.selectedSegmentIndex = 1
        segmentedControl.selectedSegmentTintColor = Resources.Colors.elevatedBack
        segmentedControl.backgroundColor = Resources.Colors.overlaySupport
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        return segmentedControl
    }()
    
    private let importanceStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = Resources.Constants.edgeSize
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
   
    private let firstSeparator = SeparatorLineView(isHidden: false)
    
    private let deadlineLabel = UILabel(
        text: Resources.Text.deadlineLabelTitle,
        textColor: Resources.Colors.primaryLabel,
        font: .body
    )
    
    let deadLineSwtich: UISwitch = {
        let switcher = UISwitch()
        switcher.onTintColor = Resources.Colors.greenColor
        switcher.layer.cornerRadius = Resources.Constants.cornerRadius
        switcher.layer.masksToBounds = true
        switcher.backgroundColor = Resources.Colors.overlaySupport
        switcher.addTarget(
            nil,
            action: #selector(TodoItemViewController.switchChanged),
            for: .valueChanged
        )
        switcher.translatesAutoresizingMaskIntoConstraints = false
        return switcher
    }()
    
    private lazy var deadlineStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = Resources.Constants.edgeSize
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let dateDeadlineButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(Resources.Colors.blueColor, for: .normal)
        button.contentHorizontalAlignment = .left
        button.isHidden = true
        button.addTarget(
            nil,
            action: #selector(TodoItemViewController.dateDeadlineButtonTapped),
            for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let secondSeparator = SeparatorLineView(isHidden: true)
    
    let calendarView: UIDatePicker = {
        let datePicker = UIDatePicker()

        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.calendar.firstWeekday = 2
        datePicker.minimumDate = Date()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
        datePicker.addTarget(
            nil,
            action: #selector(TodoItemViewController.datePickerSelected),
            for: .valueChanged)
        datePicker.isHidden = true
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        return datePicker
    }()
    
    private lazy var deadlineVerticalSubStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.alignment = .leading
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var settingsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = Resources.Colors.secondaryBack
        stackView.layer.cornerRadius = Resources.Constants.cornerRadius
        stackView.axis = .vertical
        stackView.spacing = Resources.Constants.settingsStackViewSpacing
        stackView.distribution = .fillProportionally
        stackView.layoutMargins = UIEdgeInsets(
            top: Resources.Constants.verticalStackEdgeSize,
            left: Resources.Constants.edgeSize,
            bottom: Resources.Constants.verticalStackEdgeSize,
            right: Resources.Constants.edgeSize)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        setupLayout()
        setConstraints()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        layer.cornerRadius = 16
        layer.backgroundColor = Resources.Colors.secondaryBack?.cgColor
        translatesAutoresizingMaskIntoConstraints = false
        
        
        
        addSubview(settingsStackView)
        
        settingsStackView.addArrangedSubview(importanceStackView)
        settingsStackView.addArrangedSubview(firstSeparator)
        settingsStackView.addArrangedSubview(secondSeparator)
        settingsStackView.addArrangedSubview(deadlineStackView)
        settingsStackView.addArrangedSubview(secondSeparator)
        settingsStackView.addArrangedSubview(calendarView)
        
        importanceStackView.addArrangedSubview(importanceLabel)
        importanceStackView.addArrangedSubview(importanceSegmentControl)
        
        deadlineStackView.addArrangedSubview(deadlineVerticalSubStack)
        deadlineStackView.addArrangedSubview(deadLineSwtich)
        
        deadlineVerticalSubStack.addArrangedSubview(deadlineLabel)
        deadlineVerticalSubStack.addArrangedSubview(dateDeadlineButton)
    }
    
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            
            
            settingsStackView.topAnchor.constraint(equalTo: topAnchor),
            settingsStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            settingsStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            settingsStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            firstSeparator.heightAnchor.constraint(equalToConstant: Resources.Constants.separatorHeight),
            
            
            secondSeparator.heightAnchor.constraint(equalToConstant: Resources.Constants.separatorHeight),

            importanceSegmentControl.widthAnchor.constraint(equalToConstant: Resources.Constants.importanceSegmentControlWidth),
            
            dateDeadlineButton.heightAnchor.constraint(equalToConstant: Resources.Constants.dateDeadlineButtonHeight)
        ])
    }
}
