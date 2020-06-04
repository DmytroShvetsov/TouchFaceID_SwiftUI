import Foundation

enum BuildEnvironment {
    case
        debug,
        release
}

extension BuildEnvironment {
    static let stubbed = NSClassFromString("XCTest") != nil
    
    static var current: BuildEnvironment = {
        #if DEBUG
            return .debug
        #elseif RELEASE
            return .release
        #else
            return .debug
        #endif
    }()
}
