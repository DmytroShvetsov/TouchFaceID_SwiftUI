import Foundation

enum Environment {
    case
        debug,
        release
}

extension Environment {
    static let stubbed = NSClassFromString("XCTest") != nil
    
    static var current: Environment = {
        #if DEBUG
            return .debug
        #elseif RELEASE
            return .release
        #else
            return .debug
        #endif
    }()
}
