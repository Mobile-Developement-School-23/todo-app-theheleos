import UIKit

class HeaderView: UIView {

    let doneTaskCountLabel = UILabel(text: "", textColor: Resources.Colors.tertiaryLabel, font: .subhead)
    let showButton: UIButton = {
        let butotn = UIButton(type: .system)
        butotn.setTitle("Показать", for: .normal)
        butotn.setTitle("Скрвть", for: .selected)
        return butotn
    }()
    private let headerStack = UIStackView()
    var doneTaskCount = 0
    var areDoneCellsHidden = false

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        addSubview(headerStack)
        headerStack.translatesAutoresizingMaskIntoConstraints = false

        headerStack.addArrangedSubview(doneTaskCountLabel)
        headerStack.addArrangedSubview(showButton)

        doneTaskCountLabel.text = "Выполнено - \(doneTaskCount)"
    }

    func update(doneItemsCount: Int = 0) {
        self.doneTaskCount = doneItemsCount
        doneTaskCountLabel.text = "Выполнено - \(doneTaskCount)"
    }

    private func setConstraints() {
        NSLayoutConstraint.activate([
            headerStack.topAnchor.constraint(equalTo: topAnchor),
            headerStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            headerStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            headerStack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

    }

}
