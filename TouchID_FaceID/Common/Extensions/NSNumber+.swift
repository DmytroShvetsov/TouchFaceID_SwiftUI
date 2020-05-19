import Foundation

// MARK: - isBool
extension NSNumber {
    var isBool: Bool { CFBooleanGetTypeID() == CFGetTypeID(self) }
}
