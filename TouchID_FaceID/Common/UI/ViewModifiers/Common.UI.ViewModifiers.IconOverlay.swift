import SwiftUI

// MARK: - IconOverlay
extension Common.UI.ViewModifiers {
    struct IconOverlay: ViewModifier {
        let image: Icon
        let action: () -> Void
        let side: Side
        let padding: Padding
        
        func body(content: Content) -> some View {
            let body: AnyView
            
            let buttonPadding: CGFloat = 8
            let button = Button(action: action) {
                image.image
                    .foregroundColor(image.color)
            }
            .padding(buttonPadding)
            
            switch padding {
                case .paddingToIcon(let contentLength, let iconLength):
                    body = .init(HStack(spacing: 0) {
                        if side == .right {
                            content
                                .padding(.trailing, contentLength - buttonPadding)
                            button
                                .padding(.trailing, iconLength - buttonPadding)
                        } else {
                            button
                                .padding(.leading, iconLength - buttonPadding)
                            content
                                .padding(.leading, contentLength - buttonPadding)
                        }
                    })
                
                case .padding(let contentLength, let iconLength):
                    body = .init(ZStack(alignment: side.alignment) {
                        content
                            .padding(.trailing, contentLength)
                        button
                            .padding(.trailing, iconLength - buttonPadding)
                    })
            }
            
            return body
        }
    }
}

// MARK: - Side
extension Common.UI.ViewModifiers {
    enum Side {
        case left, right
        
        fileprivate var alignment: Alignment {
            switch self {
                case .left:
                    return .leading
                case .right:
                    return .trailing
            }
        }
    }
}

// MARK: - Padding
extension Common.UI.ViewModifiers {
    enum Padding {
        case
            paddingToIcon(content: CGFloat, icon: CGFloat),
            padding(content: CGFloat, icon: CGFloat)
    }
}

// MARK: - Icon
extension Common.UI.ViewModifiers {
    struct Icon {
        let image: Image
        private(set) var color: Color?
    }
}

extension View {
    func iconOverlay(image: Common.UI.ViewModifiers.Icon, action: @escaping () -> Void,
                     side: Common.UI.ViewModifiers.Side, padding: Common.UI.ViewModifiers.Padding) -> some View {
        
        ModifiedContent(content: self,
                        modifier: Common.UI.ViewModifiers.IconOverlay(image: image,
                                                                      action: action,
                                                                      side: side,
                                                                      padding: padding))
    }
    
    func iconOverlaySecureEntry(_ isSecureEntry: Binding<Bool>) -> some View {
        let iconName = isSecureEntry.wrappedValue ? "eye.fill" : "eye.slash.fill"
        let iconPadding: CGFloat = UIDevice.current.userInterfaceIdiom != .pad ? 10 : 16
        return iconOverlay(image: .init(image: .init(systemName: iconName), color: .init(.appIconGray)),
                           action: { isSecureEntry.wrappedValue.toggle() },
                           side: .right, padding: .paddingToIcon(content: 0, icon: iconPadding))
    }
}
