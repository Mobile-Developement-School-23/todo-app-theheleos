import UIKit

enum Resources {
    
    enum Constants {
        static let edgeSize: CGFloat = 16
        static let cornerRadius: CGFloat = 16
        static let textViewHeight: CGFloat = 120
        static let verticalStackEdgeSize: CGFloat = 12.5
        static let settingsStackViewSpacing: CGFloat = 11
        static let importanceSegmentControlWidth: CGFloat = 150
        static let separatorHeight: CGFloat = 1
        static let dateDeadlineButtonHeight: CGFloat = 18
        
    }
    enum Text {
        static let todoItemNavBarTitle = "Дело"
        static let cancelButtonTitle = "Отменить"
        static let saveButtonTitle = "Сохранить"
        static let importanceLabelTitle = "Важность"
        static let importanceSegmentedControlText = "нет"
        static let deadlineLabelTitle = "Сделать до"
        static let placeholderTitleForTextView = "Что надо сделать?"
        static let deleteTitle = "Удалить"
        static let mainDataBaseFileName = "todoList"
    }
    
    enum Colors {
        // Support
        static let separatorSupport = UIColor(named: "SeparatorSupport")
        static let overlaySupport = UIColor(named: "OverlaySupport")
        static let NavBarBlurSupport = UIColor(named: "NavBarBlurSupport")
        
        // Label
        static let disableLabel = UIColor(named: "DisableLabel")
        static let primaryLabel = UIColor(named: "PrimaryLabel")
        static let secondaryLabel = UIColor(named: "SecondaryLabel")
        static let tertiaryLabel = UIColor(named: "TertiaryLabel")
        
        // Color
        static let blueColor = UIColor(named: "Blue")
        static let grayColor = UIColor(named: "GrayColor")
        static let grayLightColor = UIColor(named: "GrayLightColor")
        static let greenColor = UIColor(named: "Green")
        static let redColor = UIColor(named: "Red")
        static let whiteColor = UIColor(named: "WhiteColor")
        
        // Back
        static let elevatedBack = UIColor(named: "ElevatedBack")
        static let iosPrimaryBack = UIColor(named: "iOSPrimaryBack")
        static let primaryBack = UIColor(named: "PrimaryBack")
        static let secondaryBack = UIColor(named: "SecondaryBack")
        static let color = ""
    }
    
    enum Images {
        static var lowImportanceIcon = UIImage(named: "LowImportance") ?? UIImage()
        static var highImportanceIcon = UIImage(named: "HighImportance") ?? UIImage()
    }
}
