import SwiftUI

extension Root {
    struct RootView: View {
        @ObservedObject var viewModel: RootVM
        
        var body: some View {
            VStack {
                Group {
                    if viewModel.state == .authorized {
                        Main.MainView(viewModel: .init())
                    } else if viewModel.state == .notAuthorized {
                        SignIn.SignInView(viewModel: .init())
                    } else {
                        EmptyView()
                    }
                }
                .transition(.opacity)
            }
            .animation(.default)
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        Root.RootView(viewModel: .init())
    }
}
