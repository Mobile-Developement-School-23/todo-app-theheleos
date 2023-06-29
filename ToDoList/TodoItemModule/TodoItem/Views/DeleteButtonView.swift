import UIKit

class DeleteButtonView: UIView {
    
    private let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Resources.Text.deleteTitle, for: .normal)
        button.setTitleColor(.redColor, for: .normal)
        button.setTitleColor(.tertiaryLabel, for: .disabled)
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
        backgroundColor = .secondaryBack
        layer.cornerRadius = Resources.Constants.cornerRadius
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(deleteButton)
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
