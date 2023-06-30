import UIKit

class LabelsAndButtonView: UIView {
    
    private let myDealsLabel = UILabel(
        text: "Мои Дела",
        textColor: Resources.Colors.primaryLabel,
        font: .largeTitle)
    
    let countDoneTaskLabel = UILabel(
        text: "Выполнено - 0",
        textColor: Resources.Colors.tertiaryLabel,
        font: .subhead)
    
    let showButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Показать", for: .normal)
        button.titleLabel?.font = .subhead
        button.setTitleColor(Resources.Colors.blueColor, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(myDealsLabel)
        
        stackView.addArrangedSubview(countDoneTaskLabel)
        stackView.addArrangedSubview(showButton)
        addSubview(stackView)
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            myDealsLabel.topAnchor.constraint(equalTo: topAnchor),
            myDealsLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            
            stackView.topAnchor.constraint(equalTo: myDealsLabel.bottomAnchor, constant: 18),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
