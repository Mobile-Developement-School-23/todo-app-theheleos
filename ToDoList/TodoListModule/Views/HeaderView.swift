import UIKit

class HeaderView: UIView {

    private lazy var countDoneTasksLabel = UILabel()
    private lazy var showButton = UIButton()
    var doneCount = 0
    var areDoneCellsHiden = true
    public var change: ((Bool) -> Void)?
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(doneCount: Int = 0) {
        self.doneCount = doneCount
        self.countDoneTasksLabel.text = "Выполнено - \(doneCount)"
    }
    
    private func setupViews() {
        countDoneTasksLabel.text = "Выполнено - \(doneCount)"
        countDoneTasksLabel.textColor = .secondaryLabel
        
        showButton.setTitle("Показать", for: .normal)
        showButton.setTitle("Скрыть", for: .selected)
        showButton.addTarget(self, action: #selector(showButtonTap), for: .touchUpInside)
    
        showButton.setTitleColor(.systemBlue, for: .normal)
        
        addSubview(countDoneTasksLabel)
        addSubview(showButton)
        
        countDoneTasksLabel.translatesAutoresizingMaskIntoConstraints = false
        countDoneTasksLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 2 * Resources.Constants.edgeSize).isActive = true
        countDoneTasksLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        showButton.translatesAutoresizingMaskIntoConstraints = false
        showButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -2 * Resources.Constants.edgeSize).isActive = true
        showButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
    
    @objc func showButtonTap() {
        showButton.isSelected = areDoneCellsHiden
        
        areDoneCellsHiden = !areDoneCellsHiden
        if areDoneCellsHiden {
            if let completion = change {
                completion(true)
            }
        } else {
            if let completion = change {
                completion(false)
            }
        }
        
    }
}
