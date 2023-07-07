import UIKit
import TodoItem

class TodoListCell: UITableViewCell {

    static let identifier = "TodoListCell"

    private var itemTextLabel: UILabel = {
        let label = UILabel()
        label.textColor = Resources.Colors.primaryLabel
        label.font = .body
        label.numberOfLines = 3
        label.sizeToFit()
        return label
    }()

    private var deadlineLabel = UILabel(
        text: "14 июня",
        textColor: Resources.Colors.tertiaryLabel,
        font: .subhead
    )

    private let calendarImageView: UIImageView = {
        let imageView = UIImageView()
        let image = Resources.Images.calendarImage
        imageView.image = image
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    private let importanceImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isHidden = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    let checkMarkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(Resources.Images.checkMarkImage, for: .normal)
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private let chevroneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(Resources.Images.cellArrow, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let deadlineStack: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 2
        stackView.isHidden = true
        return stackView
    }()
    private let titleAndDeadlineStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()
    private let mainStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 2
        stackView.alignment = .top

        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupViews()
        setConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        contentView.backgroundColor = Resources.Colors.secondaryBack

        contentView.addSubview(checkMarkButton)
        contentView.addSubview(mainStack)
        contentView.addSubview(chevroneButton)

        deadlineStack.addArrangedSubview(calendarImageView)
        deadlineStack.addArrangedSubview(deadlineLabel)

        titleAndDeadlineStack.addArrangedSubview(itemTextLabel)
        titleAndDeadlineStack.addArrangedSubview(deadlineStack)

        mainStack.addArrangedSubview(importanceImageView)
        mainStack.addArrangedSubview(titleAndDeadlineStack)
    }

    func configure(for item: TodoItem) {
        if item.dateСreation == .distantPast {
            itemTextLabel.attributedText = NSAttributedString(
                string: "Новое",
                attributes: [NSAttributedString.Key.strikethroughStyle: 0]
            )
            [deadlineStack, chevroneButton, checkMarkButton, importanceImageView].forEach { $0.isHidden = true }
            itemTextLabel.textColor = .secondaryLabel
        } else {
            itemTextLabel.attributedText = NSAttributedString(string: item.text)
            itemTextLabel.textColor = Resources.Colors.primaryLabel

            switch item.importance {
            case .important:
                importanceImageView.image = Resources.Images.highImportanceIcon
                checkMarkButton.setImage(
                    Resources.Images.checkHighImportanceMarkImage, for: .normal
                )
            case .normal:
                importanceImageView.isHidden = true
                checkMarkButton.setImage(
                    Resources.Images.checkMarkImage, for: .normal
                )
            case .unimportant:
                importanceImageView.image = Resources.Images.lowImportanceIcon
                checkMarkButton.setImage(
                    Resources.Images.checkMarkImage, for: .normal
                )
            }

            if let deadline = item.dateDeadline {
                deadlineStack.isHidden = false
                deadlineLabel.text = deadline.toString(with: "d MMMM")
            } else {
                deadlineStack.isHidden = true
            }

            [chevroneButton, checkMarkButton, importanceImageView].forEach { $0.isHidden = false }

            if item.isDone {
                checkMarkButton.setImage(
                    Resources.Images.checkDoneMarkImage,
                     for: .normal)
                itemTextLabel.attributedText = NSAttributedString(
                    string: item.text,
                    attributes: [NSAttributedString.Key.strikethroughStyle: 1]
                )
                itemTextLabel.textColor = Resources.Colors.tertiaryLabel
            } else {
                itemTextLabel.attributedText = NSAttributedString(
                    string: item.text,
                    attributes: [NSAttributedString.Key.strikethroughStyle: 0]
                )
            }
        }
    }
}

extension TodoListCell {
    private func setConstraints() {
        NSLayoutConstraint.activate([

            checkMarkButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkMarkButton.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: Resources.Constants.edgeSize
            ),

            chevroneButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            chevroneButton.trailingAnchor.constraint(
                equalTo: contentView.safeAreaLayoutGuide.trailingAnchor,
                constant: -Resources.Constants.edgeSize
            ),

            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Resources.Constants.edgeSize),
            mainStack.leadingAnchor.constraint(equalTo: checkMarkButton.trailingAnchor, constant: 12),
            mainStack.trailingAnchor.constraint(
                equalTo: chevroneButton.leadingAnchor,
                constant: -Resources.Constants.edgeSize
            ),
            mainStack.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -Resources.Constants.edgeSize
            ),

            calendarImageView.heightAnchor.constraint(equalToConstant: 16),
            calendarImageView.widthAnchor.constraint(equalToConstant: 16)
        ])
    }
}
