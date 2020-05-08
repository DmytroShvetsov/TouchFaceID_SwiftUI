import SwiftUI

struct CustomEmptyView: UIViewRepresentable {
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIView { UIView() }
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<Self>) {}
}

struct CustomEmptyView_Previews: PreviewProvider {
    static var previews: some View {
        CustomEmptyView()
    }
}
