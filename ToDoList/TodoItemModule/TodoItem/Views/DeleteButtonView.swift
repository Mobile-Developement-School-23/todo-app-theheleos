import UIKit

class DeleteButtonView: UIView {

    let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Resources.Text.deleteTitle, for: .normal)
        button.setTitleColor(Resources.Colors.redColor, for: .normal)
        button.setTitleColor(Resources.Colors.tertiaryLabel, for: .disabled)
        button.titleLabel?.font = UIFont.body
        button.addTarget(
            nil,
            action: #selector(TodoItemViewController.deleteTodoItem),
            for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
        backgroundColor = Resources.Colors.secondaryBack
        layer.cornerRadius = Resources.Constants.cornerRadius
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(deleteButton)
    }

    func deleteButtonIsEnabled(enable: Bool) {
        deleteButton.isEnabled = enable
    }

    private func setConstraints() {
        NSLayoutConstraint.activate([
            deleteButton.topAnchor.constraint(equalTo: topAnchor),
            deleteButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            deleteButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            deleteButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
