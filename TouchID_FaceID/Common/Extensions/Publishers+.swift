import UIKit
import Combine

// MARK: - keyboardChange
extension Publishers {
    /// keyboardHeight: CGFloat, animationDuration: TimeInterval
    static var keyboardChange: AnyPublisher<(keyboardHeight: CGFloat, animationDuration: TimeInterval), Never> {
        NotificationCenter.default.publisher(for: UIApplication.keyboardWillChangeFrameNotification)
            .map {
                let duration = ($0.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval) ?? 0
                guard let frame = ($0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect) else { return (0, duration) }
                let height = frame.origin.y >= UIScreen.main.bounds.size.height ? 0 : frame.height
                return (height, duration)
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - assignWeak
extension Publisher where Self.Failure == Never {
    func assignWeak<Root: AnyObject>(to keyPath: ReferenceWritableKeyPath<Root, Self.Output>, on object: Root) -> AnyCancellable {
        sink { [weak object] in
            object?[keyPath: keyPath] = $0
        }
    }
}
