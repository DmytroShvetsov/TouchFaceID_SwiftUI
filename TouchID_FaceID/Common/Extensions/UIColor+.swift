import UIKit

extension UIColor {
    @nonobjc static let appText = UIColor(named: "text") ?? UIColor.systemBackground
    @nonobjc static let appGray = UIColor.systemGray
    @nonobjc static let appIconGray = UIColor.init { $0.userInterfaceStyle == .dark ? .systemGray2 : .systemGray3 }
}
