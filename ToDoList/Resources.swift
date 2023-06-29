import UIKit

private let selectedColorButtonSizes: CGFloat = 36
private let importanceSegmentControlHeight: CGFloat = 36
private let separatorHeight: CGFloat = 1
private let textViewHeight: CGFloat = 120
private let dateDeadlineButtonHeight: CGFloat = 18
private let deleteButtonHeight: CGFloat = 56

private let importanceSegmentControlWidth: CGFloat = 156

private let cornerRadius: CGFloat = 16
private let edgeSize: CGFloat = 16
private let verticalStackEdgeSize: CGFloat = 12.5
private let settingsStackViewSpacing: CGFloat = 11


private let todoItemTitle = "Дело"

private let deleteTitle = "Удалить"
private let cancelTitle = "Отменить"
private let saveTitle = "Сохранить"

private let doBeforeTitle = "Cделать до"
private let importanceTitle = "Важность"
private let colorTextTitle = "Цвет текста"

private let mainDataBaseFileName = "2"

private var items: [Any] = [UIImage.lowImportanceIcon, NSAttributedString(string: "нет", attributes: [NSAttributedString.Key.font: UIFont.subhead!]), UIImage.highImportanceIcon]


enum Resources {
    enum Text {
        static let placeholderTitleForTextView = "Что надо сделать?"
    }
    
    
    enum Colors {
        
    }
}
