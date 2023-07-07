import UIKit

class HeaderView: UIView {

    private let doneTaskCountLabel = UILabel(text: "", textColor: Resources.Colors.tertiaryLabel, font: .subhead)
    private lazy var showButton: UIButton = {
        let butotn = UIButton()
        butotn.setTitle("Показать", for: .normal)
        butotn.setTitle("Скрыть", for: .selected)
        butotn.titleLabel?.font = .boldSystemFont(ofSize: 15)
        butotn.setTitleColor(Resources.Colors.blueColor, for: .normal)
        butotn.addTarget(self, action: #selector(showButtonTap), for: .touchUpInside)
        butotn.translatesAutoresizingMaskIntoConstraints = false
        return butotn
    }()

    var doneTaskCount = 0
    var areDoneCellsHidden = true
    var change: ((Bool) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupViews()
        setConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {

        addSubview(doneTaskCountLabel)
        addSubview(showButton)

        doneTaskCountLabel.text = "Выполнено - \(doneTaskCount)"
    }

    func update(doneItemsCount: Int = 0) {
        self.doneTaskCount = doneItemsCount
        self.doneTaskCountLabel.text = "Выполнено - \(doneTaskCount)"
    }

    // MARK: - objc Methods
    @objc func showButtonTap() {
        showButton.isSelected = areDoneCellsHidden

        areDoneCellsHidden = !areDoneCellsHidden
        if areDoneCellsHidden {
            if let completion = change {
                completion(true)
            }
        } else {
            if let completion = change {
                completion(false)
            }
        }
    }

    private func setConstraints() {
        NSLayoutConstraint.activate([
            doneTaskCountLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 2 * Resources.Constants.edgeSize),
            doneTaskCountLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            showButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -2 * Resources.Constants.edgeSize),
            showButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

    }

}
