import UIKit

extension UILabel {
    convenience init(text: String, textColor: UIColor?, font: UIFont?) {
        self.init()
        self.text = text
        self.font = font
        self.textColor = textColor ?? UIColor.systemRed
        self.adjustsFontSizeToFitWidth = true
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}
