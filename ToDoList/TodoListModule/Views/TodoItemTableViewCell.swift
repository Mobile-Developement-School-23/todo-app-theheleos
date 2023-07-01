import UIKit

class TodoItemTableViewCell: UITableViewCell {
    
    static let identifier = "todoItemCell"
    
    internal let itemTextLabel = UILabel()
    private let deadlineLabel = UILabel()
    
    private let importanceImageView = UIImageView()
    private let calendarImageView = UIImageView()
    
    private let titleAndDateDeadlineStack = UIStackView()
    private let mainStack = UIStackView()
    private let dateDeadlineStack = UIStackView()
    
    let circleButton = UIButton()
    private let arrowButton = UIButton()
    
    private let normalImportanceCircleImage = UIImage(systemName: "circle")?.withTintColor(.secondaryLabel, renderingMode: .alwaysOriginal)
    private let highImportanceCircleImage = UIImage(systemName: "circle")?.withTintColor(.red, renderingMode: .alwaysOriginal)
    private let doneImportanceCircleImage = UIImage(systemName: "checkmark.circle.fill")?.withTintColor(.green, renderingMode: .alwaysOriginal)
    
    private let calendarImage = UIImage(systemName: "calendar")?.withTintColor(.secondaryLabel, renderingMode: .alwaysOriginal)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func setupView() {
        titleAndDateDeadlineStack.axis = .vertical
        dateDeadlineStack.axis = .horizontal
        
        contentView.backgroundColor = Resources.Colors.secondaryBack
        
        itemTextLabel.font = .body
        itemTextLabel.textColor = Resources.Colors.primaryLabel
        itemTextLabel.numberOfLines = 3
        itemTextLabel.sizeToFit()
        
        circleButton.contentVerticalAlignment = .fill
        circleButton.contentHorizontalAlignment = .fill
        
        deadlineLabel.font = .subhead
        deadlineLabel.textColor = .secondaryLabel
        
        mainStack.axis = .horizontal
        mainStack.spacing = 2
        mainStack.alignment = .top
        
        dateDeadlineStack.spacing = 2
            
        arrowButton.imageView?.image = UIImage(named: "ChevronRight")
         
        addSubviews()
        setupLayout()
    }
    
    func addSubviews() {
        contentView.addSubview(circleButton)
        contentView.addSubview(mainStack)
        contentView.addSubview(arrowButton)
        
        mainStack.addArrangedSubview(importanceImageView)
        mainStack.addArrangedSubview(titleAndDateDeadlineStack)
        
        titleAndDateDeadlineStack.addArrangedSubview(itemTextLabel)
        titleAndDateDeadlineStack.addArrangedSubview(dateDeadlineStack)
        
        dateDeadlineStack.addArrangedSubview(calendarImageView)
        dateDeadlineStack.addArrangedSubview(deadlineLabel)
    }
    
    func setupLayout() {
        circleButton.translatesAutoresizingMaskIntoConstraints = false
        circleButton.heightAnchor.constraint(equalToConstant: 24).isActive = true
        circleButton.widthAnchor.constraint(equalToConstant: 24).isActive = true
        circleButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Resources.Constants.edgeSize).isActive = true
        circleButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Resources.Constants.edgeSize).isActive = true
        mainStack.leadingAnchor.constraint(equalTo: circleButton.trailingAnchor, constant: 12).isActive = true
        mainStack.trailingAnchor.constraint(equalTo: arrowButton.leadingAnchor, constant: -Resources.Constants.edgeSize).isActive = true
        mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Resources.Constants.edgeSize).isActive = true
        
        arrowButton.translatesAutoresizingMaskIntoConstraints = false
        arrowButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Resources.Constants.edgeSize).isActive = true
        arrowButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        arrowButton.widthAnchor.constraint(equalToConstant: 7).isActive = true
        arrowButton.heightAnchor.constraint(equalToConstant: 11).isActive = true
        
        importanceImageView.translatesAutoresizingMaskIntoConstraints = false
        importanceImageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        importanceImageView.widthAnchor.constraint(equalToConstant: 16).isActive = true
        
        calendarImageView.translatesAutoresizingMaskIntoConstraints = false
        calendarImageView.heightAnchor.constraint(equalToConstant: 16).isActive = true
        calendarImageView.widthAnchor.constraint(equalToConstant: 16).isActive = true
    }
    
    func configureCell(_ item: TodoItem) {
        if item.dateСreation == .distantPast {
            itemTextLabel.attributedText = NSAttributedString(string: "Новое", attributes: [NSAttributedString.Key.strikethroughStyle: 0])
            itemTextLabel.textColor = .secondaryLabel
            dateDeadlineStack.isHidden = true
            arrowButton.isHidden = true
            circleButton.isHidden = true
            importanceImageView.isHidden = true
        } else {
            itemTextLabel.attributedText = NSAttributedString(string: item.text)
            
            if let dateDeadline = item.dateDeadline {
                deadlineLabel.text = dateDeadline.toString()
                calendarImageView.image = calendarImage
                dateDeadlineStack.isHidden = false
            } else {
                dateDeadlineStack.isHidden = true
            }
        
            arrowButton.isHidden = false
            arrowButton.setImage(UIImage(named: "ChevronRight"), for: .normal)
            
            circleButton.isHidden = false
            importanceImageView.isHidden = false
            switch item.importance {
                case .important:
                    importanceImageView.image = UIImage(named: "HighImportance")
                    circleButton.setImage(highImportanceCircleImage, for: .normal)
                case .unimportant:
                    importanceImageView.image = UIImage(named: "LowImportance")
                    circleButton.setImage(normalImportanceCircleImage, for: .normal)
                case .ordinary:
                    importanceImageView.isHidden = true
                    circleButton.setImage(normalImportanceCircleImage, for: .normal)
            }
            
            if item.isDone {
                circleButton.setImage(doneImportanceCircleImage, for: .normal)
                itemTextLabel.attributedText = NSAttributedString(string: item.text, attributes: [NSAttributedString.Key.strikethroughStyle: 1])
            } else {
                itemTextLabel.attributedText = NSAttributedString(string: item.text, attributes: [NSAttributedString.Key.strikethroughStyle: 0])
            }
        }
    }
    
}
