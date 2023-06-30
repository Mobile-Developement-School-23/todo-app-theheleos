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
        text = "Что надо сделать?"
        textColor = Resources.Colors.tertiaryLabel
        textContainerInset = UIEdgeInsets.init(top: 16, left: 11, bottom: 16, right: 16)
        font = UIFont.body
        layer.cornerRadius = 16
        backgroundColor = Resources.Colors.secondaryBack
        isScrollEnabled = false
        autocorrectionType = .no
        translatesAutoresizingMaskIntoConstraints = false
    }
}
