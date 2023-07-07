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
        static let separatorSupport = UIColor(named: "SeparatorSupport") ?? .systemRed
        static let overlaySupport = UIColor(named: "OverlaySupport") ?? .systemRed
        static let NavBarBlurSupport = UIColor(named: "NavBarBlurSupport") ?? .systemRed

        // Label
        static let disableLabel = UIColor(named: "DisableLabel") ?? .systemRed
        static let primaryLabel = UIColor(named: "PrimaryLabel") ?? .systemRed
        static let secondaryLabel = UIColor(named: "SecondaryLabel") ?? .systemRed
        static let tertiaryLabel = UIColor(named: "TertiaryLabel") ?? .systemRed

        // Color
        static let blueColor = UIColor(named: "BlueColor") ?? .systemRed
        static let grayColor = UIColor(named: "GrayColor") ?? .systemRed
        static let grayLightColor = UIColor(named: "LightGrayColor") ?? .systemRed
        static let greenColor = UIColor(named: "GreenColor") ?? .systemRed
        static let redColor = UIColor(named: "RedColor") ?? .systemRed
        static let whiteColor = UIColor(named: "WhiteColor") ?? .systemRed

        // Back
        static let elevatedBack = UIColor(named: "ElevatedBack") ?? .systemRed
        static let iosPrimaryBack = UIColor(named: "iOSPrimaryBack") ?? .systemRed
        static let primaryBack = UIColor(named: "PrimaryBack") ?? .systemRed
        static let secondaryBack = UIColor(named: "SecondaryBack") ?? .systemRed
        static let color = ""
    }

    enum Images {
        static let lowImportanceIcon = UIImage(named: "LowImportance") ?? UIImage()
        static let highImportanceIcon = UIImage(named: "HighImportance") ?? UIImage()
        static let cellArrow = UIImage(named: "CellArrow") ?? UIImage()
        static let plusButton = UIImage(named: "PlusButton") ?? UIImage()

        static let calendarImage = UIImage(systemName: "calendar")?
            .withTintColor(Resources.Colors.secondaryLabel, renderingMode: .alwaysOriginal)
        static let checkMarkImage = UIImage(systemName: "circle")?
            .withTintColor(Resources.Colors.secondaryLabel, renderingMode: .alwaysOriginal) ?? UIImage()
        static let checkHighImportanceMarkImage = UIImage(systemName: "circle")?
            .withTintColor(Resources.Colors.redColor, renderingMode: .alwaysOriginal) ?? UIImage()
        static let checkDoneMarkImage = UIImage(systemName: "checkmark.circle.fill")?
            .withTintColor(Resources.Colors.greenColor, renderingMode: .alwaysOriginal) ?? UIImage()
        static let trashImage = UIImage(systemName: "trash.fill")?
            .withTintColor(.white, renderingMode: .alwaysOriginal) ?? UIImage()
        static let fillCheckmarkCircle = UIImage(systemName: "checkmark.circle.fill")?
            .withTintColor(.white, renderingMode: .alwaysOriginal) ?? UIImage()

    }
}
