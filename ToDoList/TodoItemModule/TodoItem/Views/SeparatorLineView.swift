import UIKit

class SeparatorLineView: UIView {

    init(isHidden: Bool) {
        super.init(frame: .zero)
        
        setupView()
        self.isHidden = isHidden
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = .separatorSupport
        translatesAutoresizingMaskIntoConstraints = false
    }
    
}
