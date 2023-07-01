import UIKit

class TodoItemViewCell: UITableViewCell {
    
    static let idTableViewCell = "todoItemCell"

    private let itemTextLabel: UILabel = {
        let label = UILabel()
        label.font = .body
        label.textColor = Resources.Colors.primaryLabel
        label.numberOfLines = 3
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let deadlineLabel = UILabel(
        text: "",
        textColor: Resources.Colors.secondaryLabel,
        font: .subhead
    )
    
    private let importanceImageView = UIImageView()
    private let calendarImageView: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(systemName: "circle")
        image?.withTintColor(Resources.Colors.secondaryLabel!, renderingMode: .alwaysOriginal)
        imageView.image = image
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let circleButton: UIButton = {
        let button = UIButton()
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        return button
    }()
    private let arrowButton: UIButton = {
        let button = UIButton()
        button.imageView?.image = UIImage(named: "Arrow")
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // Испрваить forceunwrap
    
    private let normalImportanceCircleImage: UIImage = {
        let image = UIImage(systemName: "circle")
        image?.withTintColor(Resources.Colors.secondaryLabel!, renderingMode: .alwaysOriginal)
        return image ?? UIImage()
    }()
    
    private let highImportanceCircleImage: UIImage = {
        let image = UIImage(systemName: "circle")
        image?.withTintColor(Resources.Colors.redColor!, renderingMode: .alwaysOriginal)
        return image ?? UIImage()
    }()
    
    private let doneImportanceCircleImage: UIImage = {
        let image = UIImage(systemName: "checkmark.circle.fill")
        image?.withTintColor(Resources.Colors.greenColor!, renderingMode: .alwaysOriginal)
        return image ?? UIImage()
    }()
    
    private let calendarImage = UIImage(systemName: "calendar")?.withTintColor(.secondaryLabel, renderingMode: .alwaysOriginal)
    
    private let titleAndDateDeadlineStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()
    private let mainStack: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 2
        stackView.alignment = .top
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    private let dateDeadlineStack: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 2
        return stackView
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func setupViews() {
        contentView.backgroundColor = Resources.Colors.secondaryBack
        
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
                case .normal:
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




extension TodoItemViewCell {
    func setupLayout() {
        circleButton.translatesAutoresizingMaskIntoConstraints = false
        circleButton.heightAnchor.constraint(equalToConstant: 24).isActive = true
        circleButton.widthAnchor.constraint(equalToConstant: 24).isActive = true
        circleButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Resources.Constants.edgeSize).isActive = true
        circleButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: edgeSize).isActive = true
        mainStack.leadingAnchor.constraint(equalTo: circleButton.trailingAnchor, constant: 12).isActive = true
        mainStack.trailingAnchor.constraint(equalTo: arrowButton.leadingAnchor, constant: -edgeSize).isActive = true
        mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -edgeSize).isActive = true
        
        arrowButton.translatesAutoresizingMaskIntoConstraints = false
        arrowButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -edgeSize).isActive = true
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
}































