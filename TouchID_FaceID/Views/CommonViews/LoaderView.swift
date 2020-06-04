import SwiftUI

struct LoaderView: View {
    var isAnimating: Binding<Bool>
    
    var body: some View {
        ZStack {
            Color.appContrastBackground.colorInvert().opacity(0.1)
            ActivityIndicatorView(isAnimating: isAnimating, style: .medium)
        }
        .opacity(isAnimating.wrappedValue ? 1 : 0)
        .animation(.easeInOut)
        .clipped()
    }
}

struct LoaderView_Previews: PreviewProvider {
    static var previews: some View {
        let view = LoaderView(isAnimating: .constant(true))
            .background(Color.appContrastBackground)
        
        return Group {
            view
                .environment(\.colorScheme, .light)
            
            view
                .environment(\.colorScheme, .dark)
        }
        .previewLayout(.fixed(width: 400, height: 200))
    }
}
