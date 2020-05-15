//import SwiftUI
//import Combine
//
//struct KeyboardHost<Content: View>: View {
//    let view: Content
//
//    @State private var keyboardHeight: CGFloat = 0
//
//    init(@ViewBuilder content: () -> Content) {
//        view = content()
//    }
//
//    var body: some View {
//        VStack(spacing: 0) {
//            view
//            Rectangle()
//                .frame(height: keyboardHeight)
//                .animation(.default)
//                .foregroundColor(.red)
//        }.onReceive(Publishers.keyboardHeight) {
//            self.keyboardHeight = $0
//        }.animation(.easeOut(duration: 0.25))
//    }
//}
