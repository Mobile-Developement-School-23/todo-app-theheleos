import UIKit

extension UIColor {
    
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
}


extension UIColor {
     
    func toHex() -> String? {
        guard let components = cgColor.components else {
            return nil
        }
           
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
           
        let hexString = String(format: "#%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        return hexString
    }

    static func colorFromHex(_ hex: String) -> UIColor? {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if hexString.hasPrefix("#") {
            hexString.remove(at: hexString.startIndex)
        }
        
        guard hexString.count == 6 else {
            return nil
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgbValue)
        
        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0x0000FF) / 255.0
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    func adjust(hueBy hue: CGFloat = 0, saturationBy saturation: CGFloat = 0, brightnessBy brightness: CGFloat = 0) -> UIColor {
        var currentHue: CGFloat = 0.0
        var currentSaturation: CGFloat = 0.0
        var currentBrigthness: CGFloat = 0.0
        var currentAlpha: CGFloat = 0.0

        if getHue(&currentHue, saturation: &currentSaturation, brightness: &currentBrigthness, alpha: &currentAlpha) {
            return UIColor(hue: currentHue,
                           saturation: currentSaturation,
                           brightness: brightness,
                           alpha: currentAlpha)
        } else {
            return self
        }
    }
}
