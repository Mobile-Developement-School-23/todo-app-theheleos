import UIKit

class TextView: UITextView {
    
    init() {
        super.init(frame: .zero, textContainer: .none)
        
        setupTextView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupTextView() {
        textContainerInset = UIEdgeInsets.init(top: 16, left: 11, bottom: 16, right: 16)
        font = UIFont.body
        layer.cornerRadius = 16
        layer.backgroundColor = UIColor.secondaryBack?.cgColor
        isScrollEnabled = false
        autocorrectionType = .no
        translatesAutoresizingMaskIntoConstraints = false
    }
}

