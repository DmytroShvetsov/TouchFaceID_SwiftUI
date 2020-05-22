import SwiftUI

extension Root {
    struct RootView: View {
        @ObservedObject var viewModel: RootVM
        
        var body: some View {
            Group {
                if viewModel.state == .authorized {
                    MainView()
                } else {
                    SignIn.SignInView(viewModel: .init())
                }
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        Root.RootView(viewModel: .init())
    }
}
